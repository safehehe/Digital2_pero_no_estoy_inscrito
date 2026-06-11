import tkinter as tk
from tkinter import messagebox, filedialog, ttk, colorchooser
import serial
import serial.tools.list_ports
import sys

class PixelArtSerialApp:
    def __init__(self, root):
        self.root = root
        self.root.title("Pixel Art to Serial Sender")
        
        # --- SOPORTE HIGH DPI / ANTIALIASING ---
        try:
            if sys.platform.startswith('win'):
                import ctypes
                ctypes.windll.shcore.SetProcessDpiAwareness(1)
            elif sys.platform.startswith('linux') or sys.platform.startswith('darwin'):
                self.root.tk.call('tk', 'scaling', 1.33)
        except Exception:
            pass

        self.root.configure(bg="#F0F4F8", cursor="arrow")
        
        # Variables de estado
        self.grid_size = tk.IntVar(value=8)
        self.current_color = "#FFB7B2"
        self.pixels = {}
        self.canvas_size = 400
        
        self.setup_ui()
        self.create_grid()

    def setup_ui(self):
        # Contenedor Izquierdo (Canvas y Botón Enviar)
        left_frame = tk.Frame(self.root, bg="#F0F4F8")
        left_frame.grid(row=0, column=0, padx=20, pady=20, sticky="ns")
        
        self.canvas = tk.Canvas(
            left_frame, 
            width=self.canvas_size, 
            height=self.canvas_size, 
            bg="#FFFFFF", 
            highlightthickness=1, 
            highlightbackground="#D8E2DC",
            cursor="cross"
        )
        self.canvas.pack(pady=10)
        self.canvas.bind("<B1-Motion>", self.paint)
        self.canvas.bind("<Button-1>", self.paint)
        
        btn_send = tk.Button(
            left_frame, text="⚡ Enviar a Dispositivo", 
            bg="#B5E2FA", fg="#2A4494", 
            font=("Helvetica", 11, "bold"), 
            command=self.send_serial, 
            relief="flat", padx=10, pady=7,
            cursor="hand2"
        )
        btn_send.pack(fill="x", pady=5)

        # Contenedor Derecho (Controles)
        right_frame = tk.Frame(self.root, bg="#F0F4F8")
        right_frame.grid(row=0, column=1, padx=20, pady=20, sticky="n")
        
        # --- SECCIÓN 1: Tamaño de Matriz ---
        size_frame = tk.LabelFrame(right_frame, text=" Tamaño de Matriz ", bg="#F0F4F8", fg="#5E60CE", font=("Helvetica", 10, "bold"))
        size_frame.pack(fill="x", pady=5)
        
        style = ttk.Style()
        style.configure("TRadiobutton", background="#F0F4F8", font=("Helvetica", 10))
        
        ttk.Radiobutton(size_frame, text="8x8", variable=self.grid_size, value=8, command=self.rebuild_grid, style="TRadiobutton").pack(side="left", padx=10, pady=5)
        ttk.Radiobutton(size_frame, text="16x16", variable=self.grid_size, value=16, command=self.rebuild_grid, style="TRadiobutton").pack(side="left", padx=10, pady=5)
        ttk.Radiobutton(size_frame, text="32x32", variable=self.grid_size, value=32, command=self.rebuild_grid, style="TRadiobutton").pack(side="left", padx=10, pady=5)

        # --- SECCIÓN 2: Selector de Color (Rueda y Paleta) ---
        color_frame = tk.LabelFrame(right_frame, text=" Color (24-bit) ", bg="#F0F4F8", fg="#5E60CE", font=("Helvetica", 10, "bold"))
        color_frame.pack(fill="x", pady=5)
        
        btn_wheel = tk.Button(
            color_frame, text="🎨 Abrir Rueda de Color", 
            bg="#C7CEEA", fg="#4A4E69", 
            font=("Helvetica", 10, "bold"), 
            command=self.open_color_wheel, 
            relief="flat", pady=6, cursor="hand2"
        )
        btn_wheel.pack(fill="x", padx=10, pady=8)
        
        pastels = ["#FFB7B2", "#FFDAC1", "#E2F0CB", "#B5E2FA", "#C7CEEA", "#FFFFFC", "#000000"]
        color_grid = tk.Frame(color_frame, bg="#F0F4F8")
        color_grid.pack(pady=2, padx=5)
        
        for i, color in enumerate(pastels):
            btn = tk.Button(color_grid, bg=color, width=3, height=1, relief="flat", command=lambda c=color: self.set_color(c), cursor="hand2")
            btn.grid(row=0, column=i, padx=2, pady=2)
            
        self.color_preview = tk.Label(color_frame, text="Color Seleccionado", bg=self.current_color, font=("Helvetica", 9, "bold"), fg="#333333", height=2)
        self.color_preview.pack(fill="x", padx=10, pady=8)

        # --- SECCIÓN 3: Configuración Serial ---
        serial_frame = tk.LabelFrame(right_frame, text=" Conexión Serial ", bg="#F0F4F8", fg="#5E60CE", font=("Helvetica", 10, "bold"))
        serial_frame.pack(fill="x", pady=5)
        
        tk.Label(serial_frame, text="Puerto:", bg="#F0F4F8", font=("Helvetica", 10)).grid(row=0, column=0, padx=5, pady=5, sticky="e")
        self.combo_port = ttk.Combobox(serial_frame, values=self.get_linux_ports(), width=15, font=("Helvetica", 10))
        self.combo_port.grid(row=0, column=1, padx=5, pady=5)
        if self.combo_port['values']: self.combo_port.current(0)
        
        tk.Label(serial_frame, text="Baudrate:", bg="#F0F4F8", font=("Helvetica", 10)).grid(row=1, column=0, padx=5, pady=5, sticky="e")
        self.combo_baud = ttk.Combobox(serial_frame, values=[9600, 115200, 57600, 38400], width=15, font=("Helvetica", 10))
        self.combo_baud.grid(row=1, column=1, padx=5, pady=5)
        self.combo_baud.current(1)

        # --- SECCIÓN 4: Archivo/Guardar ---
        file_frame = tk.LabelFrame(right_frame, text=" Archivo ", bg="#F0F4F8", fg="#5E60CE", font=("Helvetica", 10, "bold"))
        file_frame.pack(fill="x", pady=5)
        
        btn_save = tk.Button(file_frame, text="💾 Guardar Hex Raw", bg="#E2F0CB", fg="#46661D", font=("Helvetica", 10), command=self.save_hex_file, relief="flat", cursor="hand2")
        btn_save.pack(fill="x", padx=10, pady=10)

    def open_color_wheel(self):
        # SOLUCIÓN: Forzar cursor visible antes de abrir el diálogo modal
        self.root.config(cursor="arrow")
        self.root.update_idletasks() 
        
        # Pasa 'self.root' como padre explícito para heredar propiedades de ventana correctamente
        color_code = colorchooser.askcolor(title="Selecciona cualquier color (24-bit)", parent=self.root)
        
        if color_code[1]: 
            self.set_color(color_code[1])
            
        # Restaurar cursor por si acaso al cerrar el diálogo
        self.root.config(cursor="arrow")

    def get_linux_ports(self):
        ports = serial.tools.list_ports.comports()
        return [p.device for p in ports if "ttyUSB" in p.device or "ttyACM" in p.device]

    def create_grid(self):
        self.canvas.delete("all")
        self.pixels.clear()
        size = self.grid_size.get()
        self.cell_size = self.canvas_size / size
        
        for i in range(size):
            for j in range(size):
                x1, y1 = i * self.cell_size, j * self.cell_size
                x2, y2 = x1 + self.cell_size, y1 + self.cell_size
                self.canvas.create_rectangle(x1, y1, x2, y2, fill="#FFFFFF", outline="#E0E0E0")
                self.pixels[(i, j)] = "#FFFFFF"

    def rebuild_grid(self):
        if messagebox.askyesno("Confirmar", "¿Deseas cambiar el tamaño? Se perderá el dibujo actual."):
            self.create_grid()

    def set_color(self, color):
        self.current_color = color
        self.color_preview.configure(bg=color)
        rgb = self.root.winfo_rgb(color)
        brightness = (rgb[0] + rgb[1] + rgb[2]) / 3
        self.color_preview.configure(fg="#000000" if brightness > 32768 else "#FFFFFF")

    def paint(self, event):
        size = self.grid_size.get()
        x = int(event.x // self.cell_size)
        y = int(event.y // self.cell_size)
        
        if 0 <= x < size and 0 <= y < size:
            x1, y1 = x * self.cell_size, y * self.cell_size
            x2, y2 = x1 + self.cell_size, y1 + self.cell_size
            
            overlapping = self.canvas.find_overlapping(x1+1, y1+1, x2-1, y2-1)
            if overlapping:
                self.canvas.itemconfig(overlapping[0], fill=self.current_color)
                self.pixels[(x, y)] = self.current_color

    def get_rgb_payload(self):
        size = self.grid_size.get()
        payload = bytearray()
        for y in range(size):
            for x in range(size):
                hex_color = self.pixels.get((x, y), "#FFFFFF").lstrip('#')
                r = int(hex_color[0:2], 16)
                g = int(hex_color[2:4], 16)
                b = int(hex_color[4:6], 16)
                payload.append(b)
                payload.append(g)
                payload.append(r)
        return payload

    def send_serial(self):
        port = self.combo_port.get()
        baud = self.combo_baud.get()
        if not port:
            messagebox.showerror("Error", "No se ha seleccionado ningún dispositivo serial (ttyUSB/ttyACM).")
            return
        try:
            data = self.get_rgb_payload()
            ser = serial.Serial(port, baudrate=int(baud), timeout=1)
            ser.write(data)
            ser.close()
            messagebox.showinfo("Éxito", f"Datos enviados correctamente a {port}")
        except Exception as e:
            messagebox.showerror("Error Serial", f"No se pudo enviar la información:\n{str(e)}")

    def save_hex_file(self):
        file_path = filedialog.asksaveasfilename(defaultextension=".txt", filetypes=[("Texto Hex", "*.txt")])
        if file_path:
            try:
                data = self.get_rgb_payload()
                hex_string = data.hex().upper()
                formatted_hex = " ".join(hex_string[i:i+6] for i in range(0, len(hex_string), 6))
                with open(file_path, "w") as f:
                    f.write(formatted_hex)
                messagebox.showinfo("Guardado", "Archivo guardado exitosamente.")
            except Exception as e:
                messagebox.showerror("Error", f"No se pudo guardar el archivo:\n{str(e)}")

if __name__ == "__main__":
    root = tk.Tk()
    app = PixelArtSerialApp(root)
    root.mainloop()