module dds (clock, reset, enableclk, phaseinc, outsine);

	parameter M = 13;
	parameter N = 7;
	parameter B = 32;
	parameter FILE = "../simdata/DDSLUT.hex";
	parameter NSamplesLUT = 64;
	
	input		clock;
	input		reset;
	input		enableclk;
		
	input		[ 31 : 0 ] phaseinc;
		
	output		reg [ (B-1) : 0 ] outsine;
	
	reg  [ (B-1) : 0 ] sineLUT[ 0 : NSamplesLUT-1 ];
	wire [ (M-1) : 0 ] sum;
	reg  [ (M-1) : 0 ] acum;
	wire [ (M-1) : 0 ] feedback;
	wire [ (N-1) : 0 ] addr;
	
	initial begin
		$readmemh(FILE, sineLUT );
	end
	
	assign sum = phaseinc[(M-1):0] + feedback;
	
	always @(posedge clock)
		if(reset)
			acum <= 1'd0;
		else if(enableclk)
			acum <= sum;
	
	assign feedback = acum;
	assign addr = acum[M-1:(M-N)];

	always @(posedge clock)
		if(reset)
			outsine <= 0;
		else if(enableclk)
			outsine <= sineLUT[addr];
	
endmodule