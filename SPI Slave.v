module spi_slave (
	input MOSI, SS_n, clk, rst_n,
	input [7:0] tx_data,
	input tx_valid,
	output MISO,
	output [9:0] rx_data,
	output rx_valid);

    parameter IDLE=3'b000;
    parameter CHK_CMD=3'b001;
    parameter WRITE=3'b010;
    parameter READ_ADD=3'b011;
    parameter READ_DATA=3'b100;

    reg [2:0] state_current, state_next;
    reg [3:0] counter_rx_current, counter_rx_next;
    reg [2:0] counter_tx_current, counter_tx_next;
    reg [9:0] rx_data_current, rx_data_next; 
    reg rx_valid_current, rx_valid_next;
    reg rd_add_done_current, rd_add_done_next;
    reg MISO_current, MISO_next;

    always@(posedge clk or negedge rst_n) begin
    	if(!rst_n) begin
    		state_current <= IDLE;
    		rx_data_current <= 0;
    		rx_valid_current <=0;
    		counter_rx_current <= 0;
    		counter_tx_current <= 0;
    		rd_add_done_current <= 0;
    		MISO_current <= 0;
    	end
    	else begin
    		state_current <= state_next;
    		rx_data_current <= rx_data_next;
    		rx_valid_current <=rx_valid_next;
    		counter_rx_current <= counter_rx_next;
    		counter_tx_current <= counter_tx_next;
    		rd_add_done_current <= rd_add_done_next;
    		MISO_current<= MISO_next;
        end 
    end

    always@(*) begin
    	case(state_current)
    		IDLE: if(SS_n) begin
    		       state_next=IDLE;
    		       rx_valid_next=0;
    		       counter_rx_next=0;
    		       counter_tx_next=0;
    		      end 
    		      else begin
    		       state_next=CHK_CMD;
    		       rx_valid_next=0;
    		       counter_rx_next=0;
    		       counter_tx_next=0;
    		      end 

    		CHK_CMD: if(!SS_n && !MOSI)
    		          state_next=WRITE;
    		         else if (!SS_n && MOSI && rd_add_done_current) begin
    		          state_next=READ_DATA;
    		          rd_add_done_next=0;
    		         end
    		         else if (!SS_n && MOSI) begin
    		          state_next=READ_ADD;
    		         end
    		         else
    		          state_next=IDLE;

    		WRITE: if(!SS_n && counter_rx_current<10) begin
    		        if(counter_rx_current<9) begin
    		        	state_next=WRITE;
    		            rx_data_next[9-counter_rx_current]=MOSI;
    		            counter_rx_next=counter_rx_current+1;
    		        end
    		        else begin
    		            state_next=IDLE;
    		            rx_data_next[9-counter_rx_current]=MOSI;
    		        	rx_valid_next=1;
    		       end
    		      end 
    		      else 
    		       state_next=IDLE; 

    	READ_ADD: if(!SS_n && counter_rx_current<10) begin
    		        if(counter_rx_current<9) begin
    		         state_next=READ_ADD;
    		         rx_data_next[9-counter_rx_current]=MOSI;
    		         counter_rx_next=counter_rx_current+1;
    		       end
    		       else begin
    		         state_next=IDLE;
    		         rx_data_next[9-counter_rx_current]=MOSI;
    		         rx_valid_next=1;
    		         rd_add_done_next=1;
    		       end
    		      end
    		      else
    		       state_next=IDLE;
    		       

    	READ_DATA: if(!SS_n && counter_rx_current<9) begin
    		        state_next=READ_DATA;
    		        rx_data_next[9-counter_rx_current]=MOSI;
    		        counter_rx_next=counter_rx_current+1;
    		       end
    		       else if(!SS_n && counter_rx_current==9) begin
    		        state_next=READ_DATA;
    		        rx_data_next[9-counter_rx_current]=MOSI;
    		        counter_rx_next=counter_rx_current+1;
    		        rx_valid_next=1;
    		       end  
    		       else if(!SS_n && counter_tx_current<8 && tx_valid) begin
    		        if(counter_tx_current<7) begin
    		         rx_valid_next=0;
    		       	 state_next=READ_DATA;
    		       	 MISO_next=tx_data[8-counter_tx_current];
    		       	 counter_tx_next=counter_tx_current+1;
    		       end
    		       else begin
    		       	 state_next=IDLE;
    		       	 MISO_next=tx_data[8-counter_tx_current];
    		       	 counter_tx_next=counter_tx_current+1;
    		       end
    		      end 
    		      else begin
    		         state_next=READ_DATA;
    		         rx_valid_next=0;
    		      end                    
    		endcase                    
    end

    assign rx_data=rx_data_current;
    assign rx_valid=rx_valid_current;
    assign  MISO= MISO_current;

endmodule : spi_slave  

`timescale 1ns/1ps
module spi_slave_tb();
	reg MOSI, SS_n, clk, rst_n;
	reg [7:0] tx_data;
	reg tx_valid;
	wire MISO;
	wire [9:0] rx_data;
	wire rx_valid;
	spi_slave dut (MOSI, SS_n, clk, rst_n, tx_data, tx_valid, MISO, rx_data, rx_valid);

	initial begin
		clk=0;
		forever #5 clk=~clk;
	end

	initial begin
		rst_n=0;
		repeat(2) @(negedge clk);
		rst_n=1;
		#1;
		SS_n=1;
		@(negedge clk);
		SS_n=0;
		MOSI=0;
		@(negedge clk);
		repeat(11) begin
			MOSI=$random;
			@(negedge clk);
		end
		SS_n=1;
		repeat(2) @(negedge clk);

		SS_n=0;
		MOSI=1;
		@(negedge clk);
		repeat(11) begin
			MOSI=$random;
			@(negedge clk);
		end
		SS_n=1;
		repeat(2) @(negedge clk);
		

		tx_data=8'b10101010;
		tx_valid=1;
		SS_n=0;
		MOSI=1;
		repeat(2) @(negedge clk);
		repeat(11) begin
			MOSI=$random;
			@(negedge clk);
		end
		repeat(9) begin
			@(negedge clk);
		end
		SS_n=1;
		repeat(2) @(negedge clk);
		$stop;
	end
endmodule



