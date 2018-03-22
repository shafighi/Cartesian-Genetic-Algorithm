`timescale 1ns/1ns

module mutation(CLOCK_50,rst,LEDR,SRAM_ADDRESS_O,SRAM_DATA_IO,SRAM_UB_N_O,SRAM_LB_N_O,SRAM_WE_N_O,SRAM_CE_N_O,SRAM_OE_N_O);

parameter geneBit = 80;
parameter row = 3;
parameter column = 3;
parameter selBit = 4;
parameter funcBit = 2;
parameter funcCount = 4;
parameter geneResultBit = 2;
parameter primaryInputCount = 8;
parameter population = 24;
parameter bestCount = 4;
parameter maxSupport = 128;
parameter bitCountMutate = 7;
parameter mutationMaskCount = 16;
parameter primaryInputBit = 3;
parameter howGrowUp = 4;
parameter funcResultBit = 4;
parameter mutateCountSelectBit = 4;
parameter geneFuncMem = 16'b1110100110010100;
parameter functionMem = 16'b0111011011101000;

parameter initial_maskFSM = 3'b000,
			 bitChange_maskFSM = 3'b001,
			 bitCount_maskFSM = 3'b010,
			 maskCount_maskFSM = 3'b011,
			 maskReady_maskFSM = 3'b100,
			 finished_maskFSM = 3'b101;		
			 
parameter initial_controller = 3'b000,
			fitness_controller = 3'b001,
			sort_controller = 3'b010,
			mutation_controller = 3'b011,
			memory_controller = 3'b101,
			finished_controller = 3'b110;

parameter initial_memFSM=2'b00,
          write_memFSM=2'b01,
          writeTime_memFSM=2'b10,
          finished_memFSM = 2'b11; 

parameter initial_sortFSM = 4'b0000,
			zeros_sortFSM = 4'b0001,
			zeroCounter_sortFSM = 4'b0010,
			ones_sortFSM = 4'b0011,
			oneCounter_sortFSM = 4'b0100,
			baseBitCounter_sortFSM = 4'b0101,
			sortedCounterZeros_sortFSM = 4'b0110,
			sortedCounterOnes_sortFSM = 4'b0111,
			finished_sortFSM = 4'b1000;

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
			
parameter initial_initFSM = 2'b00,
			firstGenes_initFSM = 2'b01,
			popIndexSort_initFSM = 2'b10,
			finished_initFSM = 2'b11;		 

	parameter initial_evaluationFSM = 3'b000,
			    blockCalculation_evaluationFSM = 3'b001,
				 mismatch_evaluationFSM = 3'b010,
				 shiftMismatches_evaluationFSM = 3'b011,
				 fitnessResult_evaluationFSM = 3'b100,
				 geneFound_evaluationFSM=3'b101,
				 finished_evaluationFSM = 3'b110;

  input CLOCK_50,rst;
  //output reg [7:0]LEDG;
  output reg LEDR;
  output [19:0] SRAM_ADDRESS_O;
  inout   [15:0]SRAM_DATA_IO;
  output  SRAM_UB_N_O;
  output  SRAM_LB_N_O;
  output  SRAM_WE_N_O;
  output  SRAM_CE_N_O;
  output	SRAM_OE_N_O;
 

  wire [geneBit-1:0]random;
  //wire [selectGeneBit*mutateCountSelectBit-1:0]randomBit;//bara in zarb kardam ke ziad beshe, daghighesh intorie ke bayad 2^mutateCountSelectBit+ tedad bt bara select bashe 
  wire [4095:0]RandomNum4096;
  wire [8191:0]RandomNum8192;
  wire [mutateCountSelectBit-1:0]mutateCountSelect;
  wire [bitCountMutate-1:0]partialRandom;
  wire [17:0]LEDRIN;
  
  //initial
  wire [1:0]state_initFSM;
 	wire [4095:0]Seed;
  wire [4095:0]Tap;
  wire seedIsReady,functionMemIsReady;
  
  //read and write
  wire start,rw;
  wire [19:0]address;
  wire done;
  wire [maxSupport-1:0]dataIn;
  reg [maxSupport-1:0]dataOut;
  
   //enable and reset
   wire reset;
  // reg geneIsReady;
   wire memEnable;
	
 //genes
  wire [geneBit-1:0]mutationMaskItem;
 	wire [geneBit-1:0]nextFinalSelectedGene;//genes[nextFinalSelected-1]
 	wire [geneBit-1:0]nextSameFitnessGene,nextBestGene;//genes[nextSameFitness]
 	wire [primaryInputCount+1:0]nextSameFitnessFitness;//genesFitness[nextSameFitness]
 	wire [primaryInputCount+1:0]nextGeneInSourceFitness;//sortedGenes[nextGeneInSource]
 	wire [7:0]populationCounter;
 	wire [primaryInputCount+1:0]bestFitness;
 	wire [geneBit-1:0]sortGene;
 	wire [primaryInputCount+1:0]compareGeneCounterFitness;
 	reg [7:0]growIndex;
 
	//controller_always
	wire [2:0]state_controller;
	 
	//mask_always
	reg [geneBit-1:0]mutationMask[mutationMaskCount-1:0];
	integer maskIndex;
	wire [10:0]bitCount;
  wire [2:0]state_maskFSM;
  wire [10:0]maskCount;
  wire maskReady;	
  reg outOfBound;
	  
	//timer_always
	reg [255:0]timer;
   
	//fitness_always

	wire [geneBit-1:0]gene;
	wire [primaryInputCount+1:0]fitness;
  wire [7:0]fitCounter;
  wire [2:0]state_evaluationFSM;

	//sort_always
	wire [primaryInputCount+1:0]andAll,orAll;
	wire [7:0]compareGeneCounter;
	wire [7:0]sortGeneCount,sortBitCount,sortedCounter;
	wire [3:0]state_sortFSM;

  //memory
  wire [1:0]state_memFSM;
	
	
	//mutation_always

	wire [3:0]state_mutationFSM;
	wire maskUsed;
	wire [7:0]nextFinalSelected,nextGeneInSource,nextSameFitness,randomCounter,bestIndex;
	
				
  evaluation #(geneBit,row,column,selBit,funcBit,funcCount,geneResultBit,primaryInputCount,primaryInputBit,funcResultBit,population,maxSupport,fitness_controller,initial_evaluationFSM,blockCalculation_evaluationFSM,mismatch_evaluationFSM,shiftMismatches_evaluationFSM,fitnessResult_evaluationFSM,geneFound_evaluationFSM,finished_evaluationFSM)fit(CLOCK_50,reset,functionMemIsReady,gene,geneFuncMem,functionMem,state_controller,fitness,fitCounter,state_evaluationFSM); 
  lfsr #(4096)GenerateRandom(CLOCK_50,reset,seedIsReady,RandomNum4096,Seed,Tap);
  memory #(memory_controller,maxSupport,initial_memFSM,write_memFSM,writeTime_memFSM,finished_memFSM)readGeneLfsr(CLOCK_50,reset,state_controller,dataOut,dataIn,SRAM_ADDRESS_O,SRAM_DATA_IO,SRAM_UB_N_O,SRAM_LB_N_O,SRAM_WE_N_O,SRAM_CE_N_O,SRAM_OE_N_O,state_memFSM);
  initialFsm #(population,initial_controller,initial_initFSM,firstGenes_initFSM,popIndexSort_initFSM,finished_initFSM)initF(CLOCK_50,reset,state_controller,state_initFSM,Seed,Tap,seedIsReady,functionMemIsReady,populationCounter);
  controller#(finished_evaluationFSM,geneFound_evaluationFSM,finished_memFSM,finished_sortFSM,finished_mutationFSM,finished_initFSM,initial_controller,fitness_controller,sort_controller,mutation_controller,memory_controller,finished_controller)cntrl(CLOCK_50,reset,state_initFSM,state_evaluationFSM,state_sortFSM,state_mutationFSM,state_memFSM,state_controller);	
	maskFSM#(geneBit,mutationMaskCount,bitCountMutate,mutateCountSelectBit,primaryInputCount,initial_maskFSM,bitChange_maskFSM,bitCount_maskFSM,maskCount_maskFSM,maskReady_maskFSM,finished_maskFSM)maskF(CLOCK_50,reset,maskUsed,mutateCountSelect,bestFitness,state_maskFSM,maskReady,bitCount,maskCount);
  sortFSM#(primaryInputCount,population,sort_controller,initial_sortFSM,zeros_sortFSM,zeroCounter_sortFSM,ones_sortFSM,oneCounter_sortFSM,baseBitCounter_sortFSM,sortedCounterZeros_sortFSM,sortedCounterOnes_sortFSM,finished_sortFSM)sortF(CLOCK_50,reset,sortGene[sortBitCount],state_controller,compareGeneCounterFitness,andAll,orAll,compareGeneCounter,sortGeneCount,sortBitCount,sortedCounter,state_sortFSM);
  mutationFSM#(howGrowUp,geneBit,population,bestCount,mutationMaskCount,primaryInputCount,mutation_controller,initial_mutationFSM,mutation_mutationFSM,nextGene_mutationFSM,repeatativeCheck_mutationFSM,NextGeneInSource_mutationFSM,sameFitness_mutationFSM,sameGeneChange_mutationFSM,nextSameGene_mutationFSM,randomGenes_mutationFSM,finished_mutationFSM)mutationF(CLOCK_50,reset,maskReady,state_controller,nextBestGene,nextSameFitnessFitness,nextGeneInSourceFitness,nextFinalSelectedGene,nextSameFitnessGene,growIndex,state_mutationFSM,maskUsed,bestIndex,nextSameFitness,nextGeneInSource,nextFinalSelected);
  genes#(geneBit,primaryInputCount,population,bestCount,howGrowUp,mutationMaskCount,firstGenes_initFSM,baseBitCounter_sortFSM,sortedCounterZeros_sortFSM,sortedCounterOnes_sortFSM,mutation_mutationFSM,fitnessResult_evaluationFSM,nextGene_mutationFSM,nextSameGene_mutationFSM,randomGenes_mutationFSM,initial_controller,fitness_controller,sort_controller,mutation_controller,memory_controller,finished_controller)genesB(CLOCK_50,reset,fitCounter,populationCounter,random,fitness,sortGeneCount,sortedCounter,compareGeneCounter,mutationMaskItem,state_initFSM,state_evaluationFSM,state_sortFSM,state_mutationFSM,state_memFSM,nextFinalSelected,nextGeneInSource,nextSameFitness,randomCounter,bestIndex,state_controller,growIndex,gene,nextFinalSelectedGene,nextSameFitnessGene,bestFitness,sortGene,nextBestGene,nextSameFitnessFitness,nextGeneInSourceFitness,compareGeneCounterFitness);

	      	
  assign mutateCountSelect= RandomNum8192[timer[0+:12] +: mutateCountSelectBit];
  assign random = RandomNum8192[timer[0+:12] +: geneBit];
  assign RandomNum8192 = {RandomNum4096,RandomNum4096};
  assign partialRandom = RandomNum8192[timer[0+:12]+ bitCount +: bitCountMutate];

  
  assign reset= ~rst;
  
  always@(posedge CLOCK_50)begin//timer
	 if(reset)begin
		timer<=0;
		end else begin
		timer<=timer+1;
		end
	end

  always@(posedge CLOCK_50)begin//dataOut
    if(reset)begin
      dataOut <= 0;
    end else begin
      if(state_controller==memory_controller && state_memFSM==write_memFSM)begin
          dataOut<=gene;
      end else if(state_controller==memory_controller && state_memFSM==writeTime_memFSM)begin
          dataOut<=timer;
      end
    end
  end

  //growIndex
  always@(posedge CLOCK_50)begin
    if(reset)begin
        growIndex<=0;
    end else if(state_controller==mutation_controller && state_mutationFSM==mutation_mutationFSM && nextFinalSelected<bestCount && nextGeneInSource<population)begin
      growIndex <= growIndex +1;
    end else if(state_controller==mutation_controller && state_mutationFSM==nextGene_mutationFSM)begin
      growIndex<=0;
    end
  end

  //aleays@(posedge CLOCK_50)begin

  assign mutationMaskItem = mutationMask[nextFinalSelected*howGrowUp+growIndex];
	always@(posedge CLOCK_50)begin//mutationMask
		if(reset)begin	
				for(maskIndex=0;maskIndex<mutationMaskCount;maskIndex=maskIndex+1)begin
					mutationMask[maskIndex]<=0;
				end	
		end else begin
		  if(state_maskFSM==initial_maskFSM && maskUsed)begin
				for(maskIndex=0;maskIndex<mutationMaskCount;maskIndex=maskIndex+1)begin
					mutationMask[maskIndex]<=0;
				end			    
		  end else if(state_maskFSM==bitCount_maskFSM)begin
		    if(outOfBound)begin
					//mutationMask[maskCount][(randomBit[bitCount +: bitCountMutate])/3]<=1'b1;
					mutationMask[maskCount][partialRandom/3]<=1'b1;
				end else begin
					mutationMask[maskCount][partialRandom]<=1'b1;
				end
			end
	  end
	end
	
	always@(posedge CLOCK_50)begin//outOfBound
	 if(reset)begin	
	   outOfBound <= 0;
	 end else if(state_maskFSM==bitChange_maskFSM && partialRandom>=geneBit)begin 
				outOfBound<=1;
	 end else if(state_maskFSM==bitCount_maskFSM)begin
	   outOfBound <= 0;
	 end
	end


	 
endmodule