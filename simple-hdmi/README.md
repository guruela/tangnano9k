# simple-hdmi

Displays a solid blue 640×480 image at 60 Hz over HDMI.
The design uses the board's 27 MHz oscillator, Gowin clock IP, TMDS encoders,
and the FPGA's high-speed serializer and differential output cells.

## Files

| File | Purpose |
| ---- | ------- |
| `top.v` | Video timing, blue pixel values, and HDMI output connections |
| `tmds_encoder.v` | TMDS data and control-period encoder |
| `ip/pixel_clock_pll.v` | Gowin PLL wrapper for the 5× pixel clock |
| `ip/pixel_clock_divider.v` | Gowin divider wrapper for the pixel clock |
| `tangnano9k.cst` | Pin constraints for the Tang Nano 9K |

## Build and flash

Assuming that [oss-cad-suite](https://github.com/YosysHQ/oss-cad-suite-build) toolchain is installed and on your path

```sh
# Synthesize
yosys -p "read_verilog top.v tmds_encoder.v ip/pixel_clock_pll.v ip/pixel_clock_divider.v; synth_gowin -json hdmi.json -top top"

# Place and route
nextpnr-himbaechel --json hdmi.json --write pnr-hdmi.json --device GW1NR-LV9QN88PC6/I5 --vopt family=GW1N-9C --vopt cst=tangnano9k.cst

# Generate the bitstream
gowin_pack -d GW1N-9C -o pack.fs pnr-hdmi.json

# Flash the Tang Nano 9K
openFPGALoader -b tangnano9k pack.fs
```
