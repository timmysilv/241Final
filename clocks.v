`timescale 1ns/1ns

module clocks(clk, reset, count60,clk5);
	input clk, reset;
	output [5:0] count60;
	output clk5;
	
	count60 frame(clk,reset,count60);
	clk5sec eventClock(clk,reset,clk5);
endmodule

//From 0 to 59, then 20/50mil more ticks at count60=60
module count60(input clk, reset, output [5:0] count60);
	reg [25:0] count;
	
	always@(posedge clk) begin
		if(reset | (count==26'd50000000))
			count <= 26'd0;
		else if(count < 26'd50000000)
			count <= count + 1'b1;
	end

	assign count60 = count / 20'd833333;
endmodule

//clk5 ticks once every 5 seconds
module clk5sec(input clk, reset, output clk5);
	reg [27:0] count;
	always@(posedge clk) begin
		if(reset | count==28'd250000000)
			count <= 28'd0;
		else if(count<28'd250000000)
			count <= count + 1'b1;
	end
	assign clk5 = (count==28'd250000000) ? 1'b1 : 1'b0;
endmodule
