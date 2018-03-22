`timescale 1ns/1ns
module sortFSM(CLOCK_50,reset,gene,state_controller,compareGeneCounterFitness,andAll,orAll,compareGeneCounter,sortGeneCount,sortBitCount,sortedCounter,state_sortFSM);
/*

in this function we sort the genes based on their fitnesses
the sort algorithm is counting sort and the order is o(n)


*/

  parameter primaryInputCount = 8;
  parameter population = 24;
  parameter sort_controller = 3'b01;
  
  parameter initial_sortFSM = 4'b0000,
			zeros_sortFSM = 4'b0001,
			zeroCounter_sortFSM = 4'b0010,
			ones_sortFSM = 4'b0011,
			oneCounter_sortFSM = 4'b0100,
			baseBitCounter_sortFSM = 4'b0101,
			sortedCounterZeros_sortFSM = 4'b0110,
			sortedCounterOnes_sortFSM = 4'b0111,
			finished_sortFSM = 4'b1000;
			
  input CLOCK_50,reset;
  input gene;
  input [2:0]state_controller;
  input [primaryInputCount+1:0]compareGeneCounterFitness;
  input [primaryInputCount+1:0]andAll,orAll;
  output reg [7:0]compareGeneCounter;
  output reg [7:0]sortGeneCount,sortBitCount,sortedCounter;
  output reg [3:0]state_sortFSM;
  
 
  
 	/*always@(posedge CLOCK_50)begin//and_or
	 if(reset)begin		
		andAll <=1;
		orAll <=0;
		end else begin
		  if( state_sortFSM == initial_sortFSM)begin
				for(compareGeneCounter=0;compareGeneCounter<population;compareGeneCounter=compareGeneCounter+1)begin : genesss
					andAll <= andAll & compareGeneCounterFitness;//genesFitness[compareGeneCounter];
					orAll <= orAll | compareGeneCounterFitness;//genesFitness[compareGeneCounter];
				end	
			end
		end
		end//always*/
 
 
  //genesFitness[sortGeneCount][sortBitCount],genesFitness[sortGeneCount][sortBitCount]
  always@(posedge CLOCK_50)begin//sortFSM
    if(reset)begin
		state_sortFSM <= initial_sortFSM;
		//sortFinished <= 0;
		
		sortBitCount <= 8'd0;
		sortGeneCount <= 8'd0;
		sortedCounter <= 0;

	 end else if(state_controller==sort_controller)begin
	
		case(state_sortFSM)
		
		initial_sortFSM : 
			begin
				sortBitCount <= 8'd0;
				sortGeneCount <= 8'd0;
				sortedCounter <= 0;
				state_sortFSM <= zeros_sortFSM;
			end
			
		zeros_sortFSM :
			if(sortBitCount<primaryInputCount+2)begin
				if(andAll==orAll)begin
					state_sortFSM <= baseBitCounter_sortFSM;
				end else begin
					if(sortGeneCount<population && sortedCounter<population)begin
						if(gene==0)begin
							state_sortFSM <= sortedCounterZeros_sortFSM;
						end else
						 state_sortFSM <= zeroCounter_sortFSM;
					end else begin
						sortGeneCount<=0;
						state_sortFSM <= ones_sortFSM;
					end
				end
			end else begin
				state_sortFSM <= finished_sortFSM;
			end
			 
		zeroCounter_sortFSM :
			begin
				sortGeneCount <= sortGeneCount+8'd1;
				state_sortFSM <= zeros_sortFSM;
			end
			
		ones_sortFSM :
			if(sortGeneCount<population && sortedCounter<population)begin
				if(gene==1)begin
					state_sortFSM <= sortedCounterOnes_sortFSM;
				end else
				  state_sortFSM <= oneCounter_sortFSM;
			end else begin
				state_sortFSM <= baseBitCounter_sortFSM;
			end
		
		oneCounter_sortFSM :
			begin
				sortGeneCount <= sortGeneCount+8'd1;
				state_sortFSM <= ones_sortFSM;
			end
	
		baseBitCounter_sortFSM : 
			begin
			  sortedCounter <= 0;
			  sortGeneCount <= 0;
			  sortBitCount <= sortBitCount+8'd1;
				state_sortFSM <= zeros_sortFSM;	

			end
		
		sortedCounterZeros_sortFSM :
			begin
				sortedCounter <= sortedCounter+8'd1;
				sortGeneCount <= sortGeneCount+8'd1;
				state_sortFSM <= zeros_sortFSM;
			end
		
		sortedCounterOnes_sortFSM :
			begin
				sortedCounter <= sortedCounter+8'd1;
				sortGeneCount <= sortGeneCount+8'd1;
				state_sortFSM <= ones_sortFSM;
			end
		finished_sortFSM :
		begin
		end
		
		default: 
		begin
		end				
	endcase
	end else begin//if
		//sortFinished <= 0;
		state_sortFSM <= initial_sortFSM;
	end
	end//always
	
	endmodule