# Blink

A 6-LED running pattern driven by the on-board 27 MHz clock and the reset button.

## Files

| File | Purpose |
| ---- | ------- |
| `blink.v` | Verilog design |
| `tangnano9k.cst` | Pin constraints for the Tang Nano 9K |

## Build & flash

Assuming that [oss-cad-suite](https://github.com/YosysHQ/oss-cad-suite) toolchain is installed and on your path

```sh
# Synthesize
yosys -p "read_verilog blink.v; synth_gowin -json blink.json -top led"

# Place & Route
nextpnr-himbaechel --json blink.json --write pnrblink.json --device GW1NR-LV9QN88PC6/I5 --vopt family=GW1N-9C --vopt cst=tangnano9k.cst

# Generate Bitstream
gowin_pack -d GW1N-9C -o pack.fs pnrblink.json

# Flash
openFPGALoader -b tangnano9k pack.fs
```
