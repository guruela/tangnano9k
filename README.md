# Tang Nano 9K Projects

Projects for the [Tang Nano 9K](https://wiki.sipeed.com/hardware/en/tang/tang-nano-9k/nano-9k.html) based on **Gowin GW1NR-9C FPGA**.

## Toolchain

- [oss-cad-suite](https://github.com/YosysHQ/oss-cad-suite-build)

## Toolchain workflow

Every project follows the same four steps:

1. **Synthesis** — `yosys` turns Verilog into a generic netlist
2. **Place & route** — `nextpnr-gowin` maps it to the GW1NR-9C using the board's physical constraints
3. **Packing** — `gowin_pack` produces the bitstream
4. **Flashing** — `openFPGALoader` writes the bitstream to the board

## Projects

| Project | Description |
| ------- | ----------- |
| [blink](blink/) | 6-LED chaser |
| [simple-uart](simple-uart/) | Simple 8N1 UART |

## License

MIT
