# UART vs SPI: RTL-to-GDSII Comparative ASIC Design

A comparative physical design study of two classic serial communication protocols — **UART** (asynchronous) and **SPI** (synchronous) — taken from RTL all the way to manufacturable GDSII layout using an open-source ASIC toolchain.

## Toolchain
- **Yosys** — logic synthesis
- **OpenROAD** — floorplanning, placement, CTS, routing
- **Magic / KLayout** — layout viewing, DRC/LVS verification
- **SkyWater 130nm (SKY130A)** — open-source PDK
- **OpenLane** — flow orchestration
- Run via **GitHub Codespaces** (Docker-based cloud dev environment)

## Designs
- `uart_tx/` — UART transmitter (8-bit data, start/stop bit framing)
- `uart_rx/` — UART receiver
- `spi_master/` — SPI Master (Mode 0, single slave)

## Results

| Metric | UART TX | UART RX | UART Total | SPI Master |
|---|---|---|---|---|
| Synthesized cells | 142 | 160 | 302 | 147 |
| Critical path delay | 1.34 ns | 1.09 ns | — | 1.25 ns |
| Setup/Hold violations | 0 | 0 | 0 | 0 |
| DRC violations | 0 | 0 | 0 | 0 |
| LVS errors | 0 | 0 | 0 | 0 |
| Internal power | 0.202 nW | 0.171 nW | 0.373 nW | 0.213 nW |

## Key Finding

UART requires ~2x more logic than SPI (302 combined cells vs 147) because asynchronous communication demands independent baud-rate generation and framing state machines on both TX and RX sides. SPI's synchronous design shares a single external clock, needing only a shift register and simple clock divider — trading protocol simplicity for the extra wiring (CS, SCLK) and reduced device flexibility of a synchronous bus.

Both designs passed DRC and LVS cleanly, confirming manufacturability under the SKY130 process.

## Repository structure
git add README.md
git commit -m "Add project README"
git push origin main



