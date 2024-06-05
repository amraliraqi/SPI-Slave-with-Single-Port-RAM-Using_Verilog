`timescale 1ns/1ps
module spi_tb #(parameter MEM_DEPTH=256, ADDR_SIZE=8) ();
	reg MOSI, SS_n, clk, rst_n;
	wire MISO;
	spi #(MEM_DEPTH, ADDR_SIZE) spi (MOSI, SS_n, clk, rst_n, MISO);
	
	initial begin
		clk=0;
		forever #10 clk=~clk;
	end

	initial begin
		rst_n=0;
		@(negedge clk);
		rst_n=1;
		#1 $readmemh ("RAM.txt", spi.spi_ram.RAM);
		SS_n=1;
		@(negedge clk);
		SS_n=0;
		@(negedge clk);
		MOSI=0;
		@(negedge clk);
		MOSI=0;
		@(negedge clk);
		MOSI=0;
		repeat(8) begin
			MOSI=$random;
			@(negedge clk);
		end
		SS_n=1;
		@(negedge clk);
		SS_n=0;
		@(negedge clk);
		MOSI=0;
		@(negedge clk);
		MOSI=0;
		@(negedge clk);
		MOSI=1;
		repeat(8) begin
			MOSI=$random;
			@(negedge clk);
		end
		SS_n=1;
		@(negedge clk);
		SS_n=0;
		@(negedge clk);
		MOSI=1;
		@(negedge clk);
		MOSI=0;
		repeat(8) begin
			MOSI=$random;
			@(negedge clk);
		end
		repeat(2) @(negedge clk);
		MOSI=1;
		@(negedge clk);
		MOSI=1;
		@(negedge clk);
		MOSI=1;
		@(negedge clk);
		MOSI=1;
		@(negedge clk);
		repeat(8) begin
			MOSI=$random;
			@(negedge clk);
		end
		repeat(10) @(negedge clk);
		$stop;
	end
endmodule
