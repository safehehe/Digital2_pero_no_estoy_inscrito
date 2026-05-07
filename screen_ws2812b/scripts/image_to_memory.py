#!/usr/bin/env python3
"""
Script para convertir imagen PNG RGB (24 bits) a archivo .hex para memoria Verilog
Formato de salida: GRB (Green-Red-Blue) en palabras de 24 bits
"""

import argparse
import sys
from PIL import Image
import os

def rgb_to_grb(r, g, b):
    """
    Convierte un pixel RGB a formato GRB
    
    Args:
        r (int): Valor rojo (0-255)
        g (int): Valor verde (0-255)
        b (int): Valor azul (0-255)
    
    Returns:
        int: Valor de 24 bits en formato GRB
    """
    return (g << 16) | (r << 8) | b

def process_image_to_hex(input_image_path, output_hex_path, width=None, height=None, 
                         verbose=False, padding_value=0x000000):
    """
    Convierte una imagen PNG a archivo .hex para memoria Verilog
    
    Args:
        input_image_path (str): Ruta de la imagen PNG de entrada
        output_hex_path (str): Ruta del archivo .hex de salida
        width (int, optional): Ancho deseado de memoria (con padding si es necesario)
        height (int, optional): Alto deseado de memoria (con padding si es necesario)
        verbose (bool): Muestra información detallada del proceso
        padding_value (int): Valor de relleno (24 bits) si la imagen no ocupa toda la memoria
    """
    
    try:
        # Abrir la imagen
        img = Image.open(input_image_path)
        
        # Convertir a RGB si es necesario
        if img.mode != 'RGB':
            if verbose:
                print(f"Convirtiendo imagen de modo {img.mode} a RGB")
            img = img.convert('RGB')
        
        original_width, original_height = img.size
        if verbose:
            print(f"Dimensiones originales: {original_width}x{original_height}")
        
        # Si no se especifican dimensiones, usar las de la imagen
        if width is None:
            width = original_width
        if height is None:
            height = original_height
        
        # Redimensionar imagen si las dimensiones difieren
        if (width, height) != (original_width, original_height):
            img = img.resize((width, height), Image.Resampling.LANCZOS)
            if verbose:
                print(f"Redimensionada a: {width}x{height}")
        
        final_width, final_height = width, height
        total_pixels = final_width * final_height
        
        if verbose:
            print(f"Dimensiones finales de memoria: {final_width}x{final_height}")
            print(f"Total de palabras de memoria: {total_pixels}")
            print(f"Valor de padding: 0x{padding_value:06X}")
        
        # Convertir píxeles y escribir archivo .hex
        with open(output_hex_path, 'w') as hex_file:
            pixel_count = 0
            
            # Si la imagen es más grande, solo tomamos la parte que cabe
            # Si es más pequeña, la centramos y agregamos padding
            img_width, img_height = img.size
            
            # Calcular offsets para centrar la imagen si es más pequeña
            offset_x = max(0, (final_width - img_width) // 2)
            offset_y = max(0, (final_height - img_height) // 2)
            
            for y in range(final_height):
                for x in range(final_width):
                    # Verificar si el pixel está dentro de la imagen
                    if (offset_x <= x < offset_x + img_width and 
                        offset_y <= y < offset_y + img_height):
                        # Pixel de la imagen
                        img_x = x - offset_x
                        img_y = y - offset_y
                        r, g, b = img.getpixel((img_x, img_y))
                        grb_value = rgb_to_grb(r, g, b)
                    else:
                        # Padding
                        grb_value = padding_value
                    
                    # Escribir en formato hexadecimal de 6 dígitos (24 bits)
                    hex_file.write(f"{grb_value:06X}\n")
                    pixel_count += 1
            
            if verbose:
                print(f"Total de palabras escritas: {pixel_count}")
                print(f"Archivo .hex generado: {output_hex_path}")
                
                # Mostrar estadísticas del archivo
                file_size = os.path.getsize(output_hex_path)
                print(f"Tamaño del archivo: {file_size} bytes")
                
                # Calcular cuántos píxeles son de la imagen vs padding
                img_pixels = min(img_width, final_width) * min(img_height, final_height)
                padding_pixels = total_pixels - img_pixels
                print(f"Píxeles de imagen: {img_pixels}")
                print(f"Píxeles de padding: {padding_pixels}")
        
        return True
        
    except FileNotFoundError:
        print(f"Error: No se encontró el archivo {input_image_path}")
        return False
    except Exception as e:
        print(f"Error al procesar la imagen: {e}")
        return False

def main():
    parser = argparse.ArgumentParser(
        description='Convierte imagen PNG RGB a archivo .hex para memoria Verilog (formato GRB)',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Ejemplos de uso:
  python script.py imagen.png -o memoria.hex
  python script.py imagen.png -o memoria.hex -W 640 -H 480
  python script.py imagen.png -o memoria.hex --width 320 --height 240 -v
  python script.py imagen.png -o memoria.hex -W 800 -H 600 --padding 0xFF0000
        """
    )
    
    parser.add_argument('input', help='Archivo PNG de entrada')
    parser.add_argument('-o', '--output', default='output.hex', 
                       help='Archivo .hex de salida (default: output.hex)')
    parser.add_argument('-W', '--width', type=int, 
                       help='Ancho de la memoria en píxeles')
    parser.add_argument('-H', '--height', type=int, 
                       help='Alto de la memoria en píxeles')
    parser.add_argument('-v', '--verbose', action='store_true',
                       help='Mostrar información detallada del proceso')
    parser.add_argument('--padding', type=lambda x: int(x, 16), default=0x000000,
                       help='Valor de padding en hexadecimal (default: 0x000000)')
    
    args = parser.parse_args()
    
    if not args.input.lower().endswith('.png'):
        print("Advertencia: El archivo de entrada no tiene extensión .png")
    
    # Si no se especifican dimensiones, se usarán las de la imagen original
    if args.width is None and args.height is None:
        print("Nota: No se especificaron dimensiones. Se usarán las dimensiones de la imagen original.")
    
    success = process_image_to_hex(
        args.input,
        args.output,
        args.width,
        args.height,
        args.verbose,
        args.padding
    )
    
    if success:
        sys.exit(0)
    else:
        sys.exit(1)

if __name__ == "__main__":
    main()