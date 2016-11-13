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
	
	wire [9:0] xAddr; //These 3 are for the screenReg ram1024x9
	wire [8:0] yWrite, yOut;
	
	wire [5:0] frame;
	wire reset,yWren,clk5sec;
	
	clocks clks(CLOCK_50, reset, frame, clk5sec);
	
	//Will make when initial .mif is written
	//ram1024x9 screenReg(xAddr, CLOCK_50, yWrite, yWren, yOut);
	
	vga_adapter VGA(
		.resetn(reset),
		.clock(CLOCK_50),
		.colour(colour),
		.x(x),
		.y(y),
		.plot(writeEn|blkEn),
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
	defparam VGA.BACKGROUND_IMAGE = "black.mif";

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