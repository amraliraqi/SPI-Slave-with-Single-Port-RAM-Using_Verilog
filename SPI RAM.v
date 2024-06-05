module spi_ram #(parameter MEM_DEPTH=256, ADDR_SIZE=8)
	(
		input [9:0] din,
		input clk, rst_n,
		input rx_valid,
		output reg [7:0] dout,
		output reg tx_valid
		);

	reg [7:0] internal_address;
	reg [ADDR_SIZE-1:0] RAM [MEM_DEPTH-1:0];

	integer i;
	always@(posedge clk or negedge rst_n)
	  if(!rst_n) begin
	  	dout<=0;
	  	tx_valid<=0;
	   for (i = 0; i < MEM_DEPTH; i=i+1)
	    RAM[i]<=0;
	  end
	  else
	   if(rx_valid && (din[9:8]==2'b00 || din[9:8]==2'b10))
	   	internal_address<=din[7:0];
	   else if(rx_valid && din[9:8]==2'b01)
	   	RAM[internal_address]<=din[7:0];
	   else if(rx_valid && din[9:8]==2'b11) begin
	   	dout<=RAM[internal_address];
	   	tx_valid<=1;
	   end
endmodule : spi_ram	  

`timescale 1ns/1ps
module spi_ram_tb(); 
        reg [9:0] din;
		reg clk, rst_n;
		reg rx_valid;
		wire [7:0] dout;
		wire tx_valid ;
		spi_ram dut (din, clk, rst_n, rx_valid, dout, tx_valid);

		initial begin
			clk=0;
			forever #5 clk=~clk;
		end
		initial begin
			rst_n=0;
			@(negedge clk);
			rst_n=1;
			#1 $readmemh ("RAM.txt", dut.RAM);
			@(negedge clk);
			rx_valid=1;
			din=00_10001011;
			@(negedge clk);
			rx_valid=1;
			din=01_10110110;
			@(negedge clk);
			rx_valid=1;
			din=10_00001111;
			@(negedge clk);
			rx_valid=1;
			din=11_00001111;
			repeat(2) @(negedge clk);
			$stop;
		end
endmodule



