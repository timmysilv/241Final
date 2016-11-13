`timescale 1ns/1ns

module topModule(CLOCK_50,SW,KEY,VGA_CLK,VGA_HS,VGA_VS,VGA_BLANK_N,VGA_SYNC_N,VGA_R,VGA_G,VGA_B);
	input			   CLOCK_50;
	input 	[9:0] SW;
	input 	[3:0] KEY;
	output			VGA_CLK;
	output			VGA_HS;	
	output			VGA_VS;
	output			VGA_BLANK_N;
	output			VGA_SYNC_N;
	output	[9:0]	VGA_R;
	output	[9:0]	VGA_G;
	output	[9:0]	VGA_B; 
	
	wire [9:0] xAddr; //These are for the screenReg ram1024x9
	wire [8:0] yIn, yOut;
	wire yWren;
	
	wire [9:0] x;
	wire [8:0] y;
	wire [5:0] frame;
	wire reset,clk5sec;
	
	//test
	
	assign reset = SW[9];
	
	clocks clks(CLOCK_50, reset, frame, clk5sec);
	ram1024x9 screenReg(xAddr, CLOCK_50, yIn, yWren, yOut);
	shiftScreen shift(frame,yWren,xAddr,yIn);
	
	/*vga_adapter VGA(
		.resetn(reset),
		.clock(CLOCK_50),
		.colour(colour),
		.x(x),
		.y(y),
		.plot(writeEn),
		.VGA_R(VGA_R),
		.VGA_G(VGA_G),
		.VGA_B(VGA_B),
		.VGA_HS(VGA_HS),
		.VGA_VS(VGA_VS),
		.VGA_BLANK(VGA_BLANK_N),
		.VGA_SYNC(VGA_SYNC_N),
		.VGA_CLK(VGA_CLK));
	defparam VGA.RESOLUTION = "160x120";
	defparam VGA.MONOCHROME = "FALSE";
	defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
	defparam VGA.BACKGROUND_IMAGE = "black.mif";*/

endmodule

module blackWipe(
	input clock,reset,
	output reg blkEn,
	output [7:0] xt,
	output [6:0] yt
	);
	
	reg [14:0] addr;
	
	always@(posedge clock) begin
		if(!reset) begin
			addr <= 15'd0;
			blkEn <= 1'b1;
		end
		else if(addr<15'd19200) addr <= addr+15'd1;
		if(addr==15'd19200) begin
			addr <= 15'd0;
			blkEn <= 1'b0;
		end
	end
	
	assign xt = addr[14:7];
	assign yt = addr[6:0];
endmodule

module shiftScreen(clk60,write,xAddr,yReg);
	input clk60;
	output reg write;
	output reg [9:0] xAddr;
	output reg [8:0] yReg;
	
	reg [8:0] yPrev, yCur;
	
	always@(posedge clk60) begin
		write = 1'b1;
		for(xAddr = 10'd1023; xAddr > 10'd0; xAddr = xAddr - 1'b1) begin
			yCur = yReg; //Store current value
			yReg = yPrev; //Change current to previous
			if(xAddr == 10'd1023) yPrev = 9'd0; //Change 9'd0 to PRNG output
			else yPrev = yCur; //yPrev will be used on next iteration
		end
		xAddr = 10'd0; //Can't loop until 0 inclusive, get a compiler error
		yReg = yPrev;
		write = 1'b0;
	end
endmodule
