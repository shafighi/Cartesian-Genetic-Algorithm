`timescale 1ns/1ns

module genes(CLOCK_50,reset,fitCounter,populationCounter,random,fitness,sortGeneCount,sortedCounter,compareGeneCounter,mutationMaskItem,state_initFSM,state_evaluationFSM,state_sortFSM,state_mutationFSM,state_memFSM,nextFinalSelected,nextGeneInSource,nextSameFitness,randomCounter,bestIndex,state_controller,growIndex,gene,nextFinalSelectedGene,nextSameFitnessGene,bestFitness,sortGene,nextBestGene,nextSameFitnessFitness,nextGeneInSourceFitness,compareGeneCounterFitness);
  /* 
  In this function the registers which contain the genes are controlled.
  All the registers which is needed in sort or other functions are here.
  we can not pass the vector of the register, so we have them here, and jus pass the signals and copy of one register of them.
  */
  
  parameter geneBit = 80;
  parameter primaryInputCount = 8;
  parameter population = 24;
  parameter bestCount = 4;
  parameter howGrowUp = 4;
  parameter mutationMaskCount = 16;
  parameter firstGenes_initFSM = 2'b01;
  parameter baseBitCounter_sortFSM = 4'b0101;
  parameter sortedCounterZeros_sortFSM = 4'b0110;
  parameter sortedCounterOnes_sortFSM = 4'b0111;
  parameter mutation_mutationFSM = 4'b0001;
  parameter fitnessResult_evaluationFSM = 3'b100;
  parameter nextGene_mutationFSM = 4'b0010;
  parameter nextSameGene_mutationFSM = 4'b0111;
  parameter randomGenes_mutationFSM = 4'b1000;
  
  parameter initial_controller = 3'b000,
			fitness_controller = 3'b001,
			sort_controller = 3'b010,
			mutation_controller = 3'b011,
			memory_controller = 3'b101,
			finished_controller = 3'b110;
  
  input CLOCK_50,reset;
  input [7:0]fitCounter;
  input [7:0]populationCounter;
  input [geneBit-1:0]random;
  input [primaryInputCount+1:0]fitness;
 	input [7:0]sortGeneCount,sortedCounter,compareGeneCounter;
 	input [geneBit-1:0]mutationMaskItem;
  input [1:0]state_initFSM;
  input [2:0]state_evaluationFSM;
  input [3:0]state_sortFSM,state_mutationFSM;
  input [1:0]state_memFSM;
  input [7:0]nextFinalSelected,nextGeneInSource,nextSameFitness,randomCounter,bestIndex;
  input [2:0]state_controller;
  input [7:0]growIndex;
  output reg[geneBit-1:0]gene;
 	output [geneBit-1:0]nextFinalSelectedGene;//genes[nextFinalSelected-1]
 	output [geneBit-1:0]nextSameFitnessGene;//genes[nextSameFitness]
 	output [primaryInputCount+1:0]bestFitness;
 	output [geneBit-1:0]sortGene;
 	output [geneBit-1:0]nextBestGene;//sortedGenes[bestIndex];
 	output [primaryInputCount+1:0]nextSameFitnessFitness;//genesFitness[nextSameFitness]
 	output [primaryInputCount+1:0]nextGeneInSourceFitness;//sortedGenes[nextGeneInSource]
 	output [primaryInputCount+1:0]compareGeneCounterFitness;
  
  reg [primaryInputCount+1:0]genesFitness[population-1:0];
	reg [geneBit-1:0]genes[population-1:0];
  reg [primaryInputCount+1:0]sortedGenesFitness[population-1:0];
	reg [geneBit-1:0]sortedGenes[population-1:0];
	integer popIndex,popIndexSort;
 
	assign compareGeneCounterFitness = genesFitness[compareGeneCounter];
  assign nextFinalSelectedGene = genes[nextFinalSelected];
  assign nextSameFitnessGene = genes[nextSameFitness];
  assign bestFitness = sortedGenesFitness[0];
  assign sortGene = genesFitness[sortGeneCount];
  assign nextBestGene = sortedGenes[bestIndex];
  assign nextSameFitnessFitness = genesFitness[nextSameFitness];
  assign nextGeneInSourceFitness = sortedGenesFitness[nextGeneInSource];

  always@(posedge CLOCK_50)begin//genes
    if(reset)begin  
      gene <= 0;
    end else if(state_controller==fitness_controller && fitCounter<population)begin//fitCheck_fitFSM && fitCounter<=population && fitnessReady && (~fitnessChecked)
          gene <= genes[fitCounter];  
      end else
       gene <= 0;
    end
    
    always@(posedge CLOCK_50)begin//genes
    if(reset)begin
      for(popIndex=0;popIndex<population;popIndex=popIndex+1)begin
        genes[popIndex] <= 0;
      end
    end else begin
      if(state_controller==initial_controller && state_initFSM==firstGenes_initFSM)begin
        genes[populationCounter] <= random;
        //firstGenes[populationCounter] <= 89'b10010110000000000000000000000000110000111000010001001101100010011010000100000001000100100;
        //genes[populationCounter] <= 80'b10010110000000000000000000000110000111000100010110110010011010001000000100100100;
        //firstGenes[populationCounter]<=175'b0111110001011100000000000000000000000000000000000000100101011010000000000011000101010100101100010010110000000000000000000000001000111100100011100001000100010001001101000011010;
        //firstGenes[populationCounter]<=104'b11011110011110101010010111001011001010100100001100010110000110100011000100101100101011000001000010010000;//adder2bitbacarry
        //firstGenes[populationCounter]<=175'b10101100110101101001011010010010001000010001101000010001000001000101010111101110100010010100110010110000010100101100101110000101000101001010000111011010011101100000001110000011;//adder3bitbacarry		
      end else 
      if(state_controller==sort_controller && state_sortFSM==baseBitCounter_sortFSM)begin
        for(popIndexSort=0;popIndexSort<population;popIndexSort=popIndexSort+1)begin
            genes[popIndexSort]<=sortedGenes[popIndexSort];
        end
      end else
      if(state_controller==mutation_controller && state_mutationFSM==mutation_mutationFSM && nextFinalSelected<bestCount && nextGeneInSource<population )begin
          genes[nextFinalSelected*howGrowUp+growIndex+bestCount]<=sortedGenes[nextGeneInSource]^ mutationMaskItem;	
      end else
      if(state_controller==mutation_controller && state_mutationFSM==nextGene_mutationFSM)begin
        genes[nextFinalSelected]<=sortedGenes[nextGeneInSource];//long
      end else
      if(state_controller==mutation_controller && state_mutationFSM==nextSameGene_mutationFSM)begin
        genes[nextSameFitness]<=sortedGenes[nextGeneInSource];
      end else 
      if(state_controller==mutation_controller && state_mutationFSM==randomGenes_mutationFSM && randomCounter<population-mutationMaskCount-bestCount)begin
        genes[population-randomCounter-1]<=random;
      end 
      
    end
  end//always
  
   always@(posedge CLOCK_50)begin//genesFitness
    if(reset)begin
      for(popIndex=0;popIndex<population;popIndex=popIndex+1)begin
        genesFitness[popIndex]<=0;
      end
    end else begin 
      if(state_controller==fitness_controller && state_evaluationFSM==fitnessResult_evaluationFSM )begin
        genesFitness[fitCounter] <= fitness;
      end else 
      if(state_controller==sort_controller && state_sortFSM==baseBitCounter_sortFSM)begin
        for(popIndexSort=0;popIndexSort<population;popIndexSort=popIndexSort+1)begin
            genesFitness[popIndexSort]<=sortedGenesFitness[popIndexSort];
        end
      end else
      if(state_controller==mutation_controller && state_mutationFSM==nextGene_mutationFSM)begin
        genesFitness[nextFinalSelected]<=sortedGenesFitness[nextGeneInSource];
      end else
      if(state_controller==mutation_controller && state_mutationFSM==nextSameGene_mutationFSM)begin
        genesFitness[nextSameFitness]<=sortedGenesFitness[nextGeneInSource];
      end
      
    end
  end//always
  
  
 always@(posedge CLOCK_50)begin//sortedGenes
    if(reset)begin
      for(popIndex=0;popIndex<population;popIndex=popIndex+1)begin
        sortedGenes[popIndex]<=0;
      end
    end else begin 
      if(state_controller==sort_controller && state_sortFSM==sortedCounterZeros_sortFSM)begin
        sortedGenes[sortedCounter]<=genes[sortGeneCount];
      end else
      if(state_controller==sort_controller && state_sortFSM==sortedCounterOnes_sortFSM)begin
        sortedGenes[sortedCounter]<=genes[sortGeneCount];
      end  
    end
  end//always  


  always@(posedge CLOCK_50)begin//sortedGenesFitness
    if(reset)begin
      for(popIndex=0;popIndex<population;popIndex=popIndex+1)begin
        sortedGenesFitness[popIndex]<=0;
      end
    end else begin
      if(state_controller==sort_controller && state_sortFSM==sortedCounterZeros_sortFSM)begin
        sortedGenesFitness[sortedCounter]<=genesFitness[sortGeneCount];
      end else
      if(state_controller==sort_controller && state_sortFSM==sortedCounterOnes_sortFSM)begin
        sortedGenesFitness[sortedCounter]<=genesFitness[sortGeneCount];	
      end 
    end
  end//always    
    
    /*
  always@(posedge CLOCK_50)begin//genes
    if(reset)begin
      for(popIndex=0;popIndex<population;popIndex=popIndex+1)begin
        genesFitness[popIndex]<=0;
        genes[popIndex] <= 0;
        sortedGenes[popIndex]<=0;
        sortedGenesFitness[popIndex]<=0;
        //growIndex<=0;
      end
    end else begin
      if(state_controller==initial_controller && state_initFSM==firstGenes_initFSM)begin
        genes[populationCounter] <= random;
        //firstGenes[populationCounter] <= 89'b10010110000000000000000000000000110000111000010001001101100010011010000100000001000100100;
        //genes[populationCounter] <= 80'b10010110000000000000000000000110000111000100010110110010011010001000000100100100;
        //firstGenes[populationCounter]<=175'b0111110001011100000000000000000000000000000000000000100101011010000000000011000101010100101100010010110000000000000000000000001000111100100011100001000100010001001101000011010;
        //firstGenes[populationCounter]<=104'b11011110011110101010010111001011001010100100001100010110000110100011000100101100101011000001000010010000;//adder2bitbacarry
        //firstGenes[populationCounter]<=175'b10101100110101101001011010010010001000010001101000010001000001000101010111101110100010010100110010110000010100101100101110000101000101001010000111011010011101100000001110000011;//adder3bitbacarry		
      end else 
      if(state_controller==fitness_controller && state_evaluationFSM==fitnessResult_evaluationFSM )begin
        genesFitness[fitCounter] <= fitness;
      end else 
      if(state_controller==sort_controller && state_sortFSM==baseBitCounter_sortFSM)begin
        for(popIndexSort=0;popIndexSort<population;popIndexSort=popIndexSort+1)begin
            genes[popIndexSort]<=sortedGenes[popIndexSort];
            genesFitness[popIndexSort]<=sortedGenesFitness[popIndexSort];
        end
      end else 
      if(state_controller==sort_controller && state_sortFSM==sortedCounterZeros_sortFSM)begin
        sortedGenes[sortedCounter]<=genes[sortGeneCount];
        sortedGenesFitness[sortedCounter]<=genesFitness[sortGeneCount];
      end else
      if(state_controller==sort_controller && state_sortFSM==sortedCounterOnes_sortFSM)begin
        sortedGenes[sortedCounter]<=genes[sortGeneCount];
        sortedGenesFitness[sortedCounter]<=genesFitness[sortGeneCount];	
      end else 
      if(state_controller==mutation_controller && state_mutationFSM==mutation_mutationFSM && nextFinalSelected<bestCount && nextGeneInSource<population )begin
        //for(growIndex=0;growIndex<howGrowUp;growIndex=growIndex+1)begin//3
          genes[nextFinalSelected*howGrowUp+growIndex+bestCount]<=sortedGenes[nextGeneInSource]^ mutationMaskItem;
        //end	
      end else
      if(state_controller==mutation_controller && state_mutationFSM==nextGene_mutationFSM)begin
        genes[nextFinalSelected]<=sortedGenes[nextGeneInSource];//long
        genesFitness[nextFinalSelected]<=sortedGenesFitness[nextGeneInSource];
      end else
      if(state_controller==mutation_controller && state_mutationFSM==nextSameGene_mutationFSM)begin
        genesFitness[nextSameFitness]<=sortedGenesFitness[nextGeneInSource];
        genes[nextSameFitness]<=sortedGenes[nextGeneInSource];
      end else 
      if(state_controller==mutation_controller && state_mutationFSM==randomGenes_mutationFSM && randomCounter<population-mutationMaskCount-bestCount)begin
        //mutatedGenes[population-randomCounter-1]<= 89'b10010110000000000000000000000000110000111000010001001101100010011010000100000001000100100;
        genes[population-randomCounter-1]<=random;
      end 
      
    end
  end//always*/
  
endmodule