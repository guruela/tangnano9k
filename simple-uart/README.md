# Simple UART

Prints `Hello World!` to a serial monitor over the Tang Nano 9K's on-board
USB-UART bridge (115200 baud, 8N1), repeating about once per second.

## Files

| File | Purpose |
| ---- | ------- |
| `top.v` | Top module: byte sequencer for the message |
| `uart_tx.v` | UART transmitter (8N1) |
| `tangnano9k.cst` | Pin constraints for the Tang Nano 9K |

## Build & flash

Assuming that [oss-cad-suite](https://github.com/YosysHQ/oss-cad-suite-build) toolchain is installed and on your path

```sh
# Synthesize
yosys -p "read_verilog top.v uart_tx.v; synth_gowin -json simple-uart.json -top top"

# Place & Route
nextpnr-himbaechel --json simple-uart.json --write pnr-simple-uart.json --device GW1NR-LV9QN88PC6/I5 --vopt family=GW1N-9C --vopt cst=tangnano9k.cst

# Generate Bitstream
gowin_pack -d GW1N-9C -o pack.fs pnr-simple-uart.json

# Flash
openFPGALoader -b tangnano9k pack.fs
```

## Serial monitor

Find the on-board serial device (usually `/dev/ttyUSB1`) and open it at
115200 baud:

```sh
# Find the serial port
ls /dev/ttyUSB*

# Open the serial monitor
screen /dev/ttyUSB1 115200
# To exit screen, press Control + A and D
```

You should see `Hello World!` printed repeatedly.

> **Note:** You cannot reflash the FPGA while the serial port is open.
