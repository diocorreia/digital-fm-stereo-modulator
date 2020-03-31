module stereo_fm_mx
		(
		input clock,
		input reset,
		input clken48kHz,
		input clken192kHz,
		
		input [3:0] Ks,
		input [3:0] Kd,
		input [3:0] Kp,
		input [7:0] Kf,
		
		input signed [17:0] LEFTin,
		input signed [17:0] RIGHTin,
		
		output signed [23:0] FMout
		);
		
		wire signed [17:0] LEFTout;
		wire signed [17:0] RIGHTout;
		wire signed [17:0] LEFT4xout;
		wire signed [17:0] RIGHT4xout;
		
		module48 module48_1(
							.clock(clock), 
							.reset(reset), 
							.enableclk(clken48kHz), 
							.LEFTin(LEFTin), 
							.RIGHTin(RIGHTin), 
							.LEFTout(LEFTout), 
							.RIGHTout(RIGHTout), 
							.Ks(Ks), 
							.Kd(Kd)				
							);
							
		interpol4x interpolL(
							.clock(clock),
							.reset(reset),
							.clkenin(clken48kHz),
							.clken4x(clken192kHz),
							.xkin(LEFTout),
							.ykout(LEFT4xout)
							);
							
		interpol4x interpolR(
							.clock(clock),
							.reset(reset),
							.clkenin(clken48kHz),
							.clken4x(clken192kHz),
							.xkin(RIGHTout),
							.ykout(RIGHT4xout)
							);		
							
		module192 module192_1(
							.clock(clock),
							.reset(reset),
							.enableclk(clken192kHz),
							.LEFTin(LEFT4xout),
							.RIGHTin(RIGHT4xout),
							.FMout(FMout),
							.Kp(Kp),
							.Kf(Kf)
							);

endmodule