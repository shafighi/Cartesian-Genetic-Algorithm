`timescale 1ns/1ns

module fitFSM(CLOCK_50,reset,state_controller,fitness,fitnessReady,state_fitFSM,fitCounter);//seed sefr nabashe
/*
This state machine control the process of generating fitness of the genes, 
but I removed it from the functions because evaluation function could do its job by its self.

*/
parameter geneBit = 80;
parameter geneResultBit = 2;
parameter population = 24;
parameter maxSupport = 128;
parameter primaryInputCount = 8;
parameter fitness_controller = 2'b01;

parameter initial_fitFSM = 3'b000,
			gene_fitFSM = 3'b001,
			fitCheck_fitFSM = 3'b010,
			fitCounter_fitFSM = 3'b011,
			finished_fitFSM = 3'b100,
			geneFound_fitFSM = 3'b101;

  input CLOCK_50,reset;
  input [2:0]state_controller;
  input [primaryInputCount+1:0]fitness;
  input fitnessReady;
  //output reg geneIsReady;
	//output reg fitnessFinished;
	output reg [2:0]state_fitFSM;
	//output reg [maxSupport-1:0]dataOut;
	//output reg geneFound;
	output reg [7:0]fitCounter;
	
	//reg fitnessChecked;
	
	//reg firstTurn;
	integer popIndex;
	//reg write; 
	//reg [geneBit-1:0]geneFound;
	
	reg start_fit,rw_fit;
  reg [19:0]address_fit;
	
  
  
 always@(posedge CLOCK_50)begin//fitnessFSM
    if(reset)begin
		state_fitFSM <= initial_fitFSM;
		//fitnessFinished <= 0;
		//geneFound <= 0;
		address_fit<=20'd0;
		start_fit<=1'b0;
		rw_fit<=1'b0;
		fitCounter <= 8'd0;
		//firstTurn<=1;
		//geneIsReady<=0;
		//write<=0;
		//LEDR<=0;
		//geneFound <= 0;

	 end else if(state_controller==fitness_controller)begin 
		
			case(state_fitFSM)
			
			initial_fitFSM : ///nemikhad
				begin	
					state_fitFSM <= gene_fitFSM;
				end
			

					
			fitCheck_fitFSM : 
				if(fitnessReady) begin
				  //geneIsReady<=0;
					//fitnessChecked<=1;
					if(fitness==geneResultBit)begin
					     state_fitFSM <= geneFound_fitFSM;

				   end else
					 state_fitFSM <= fitCounter_fitFSM;
				end
			
			fitCounter_fitFSM :
				begin
					fitCounter <= fitCounter + 8'd1;
					state_fitFSM <= gene_fitFSM;
				end
			finished_fitFSM :
			begin
			end
			geneFound_fitFSM :
			begin
			end
				
		default: 
		begin
		end
		endcase
		end else begin//if
			//fitnessFinished <= 0;
			state_fitFSM <= initial_fitFSM;
		end
		end//always
		
		
		endmodule