module SRAM_Controller(input Clock_50,input Resetn,
						input start,
						input [19:0]SRAM_address,
						input [15:0]SRAM_write_data,
						input SRAM_we_n,
						output reg [15:0]SRAM_read_data,
						output reg SRAM_ready,
						
						//sraaaaam
						output reg[19:0] SRAM_ADDRESS_O,
						inout reg[15:0]SRAM_DATA_IO,
						output reg SRAM_UB_N_O,
						output reg SRAM_LB_N_O,
						output reg SRAM_WE_N_O,
						output reg SRAM_CE_N_O,
						output reg SRAM_OE_N_O
						);
						
					
						
						always@(posedge Clock_50) begin
						
						
						if(Resetn==0) begin	//1
						
						if(start)begin
						SRAM_CE_N_O<=0;
						SRAM_OE_N_O<=0;
						if(SRAM_we_n==0)begin//3		
							SRAM_ADDRESS_O<=SRAM_address;
							SRAM_WE_N_O<=0;					
						SRAM_DATA_IO<=SRAM_write_data;
							SRAM_ready<=1;
						end//3
						
						
						
						else if(SRAM_we_n==1) begin //5
						
						
						SRAM_DATA_IO<=16'bz;
						SRAM_ADDRESS_O<=SRAM_address;
						SRAM_WE_N_O<=1;
						SRAM_read_data<=SRAM_DATA_IO;
						end//5
						
						end
						//end else begin
						//SRAM_CE_N_O<=1;
						//SRAM_OE_N_O<=1;
						//SRAM_WE_N_O<=1;
						//end
						end	//1
						else if (Resetn==1) begin 		//2
				
						SRAM_UB_N_O<=0;
						SRAM_LB_N_O<=0;
						SRAM_WE_N_O<=1;
						SRAM_CE_N_O<=0;
						SRAM_OE_N_O<=0;
						end //2
						
						end
						
endmodule