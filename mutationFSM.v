`timescale 1ns/1ns
module mutationFSM(CLOCK_50,reset,maskReady,state_controller,nextBestGene,nextSameFitnessFitness,nextGeneInSourceFitness,nextFinalSelectedGene,nextSameFitnessGene,growIndex,state_mutationFSM,maskUsed,bestIndex,nextSameFitness,nextGeneInSource,nextFinalSelected);
/*
	this function control all af the mutation process
			initial_mutationFSM in this state the registers which are indexes for gene selection have selected,
			mutation_mutationFSM in this state we choose nextFinalSelected which means the next best gene 
					and mutate it in 4(howGrowUp) ways,
			nextGene_mutationFSM in this state we select the next gene,
			repeatativeCheck_mutationFSM in this state it is checked if this new selected gene has been selected before or not,
			NextGeneInSource_mutationFSM in this state the pointer to the next gene in the source will increase,
			sameFitness_mutationFSM in this state we have check if the fitness of the nest gene is the same
					of the fitness of the gene which we have chosen, we substitute it for diversity,
			sameGeneChange_mutationFSM in this state we try to change old genes which have repeated a lot in the best items in iterations,
			nextSameGene_mutationFSM ,
			randomGenes_mutationFSM some of the genes is generated randomly for diversity,
			finished_mutationFSM in this state mutation has been finished;
*/

parameter howGrowUp = 4;
parameter geneBit = 80;
parameter population = 24;
parameter bestCount = 4;
parameter mutationMaskCount = 16;
parameter primaryInputCount = 8;
parameter mutation_controller = 3'b011;
parameter initial_mutationFSM = 4'b0000,
			mutation_mutationFSM = 4'b0001,
			nextGene_mutationFSM = 4'b0010,
			repeatativeCheck_mutationFSM = 4'b0011,
			NextGeneInSource_mutationFSM = 4'b0100,
			sameFitness_mutationFSM = 4'b0101,
			sameGeneChange_mutationFSM = 4'b0110,
			nextSameGene_mutationFSM = 4'b0111,
			randomGenes_mutationFSM = 4'b1000,
			finished_mutationFSM = 4'b1001;
			
			
  input CLOCK_50,reset,maskReady;
  input [2:0]state_controller;
 	input [geneBit-1:0]nextBestGene;//sortedGenes[bestIndex];
 	input [primaryInputCount+1:0]nextSameFitnessFitness;//genesFitness[nextSameFitness]
 	input [primaryInputCount+1:0]nextGeneInSourceFitness;//sortedGenes[nextGeneInSource]
 	input [geneBit-1:0]nextFinalSelectedGene;//genes[nextFinalSelected-1]
 	input [geneBit-1:0]nextSameFitnessGene;//genes[nextSameFitness]
 	input [7:0]growIndex;
  output reg [3:0]state_mutationFSM; 
 	output reg maskUsed;
  output reg [7:0]bestIndex,nextSameFitness,nextGeneInSource,nextFinalSelected;
  
	reg [7:0]randomCounter,bestCounter;
	
	integer popIndexMutate;
	reg [geneBit-1:0]best[bestCount-1:0];
	reg parentFound;
  
	always@(posedge CLOCK_50)begin//mutationFSM
    
	 if(reset)begin
		state_mutationFSM <= initial_mutationFSM;
		//mutationFinished <= 0;
		randomCounter <= 8'd0;
		nextGeneInSource <= 8'd0;
		nextFinalSelected <= 8'd0;
		bestCounter <= 8'd0;
		nextSameFitness <= 0;
		parentFound<=0;
		for(bestIndex=0;bestIndex<bestCount;bestIndex=bestIndex+1)begin
			best[bestIndex]<=0;
      end
	 end else if(state_controller==mutation_controller)begin
	
		case(state_mutationFSM)
		
			initial_mutationFSM : 
			begin
			   bestCounter <= 8'd0;
				nextGeneInSource <= 8'd0;
				nextFinalSelected <= 8'd0;
				parentFound<=0;
				for(bestIndex=0;bestIndex<bestCount;bestIndex=bestIndex+1)begin
       			best[bestIndex]<=nextBestGene;//sortedGenes[bestIndex];
        end
				if(maskReady)begin
					state_mutationFSM <= mutation_mutationFSM;
				end	
      end 

			mutation_mutationFSM :
			begin
				if(nextFinalSelected<bestCount && nextGeneInSource<population )begin
				  if(growIndex==howGrowUp-1)begin
					   state_mutationFSM <= nextGene_mutationFSM;
				  end   
				end else begin
				    nextSameFitness <= nextFinalSelected-8'd1;
					maskUsed<=1;
					state_mutationFSM <= sameFitness_mutationFSM;
				end
			end
			
			nextGene_mutationFSM :
			begin
				nextFinalSelected <= nextFinalSelected + 8'd1;
				nextGeneInSource <= nextGeneInSource + 8'd1;
				state_mutationFSM <= repeatativeCheck_mutationFSM;
			end
			
			repeatativeCheck_mutationFSM :
			begin
				if(nextGeneInSourceFitness==nextFinalSelectedGene)begin//genes[nextFinalSelected-1],sortedGenes[nextGeneInSource]
					state_mutationFSM <= NextGeneInSource_mutationFSM;
				end else begin
					state_mutationFSM <= mutation_mutationFSM;
				end
			end
			
			NextGeneInSource_mutationFSM :
			begin
				nextGeneInSource <= nextGeneInSource + 8'd1;
				state_mutationFSM <= repeatativeCheck_mutationFSM;
			end
			
			sameFitness_mutationFSM : //badi age fitnessesh yeksan bashe ba yeki az bestaye alan, mire oono 
		      									  //check mikone ba bestaye ghabli, age tekrari bashe, badi ro jash mizarim
			begin
				parentFound <= 0;
				if(nextGeneInSourceFitness==nextSameFitnessFitness && nextSameFitness>0 && nextGeneInSource<population )begin//genesFitness[nextSameFitness]
					state_mutationFSM <= sameGeneChange_mutationFSM;
				end else begin
					state_mutationFSM <= randomGenes_mutationFSM;
				end
			end
			
			sameGeneChange_mutationFSM : // mire ba bestaye ghabli check mikone, age tekrari bood ye jadid ke fitnessesh yeki hast ro jaygozin mikone
			begin
					if(nextSameFitnessGene==best[bestCounter])begin
						state_mutationFSM <= nextSameGene_mutationFSM;
						parentFound<=1;
					end else if(bestCounter<bestCount-1)begin			
						bestCounter <= bestCounter+1;
					end else begin
						state_mutationFSM <= randomGenes_mutationFSM;
					end		
			end
			
			
			nextSameGene_mutationFSM :
			begin	
				nextSameFitness<=nextSameFitness-8'd1;
				if(parentFound==1)begin
					nextGeneInSource <= nextGeneInSource + 8'd1;
				end
				state_mutationFSM <= sameFitness_mutationFSM;
				bestCounter<=0;
			end	
			
			randomGenes_mutationFSM :
			begin
			  if(randomCounter<population-mutationMaskCount-bestCount)begin
				 randomCounter<=randomCounter+8'd1;
			  end else begin
				 state_mutationFSM <= finished_mutationFSM;
				 //mutationFinished <= 1;
				 randomCounter <= 8'b0;
			  end    
			end
			finished_mutationFSM :
			begin
			end
			
 		default: 
		begin
		end     
	endcase
	end else begin
		//mutationFinished <= 0;
		state_mutationFSM <= initial_mutationFSM;
		if(maskReady==0)begin
			maskUsed<=0;
		end
	end//if
	end//while
	
	endmodule
