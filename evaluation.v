`timescale 1ns/1ns
module evaluation(clk,reset,functionMemIsReady,gene,geneFuncMem,functionMem,state_controller,fitness,fitCounter,state_evaluationFSM);
  
  /*
This function control the evaluation phase of the genetic algorithm.
This phase has 7 state, initial_evaluationFSM which sets the registers like fitness value and mismatches zero,
			     blockCalculation_evaluationFSM in which we are waiting for completion of the result of the one gene,
				 mismatch_evaluationFSM in which the result will compare with the correct result from the table,
				 shiftMismatches_evaluationFSM in which fitness function will shift for every mismatches which have found,
				 fitnessResult_evaluationFSM in which we have found all mismatches for all verity of inputs for 
											one configuration and have the final result of fitness;
				 geneFound_evaluationFSM in this state we find if the gene is completely correct or not, if it was correct, it will report,
				 finished_evaluationFSM we are here when the evaluation of all genes is completed;
*/
  
  
  parameter geneBit = 110;
  parameter row = 3;
  parameter column = 3;
  parameter selBit = 4;
	parameter funcBit = 3;
	parameter funcCount=8;
	parameter geneResultBit = 2;
	parameter primaryInputCount=8;//tedade voroodi haye momken bara geneBlock
	parameter primaryInputBit=3;
	parameter funcResultBit = 4;
  parameter population = 24;
  parameter maxSupport = 128;
  parameter fitness_controller = 3'b001;
				
	parameter initial_evaluationFSM = 3'b000,
			    blockCalculation_evaluationFSM = 3'b001,
				 mismatch_evaluationFSM = 3'b010,
				 shiftMismatches_evaluationFSM = 3'b011,
				 fitnessResult_evaluationFSM = 3'b100,
				 geneFound_evaluationFSM=3'b101,
				 finished_evaluationFSM = 3'b110;
				 
  parameter initial_geneBlockFSM = 2'b00,
            geneIsReady_geneBlockFSM = 2'b01,
            waitForResult_geneBlockFSM = 2'b10,
            finished_geneBlockFSM = 2'b11;
	
  input clk,reset,functionMemIsReady;
  input [geneBit-1:0]gene;
  input [primaryInputCount*geneResultBit-1:0]geneFuncMem;
  input [funcCount*funcResultBit-1:0]functionMem;
  input [2:0]state_controller;
  output reg [primaryInputCount+1:0]fitness;
  output reg [7:0]fitCounter;
  output reg[2:0]state_evaluationFSM;
  //output [7:0]fitnessFinished;
  //output geneFound;
 // output reg fitnessReady;

  
  integer geneResultBitIndex,primaryInputIndex;
  reg [7:0]geneResultBitCounter;
  //reg [2:0]state_evaluationFSM;
  wire [geneBit+primaryInputBit-1:0]geneIn;
  reg [primaryInputCount+1:0]genesFitness[geneResultBit-1:0];  
  wire [geneResultBit-1:0]geneResult;
  wire blockResultIsReady;
  reg [geneResultBit-1:0]mismatch;
  reg [geneResultBit-1:0]geneFunc [primaryInputCount-1:0];  
  reg [primaryInputBit:0]inputGeneCounter;//primaryInputBit
  reg geneInputIsReady;
  reg fitnessReady;
  wire [1:0]state_geneBlockFSM;
  
  
  geneBlock #(geneBit+primaryInputBit,row,column,selBit,funcBit,funcCount,geneResultBit,primaryInputBit,funcResultBit,fitness_controller,initial_geneBlockFSM,geneIsReady_geneBlockFSM,waitForResult_geneBlockFSM,finished_geneBlockFSM)gb(clk,~functionMemIsReady,geneInputIsReady,geneIn,functionMem,state_controller,geneResult,blockResultIsReady,state_geneBlockFSM);
  
  assign geneIn = {inputGeneCounter[primaryInputBit-1:0],gene};
  
  always@(posedge clk)begin
    if(reset)begin
      geneInputIsReady<=0;
    end else begin
      if(state_evaluationFSM==shiftMismatches_evaluationFSM || state_evaluationFSM==initial_evaluationFSM )begin
        geneInputIsReady<=1;
      end else begin
        geneInputIsReady<=0;
      end
    end
  end
  
  
  always@(posedge clk) begin
  	 if(reset)begin

		    state_evaluationFSM <= initial_evaluationFSM;
				fitnessReady<=0;
				geneResultBitCounter<=0;
				inputGeneCounter<=0;
				fitness<=0;
				mismatch<=0;
				fitCounter<=0; 
				//geneInputIsReady <=0;
	 end else if(state_controller==fitness_controller )begin
	
		case(state_evaluationFSM)
		
			initial_evaluationFSM : 
			begin
			  if(state_geneBlockFSM==geneIsReady_geneBlockFSM)begin
				//columnCounter<=0;
				fitnessReady<=0;
				geneResultBitCounter<=0;
				inputGeneCounter<=0;
				fitness<=0;
				fitCounter<=0;  
      		for(primaryInputIndex=0;primaryInputIndex<primaryInputCount;primaryInputIndex=primaryInputIndex+1)begin
			     geneFunc[primaryInputIndex]<=geneFuncMem[primaryInputIndex*geneResultBit +: geneResultBit];
		    end 
				for(geneResultBitIndex=0;geneResultBitIndex<geneResultBit;geneResultBitIndex=geneResultBitIndex+1)begin
					genesFitness[geneResultBitIndex]<=1;
				end
				state_evaluationFSM <= blockCalculation_evaluationFSM;
				end
				//geneInputIsReady <= 1;
			end
			
			blockCalculation_evaluationFSM :
			begin
			  //geneInputIsReady <=0;

			  if(fitCounter>=population)begin
			    state_evaluationFSM <= finished_evaluationFSM;
			  end else 
				if(inputGeneCounter>=primaryInputCount)begin
					state_evaluationFSM <= fitnessResult_evaluationFSM;
				end else            
				if(blockResultIsReady)begin
						state_evaluationFSM <= mismatch_evaluationFSM;					
				end
        if(inputGeneCounter==0)begin
				  fitness<=0;
				  for(geneResultBitIndex=0;geneResultBitIndex<geneResultBit;geneResultBitIndex=geneResultBitIndex+1)begin
					   genesFitness[geneResultBitIndex]<=1;
				  end
			  end
			end
			mismatch_evaluationFSM :
			begin
				mismatch = geneFunc[inputGeneCounter] ^ geneResult;	
				state_evaluationFSM <= shiftMismatches_evaluationFSM;
			end
			
			shiftMismatches_evaluationFSM :
			begin
				//columnCounter<=0;
				//geneInputIsReady <=1;
				inputGeneCounter<=inputGeneCounter+1;
				for(geneResultBitIndex=0;geneResultBitIndex<geneResultBit;geneResultBitIndex=geneResultBitIndex+1)begin
					if(mismatch[geneResultBitIndex]==1)begin
						genesFitness[geneResultBitIndex]<=genesFitness[geneResultBitIndex]<<1;
					end
			   end
				state_evaluationFSM <= blockCalculation_evaluationFSM;			
			end
  
			fitnessResult_evaluationFSM :
			begin
           if(geneResultBitCounter<geneResultBit)begin
               fitness <= genesFitness[geneResultBitCounter]+fitness;
               geneResultBitCounter <= geneResultBitCounter+1;
			     end else begin
					    fitnessReady<=1;			 	    
				 	    fitCounter<=fitCounter+1;
				 	    inputGeneCounter<=0;
				      geneResultBitCounter<=0;
				 	    if(fitness==geneResultBit)begin
				 	      state_evaluationFSM<=geneFound_evaluationFSM;
				 	    end else 
				 	      state_evaluationFSM <= blockCalculation_evaluationFSM;
			     end
			end
			
			geneFound_evaluationFSM: 
			begin
			end
			  
			finished_evaluationFSM : 
			begin
			 state_evaluationFSM<= initial_evaluationFSM;
			end
			
		endcase
	 end
  end//always 

endmodule
