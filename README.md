# VHDLscope

Simple two channel oscilloscope and one/two channel signal generator 
implemented on FPGA. Signals will be displayed on VGA display.

## Hardware

For now used hardware will be:
* Spartan 3A FPGA board
* SPI ADC [ADS7039-Q1](https://www.ti.com/lit/ds/symlink/ads7039-q1.pdf?ts=1725532616748), 10 bits, 2 MSPS
* I2C DAC [MCP4726](https://ww1.microchip.com/downloads/aemDocuments/documents/OTH/ProductDocuments/DataSheets/22272C.pdf), 12 bits
