# [FEUP][MIEEC][PSDi] All Digital FM Stereo Modulator

This project consists of an all-digital FM Stereo Modulator described in Verilog. This Verilog module was designed, by Diogo Correia (@PeachBug) and Pedro Augusto (@PetrusAugustus), to be used with a testbench developed by the professor José Carlos Alves (jca@fe.up.pt) for the course of Digital Systems Design (EEC0055) of the Master in Electrical and Computers Engineering at Faculty of Engineering of University of Porto. Unfortunatly certain modules of the project, such as the signed multiplier and the 4X linear interpolator, were developed the professor José Carlos Alves and it's Verilog code is proprietary of University of Porto. To prevent any kind of copyright infringement, only the Verilog modules developed by us (the students) will be available on this repository. For a better understanding of these IP Blocks, look into [IP Blocks](https://github.com/PeachBug/digital-fm-stereo-modulator#submodules).
This module was designed to receive a stereo digital audio signal and generate the multiplexed FM-stereo signal carried on a 5 MHz sinusoidal signal, sampled at 160 MHz. Note that the module's output signal must then be converted to an analog signal, externally, before being transmitted.

## Submodules
  
<img src="https://i.imgur.com/pDWtRxY.png" height="300">

  * stereo_fm_mx - Top-level module
  * module48 - Module containing circuitry that works with the signal sampled at 48MHz
  * module192 - Module containing circuitry that works with the signal sampled at 192MHz
  * dds - The Direct Digital Synthesizer is a digital calculator of the cos(x) function

## IP Blocks
### seqmultNM
Performs the signed multiplication A x B using the sequential shift-add algorithm.
```
module seqmultNM(
					clock,
					reset,
					start, // Set start=1 during one clock cycle to start the multiplication
					ready, // Set to 1 when the multiplier is ready to accept a new start
					A,     // Multiplicand,  M bits
					B,     // Multiplier,    N bits
					R      // Result: A x B, M+N bits
					);
```

### interpol4x
Outputs a linear interpolated signal applied at input, with a sampling frequency equal to 4X the frequency of the input data.
```
module interpol4x
         ( input         clock,        // Master clock
           input         reset,        // Master synchronous reset, active high
		   input         clkenin,      // clock enable for input data (Fs)
		   input         clken4x,      // 4 x input Fs clock enable
		   
           input  signed [17:0] xkin,      // input signal
		   output reg signed [17:0] ykout  // output signal
		 );
```
