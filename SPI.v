module spi #(parameter MEM_DEPTH=256, ADDR_SIZE=8)
	(
		input MOSI, SS_n, clk, rst_n,
		output MISO
		);

	wire [7:0] tx_data;
	wire tx_valid;
	wire [9:0] rx_data;
	wire rx_valid;
	spi_slave spi_slave (MOSI, SS_n, clk, rst_n, tx_data, tx_valid, MISO, rx_data, rx_valid);
	spi_ram #(MEM_DEPTH, ADDR_SIZE) spi_ram (rx_data, clk, rst_n, rx_valid, tx_data, tx_valid);

endmodule : spi	

