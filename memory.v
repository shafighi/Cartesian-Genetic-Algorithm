`timescale 1ns/1ns
module memory(CLOCK_50,reset,state_controller,dataInput,dataOut,SRAM_ADDRESS_O,SRAM_DATA_IO,SRAM_UB_N_O,SRAM_LB_N_O,SRAM_WE_N_O,SRAM_CE_N_O,SRAM_OE_N_O,state_memFSM);

parameter memory_controller = 3'b101;
parameter dataBit = 32;
parameter initial_memFSM=2'b00,
          write_memFSM=2'b01,
          writeTime_memFSM=2'b10,
          finished_memFSM=2'b11;    
		//output reg done;
		input CLOCK_50,reset;
		input [2:0]state_controller;
		input [dataBit-1:0] dataInput;
		output reg[dataBit-1:0] dataOut;
		output [19:0] SRAM_ADDRESS_O;
		inout   [15:0]SRAM_DATA_IO;
		output  SRAM_UB_N_O;
		output  SRAM_LB_N_O;
		output  SRAM_WE_N_O;
		output  SRAM_CE_N_O;
		output	SRAM_OE_N_O;
		//output reg [17:0]LEDR;	
		output [1:0]state_memFSM; 
		//output memoryFinished;		
			
		reg [dataBit-1:0] dataIn;
		reg [3:0] counter;
		reg [2:0] state;
		reg [19:0]SRAM_address;
		reg [15:0]SRAM_write_data;
		reg SRAM_we_n;
		wire [15:0]SRAM_read_data;
		wire SRAM_ready;
		reg [7:0]parts;//baste be max bit e gene dare
		wire start,rw;
    wire [19:0]address;
    reg done;
    

	  SRAM_Controller SC(CLOCK_50,reset,start,SRAM_address,SRAM_write_data,SRAM_we_n,SRAM_read_data,SRAM_ready,SRAM_ADDRESS_O,SRAM_DATA_IO,SRAM_UB_N_O,SRAM_LB_N_O,SRAM_WE_N_O,SRAM_CE_N_O,SRAM_OE_N_O);
	  memFSM#( memory_controller,initial_memFSM,write_memFSM,writeTime_memFSM,finished_memFSM)memF(CLOCK_50,reset,done,state_controller,start,rw,address,state_memFSM);
	      		    
		always@(posedge CLOCK_50) begin	//100
			if(reset)begin
				 //LEDR<=0;
				 counter<=0;
				 parts<=0;
				 state<=0;
				 done<=0;

			end else begin
				if(start)begin//1
					if(parts<(dataBit/16))begin//parts//
						case(state)
							3'd0: begin	//3
									if(rw==0) begin	//4 read
										SRAM_we_n<=1;
										if(parts==0)begin
										
											SRAM_address<=address*(dataBit/16);
										end else begin
											SRAM_address<=SRAM_address+20'd1;
										end
										//LEDR[15:0]<=address[15:0];
										counter<=0;
										state<=3'd1;
										//LEDR[16]<=1;
									end	//4
									else if (rw==1) begin //5 write
										//LEDR[0]<=1;
										if(parts==0)begin
											dataIn<=dataInput;
											SRAM_address<=address*(dataBit/16);
										end else begin
											SRAM_address<=SRAM_address+20'd1;
										end
										counter<=0;
										state<=3'd2;
									end //5
								end //3
						3'd1:	
							begin //6
								if(counter==4'd2) begin //b
										//LEDR[4:0]<=SRAM_read_data[4:0];
										//LEDR[9:5]<=SRAM_address[4:0];
										dataOut[16*((dataBit/16)-parts-1) +: 16]<=SRAM_read_data;
										
										state<=0;
										counter<=0;
										parts<=parts+8'd1;
										//LEDR[17]<=1;
								end //b
								else if(counter<4'd2)
									counter<=counter+4'd1;
							end //6
						
						
						3'd2: begin //8
							if(counter<4'd2) begin	///e
									//LEDR[4:0]<=SRAM_ADDRESS_O[4:0];
									
									//if(SRAM_ready)
										//LEDR[5]<=1;
								SRAM_we_n<=0;					
								counter<=counter+4'd1;
								//SRAM_write_data<=dataIn[16*((dataBit/16)-parts-1) +: 16];
								SRAM_write_data<=dataIn[16*parts +: 16];
							end  else if( counter==4'd2)begin
								counter<=4'd0;
								state<=0;
								parts<=parts+8'd1;
								end
						end///8
					
					endcase
				end//parts
				else begin
					done<=1;
				end
			end//1
			else if(start==0) begin //2
				//LEDR[12]<=1;
				counter<=0;
				state<=0;
				parts<=0;
				done<=0;
			end //2
		end
	end	//100
						
endmodule