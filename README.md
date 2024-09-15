# VHDLscope

Simple two channel oscilloscope and one/two channel signal generator 
implemented on FPGA. Signals will be displayed on VGA display.
Everything will be controlled with Linux kernel driver

## Table of contents
* [Description](#description)
* [Used hardware](#hardware)
* [Project log](#project-log)

## Description


## Hardware

For now used hardware will be:
* STM32MP157C-DK2 dev board
* Spartan 3A FPGA board
* SPI ADC [ADS7039-Q1](https://www.ti.com/lit/ds/symlink/ads7039-q1.pdf?ts=1725532616748), 10 bits, 2 MSPS
* I2C DAC [MCP4726](https://ww1.microchip.com/downloads/aemDocuments/documents/OTH/ProductDocuments/DataSheets/22272C.pdf), 12 bits


## Project log


### First hardware tests 15.09.2024
As for state of commit [39cd0e9](https://github.com/ProgramistaPrzemyslaw/VHDLscope/tree/39cd0e9d96a3326c4b62f5e5184d7a80b6aa69e5)
project is working. SPI communication between STM and FPGA works correctly.

Test command sent from STM board to FPGA is seen on [image below](#image-1.-data-sent-from-stm32mp157-mpu.), it
consisted of three 8-bit word of which first was the read command and
two remaining were converted to 16-bit value which contained amount of
samples to be taken from ADC.


![data_img](/imgs/data_from_stm_edit.jpg)
##### Image 1. Data sent from STM32MP157 MPU.

In this case it were 4 samples taken, which you can also clearly see on the [image below](#image-2.-command-and-4-cs-activations-seqence.). It is indicated by 4 CS pin activation seen on 3rd channel.
Unfortunately on this image, command is unreadable, but the closeup can be observed 
on this [image](#image-1.-data-sent-from-stm32mp157-mpu.).

![seq_img](/imgs/sequence.jpg)
##### Image 2. Command and 4 CS activations seqence.

As for now i do not have board with ADCs and DACs, so full hardware tests must wait.