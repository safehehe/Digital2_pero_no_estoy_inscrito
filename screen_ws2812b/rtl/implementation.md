# Screen Implementation

## Port Naming Convention

All module ports MUST use `in_` or `out_` prefixes, **except** for `sys_clk` and `rst_n`. See AGENTS.md for full specification.

| Direction | Prefix | Example |
|-----------|--------|---------|
| Clock/Reset | (none) | `sys_clk`, `rst_n` |
| Input | `in_` | `in_pixel_addr` |
| Output | `out_` | `out_data_out` |

## Overview

Driver for 16x16 WS2812B LED matrix (256 LEDs, 24-bit GRB color each, 800 kHz).

## Block Diagram

```
                              ┌─────────────────────────────────────────────────────┐
                              │                  screen_controller                 │
pixel_addr ─────────┐         │  ┌──────────────┐    ┌───────────────┐           │
                    │         │  │ frame_buffer │───▶│shift_register │──┐        │
pixel_color ────────┼────────▶│  └──────────────┘    └───────────────┘  │        │
                    │         │         ▲                    ▲             │        │
pixel_we ───────────┘         │         │                    │             ▼        │
                              │  ┌──────┴────────────────────┴──────────────┐     │
                              │  │                   screen_fsm             │     │
                              │  └──────────────────────────────────────────┘     │
                              │                              ▼                    │
                              │                      ┌───────────────┐            │
                              │                      │pulse_generator│            │
                              │                      └───────────────┘            │
sys_clk, rst_n ───────────────┼────────────────────────────────────────────────────┼──▶ data_out
                              └─────────────────────────────────────────────────────┘
```

## System Parameters

| Parameter | Value | Description |
|-----------|-------|-------------|
| LED_COUNT | 256 | Number of LEDs |
| COLOR_BITS | 24 | Bits per LED (GRB) |
| WS2812_T0H | 400 ns | Zero bit high pulse |
| WS2812_T1H | 850 ns | One bit high pulse |
| WS2812_PERIOD | 1250 ns | 800 kHz signaling |
| RESET_PULSE | 50000 ns | >50 us low pulse |
| CLK_FREQ_MHZ | 25 | System clock frequency |

## Modules

### 1. screen_controller (`screen_controller.v`)

Top-level module connecting all sub-modules.

| Signal | Dir | Bits | Description |
|--------|-----|------|-------------|
| sys_clk | in | 1 | System clock (25 MHz) |
| rst_n | in | 1 | Active-low reset |
| in_pixel_addr | in | 8 | LED address (0-255) |
| in_pixel_color | in | 24 | GRB color data |
| in_pixel_we | in | 1 | Write enable |
| out_data_out | out | 1 | Serial data to WS2812B |

**Internal signals:** fb_read_addr, fb_read_enable, fb_color_out, shift_load, shift_shift, shift_data_out, pulse_start, pulse_send_reset, pulse_high_done, pulse_reset_done, pulse_done

---

### 2. frame_buffer (`frame_buffer/frame_buffer.v`)

Dual-port RAM for storing LED colors (256 x 24-bit).

| Signal | Dir | Bits | Description |
|--------|-----|------|-------------|
| sys_clk | in | 1 | Clock |
| rst_n | in | 1 | Active-low reset |
| in_write_addr | in | 8 | Write address |
| in_write_enable | in | 1 | Write enable |
| in_color_in | in | 24 | Color to write |
| in_read_addr | in | 8 | Read address |
| in_read_enable | in | 1 | Read enable |
| out_color_out | out | 24 | Color read |

---

### 3. shift_register (`shift_register/shift_register.v`)

24-bit shift register (LSB out first via concatenation, async output).

| Signal | Dir | Bits | Description |
|--------|-----|------|-------------|
| sys_clk | in | 1 | Clock |
| rst_n | in | 1 | Active-low reset |
| in_load | in | 1 | Load data |
| in_data | in | 24 | Parallel data |
| in_shift | in | 1 | Shift right |
| out_data | out | 1 | Serial output (LSB) |

---

### 4. pulse_generator (`pulse_generator/pulse_generator.v`)

Generates WS2812B timing pulses.

| Signal | Dir | Bits | Description |
|--------|-----|------|-------------|
| sys_clk | in | 1 | Clock |
| rst_n | in | 1 | Active-low reset |
| in_start | in | 1 | Start pulse |
| in_bit_in | in | 1 | Bit value (0/1) |
| in_send_reset | in | 1 | Trigger reset |
| out_pulse_out | out | 1 | Pulse output |
| out_high_done | out | 1 | High phase done |
| out_reset_done | out | 1 | Reset done |
| out_pulse_done | out | 1 | Pulse complete |

**States:** IDLE (0) → HIGH_PHASE (1) → LOW_PHASE (2) → DONE (4)
           └──────────────────→ RESET_PHASE (3) ──────────────────┘

---

### 5. screen_fsm (`screen_fsm/screen_fsm.v`)

Controls frame buffer reading and data transmission.

| Signal | Dir | Bits | Description |
|--------|-----|------|-------------|
| sys_clk | in | 1 | Clock |
| rst_n | in | 1 | Active-low reset |
| in_pulse_high_done | in | 1 | Pulse complete |
| in_pulse_reset_done | in | 1 | Reset complete |
| in_pulse_done | in | 1 | All bits complete (from pulse_generator) |
| out_fb_read_addr | out | 8 | Frame buffer address |
| out_fb_read_enable | out | 1 | Frame buffer read enable |
| out_shift_load | out | 1 | Load shift register |
| out_shift_shift | out | 1 | Shift register shift |
| out_pulse_start | out | 1 | Start pulse generator |
| out_pulse_send_reset | out | 1 | Send reset signal |

**States:** START → READ_PIXEL → LOAD_SHIFT → WAIT_HIGH → SHIFT_NEXT → CHECK_BITS → NEXT_PIXEL/SEND_RESET → WAIT_RESET → START

**Internal counters:** pixel_count (0-255), bit_count (0-23)

## WS2812B Timing

| Bit | T High | T Low | Total |
|-----|--------|-------|-------|
| 0 | 400 ns | 850 ns | 1250 ns |
| 1 | 850 ns | 450 ns | 1250 ns |
| Reset | >50 us low | - | - |

Data sent MSB first (GRB[23] first). Reset pulse required after all 256 LEDs.
