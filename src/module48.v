module module48 (clock, reset, enableclk, LEFTin, RIGHTin, LEFTout, RIGHTout, Ks, Kd);
	
	parameter NBITS = 18;
	parameter K_NBITS = 4;
	
	input clock;
	input reset;
	input enableclk;
	input signed [ (NBITS-1) : 0 ] LEFTin;
	input signed [ (NBITS-1) : 0 ] RIGHTin;
	input [ (K_NBITS-1) : 0 ] Kd;
	input [ (K_NBITS-1) : 0 ] Ks;
	    
	output signed [ (NBITS-1) : 0 ] LEFTout;
	output signed [ (NBITS-1) : 0 ] RIGHTout;
	
	wire signed [ (NBITS+4) : 0 ] Kdout;
	wire signed [ (NBITS+4) : 0 ] Ksout;
	
	wire signed [ (NBITS) : 0 ] LpR;	//Changed to 19bits to prevent overflow
	wire signed [ (NBITS) : 0 ] LmR;	//Changed to 19bits to prevent overflow
		
	reg [10:0] state;							//11 bits to represent decimal numbers 0 to 2^11 = 2047
	reg start;
	
	assign	LpR = LEFTin + RIGHTin;	

	assign	LmR = LEFTin - RIGHTin;	
	

	
	
	always @(posedge clock)
	if (reset)
		state <= 11'd0;
	else
	begin
		case (state)
			11'd0: if ( enableclk )
				state <= 11'd1;
			11'd10:	begin 						//start is set to 1
					start <=1;
					state <= state + 11'd1;
					end
			11'd11:	begin						//start is set to 0 after one clock cycle 
					start <= 0;
					state <= state + 11'd1;
					end
			default: if ( state == 11'd2047 )	//posedge enableclk at every 2048 clock cycles
					state <= 11'd0;
					else
				state <= state + 11'd1;
	endcase
	end
	
	seqmultNM 
		#(
			.M(NBITS),
			.N(K_NBITS+1)
		)
		
		seqmultNM_1 

		(
			.clock(clock), 
			.reset(reset), 
			.start(start), 
			.ready(), 
			.A(LpR[18:1]), 						// Multiplicand,  M bits
			.B($signed({1'b0,Ks})),			// Multiplier,    N+1 bits 
			.R(Ksout)
		);
		
	seqmultNM
		#(
			.M(NBITS),
			.N(K_NBITS+1)
		)
		seqmultNM_2 
		(
			.clock(clock), 
			.reset(reset), 
			.start(start), 
			.ready(), 
			.A(LmR[18:1]), 						// Multiplicand,  M bits
			.B($signed({1'b0,Kd})),			// Multiplier,    N+1 bits 
			.R(Kdout)
		);
	
	assign LEFTout = $signed(Ksout[(NBITS+K_NBITS)-2:3]);	//Supposedly there is saturation
	assign RIGHTout = $signed(Kdout[(NBITS+K_NBITS)-2:3]);	//Supposedly there is saturation
	
endmodule