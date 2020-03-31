module module192 (clock, reset, enableclk, LEFTin, RIGHTin, FMout, Kp, Kf);
	
	parameter IN_NBITS = 18;
	parameter SINWAVE_NBITS = 8;
	parameter KF_NBITS = 8;
	parameter KP_NBITS = 4;
	parameter RxSW38_NBITS = 26;
	parameter SW19xKP_NBITS = 12;
	parameter SUMALL_NBITS = 20;
	parameter OUT_NBITS = 24;
	
	input clock;
	input reset;
	input enableclk;
	
	input signed [ (IN_NBITS-1) : 0 ] LEFTin;
	input signed[ (IN_NBITS-1) : 0 ] RIGHTin;
	input [ (KF_NBITS-1) : 0 ] Kf;
	input [ (KP_NBITS-1) : 0 ] Kp;
	output reg signed [ (OUT_NBITS-1) : 0 ] FMout;
	
	reg signed [ (OUT_NBITS-1) : 0 ] outreg;
			
	wire signed [ (OUT_NBITS+5)-1 : 0 ] Kfout; // 20+8+1 = 29bits
	
	wire signed [ (SUMALL_NBITS-1) : 0 ] sumAll;
		
	wire signed [ SW19xKP_NBITS : 0 ] sw19xkpout;	// 8+4+1 = 13bits
	
	wire signed [ (RxSW38_NBITS-1) : 0 ] rxsw38out;
	
	wire signed [ 31 : 0 ] sin19;
	wire signed [ 31 : 0 ] sin38;
	
	
	parameter  phaseinc19 = 32'b0000110_010101010101;
	parameter  phaseinc38 = 32'b0001100_101010101010;
	

	reg [8:0] state;
	reg start_192k1;
	reg start_192k2;
		
		
	always @(posedge clock)
		if (reset)
		state <= 9'd0;
		else
		begin
			case (state)
				9'd0: if ( enableclk )
						state <= 9'd1;
				9'd10:	begin 					//start set to high for 1 clock cycle
						start_192k1<=1;
						state <= state + 9'd1;
						end
				9'd11:	begin 
						start_192k1<=0;
						state <= state + 9'd1;
						end
				9'd40:	begin 					//start set to high for 1 clock cycle
						start_192k2<=1;
						state <= state + 9'd1;
						end
				9'd41:	begin 
						start_192k2<=0;
						state <= state + 9'd1;
						end
				default: if ( state == 9'd511 ) //posedge enableclk at every 512 clock cycles
						state <= 9'd0;
						else
						state <= state + 9'd1;
		endcase
		end
	
	
	
	always @(posedge clock)
		begin
		if (enableclk)
				FMout <= Kfout[ (OUT_NBITS+5)-2 : 4 ];
		else if(reset)
				FMout <= 0;
		end
		
		
	seqmultNM #(
				.M(SUMALL_NBITS),
				.N(KF_NBITS+1)
				)
				kfMux
				(
				.clock(clock),
				.reset(reset),
				.start(start_192k2),
				.ready(),
				.A(sumAll), //Mbits
				.B($signed({1'b0,Kf})), //Nbits
				.R(Kfout)
				);
	

	
	assign sumAll = LEFTin + $signed({sw19xkpout, 6'b0}) + $signed(rxsw38out[RxSW38_NBITS-1:8]);  //26-18 = 8
	
	seqmultNM #(
				.M(SINWAVE_NBITS),
				.N(KP_NBITS+1)
				)
				sw19xkpMux
				(
				.clock(clock),
				.reset(reset),
				.start(start_192k1),
				.ready(),
				.A(sin19[SINWAVE_NBITS-1:0]), //Mbits
				.B($signed({1'b0,Kp})), //Nbits
				.R(sw19xkpout)
				);

	seqmultNM #(
				.M(IN_NBITS),
				.N(SINWAVE_NBITS)	//was +1 before
				)
				rxsw38Mux
				(
				.clock(clock),
				.reset(reset),
				.start(start_192k1),
				.ready(),
				.A(RIGHTin), //Mbits
				.B($signed(sin38[SINWAVE_NBITS-1:0])), //Nbits	was $signed({1'b0,RIGHTin}) before
				.R(rxsw38out)
				);
				  
	dds #(
		  .M(18),
		  .N(6),
		  .FILE("../simdata/DDSLUT19K.hex")
		  )
		   sin19generator
		  (
		   .clock(clock), 
		   .reset(reset), 
		   .enableclk(enableclk),
		   .phaseinc(phaseinc19), 
		   .outsine(sin19) // M-N=12, (N=6) => M = 18; 
		   );

	dds #(
		  .M(18),
		  .N(6),
		  .FILE("../simdata/DDSLUT38K.hex")
		  
		  )
		   sin38generator
		  (
		   .clock(clock), 
		   .reset(reset), 
		   .enableclk(enableclk), 
		   .phaseinc(phaseinc38), 
		   .outsine(sin38) // M-N=12, (N=6) => M = 18; 
		   );

endmodule
