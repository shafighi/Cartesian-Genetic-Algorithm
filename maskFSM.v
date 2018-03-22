`timescale 1ns/1ns
module maskFSM(CLOCK_50,reset,maskUsed,mutateCountSelect,best,state_maskFSM,maskReady,bitCount,maskCount);
parameter geneBit = 80;
parameter mutationMaskCount = 16;
parameter bitCountMutate = 7;
parameter mutateCountSelectBit = 4;
parameter primaryInputCount = 8;

parameter initial_maskFSM = 3'b000,
			 bitChange_maskFSM = 3'b001,
			 bitCount_maskFSM = 3'b010,
			 maskCount_maskFSM = 3'b011,
			 maskReady_maskFSM = 3'b100,
			 finished_maskFSM = 3'b101;
			 
			 
input CLOCK_50,reset,maskUsed;
//input []mutateBit;
//input [bitCountMutate-1:0]partialRandom;
input [mutateCountSelectBit-1:0]mutateCountSelect;
//input [bitCountMutate-1:0]partialRandom;
input [primaryInputCount+1:0]best;
output reg [2:0]state_maskFSM;
output reg maskReady;
output reg [10:0]bitCount;
//output reg [7:0]state_maskFSM;
output reg [10:0]maskCount;
//output reg maskReady;

	//reg [2:0]state_maskFSM; 

	integer mutateBit;
	
	//reg outOfBound;

always@(posedge CLOCK_50)begin//mutatebit
  if(reset)begin
		  mutateBit <= 4'd10;//selectGeneBit - bitCountMutate; // halate sabet
		  //mutateBit<=mutateCountSelect; // yek adade random (hanooz adade randomi vojood nadare too reset akhe!!! )
	end else begin
	   if(state_maskFSM==maskReady_maskFSM)begin
	  				if(best<8)begin	// halate moteghayer bara tedad bithaye mutation
						mutateBit<=mutateCountSelect[2:0]+2;//mutateCountSelectBit
					end else begin
						mutateBit<=mutateCountSelect+4; // yek adade random
					end
					//mutateBit<=selectGeneBit-bitCountMutate; // halate sabet bara tedad bit haye mutation
		  end 
	end
end
	
		  
always@(posedge CLOCK_50)begin//maskFSM
	 if(reset)begin
		  state_maskFSM <= initial_maskFSM;
		  maskReady<=0;
		  //outOfBound<=0;

	 end 
	 else begin 
	 
	 case(state_maskFSM)
	 
		initial_maskFSM :
		
			begin
				if(maskUsed)begin
					maskReady<=0;
				end
				maskCount<=mutationMaskCount-1;
				bitCount<=0;
				//for(maskIndex=0;maskIndex<mutationMaskCount;maskIndex=maskIndex+1)begin
					//mutationMask[maskIndex]<=0;
				//end
				state_maskFSM <= bitChange_maskFSM;
				//partialRandom <= RandomNum8192[timer[0+:12]+bitCount +: bitCountMutate];/////
			end
	 
	   bitChange_maskFSM :
		begin
			 //if(partialRandom>=geneBit)begin  
			//	outOfBound<=1;
   		 //end 
			 if(maskCount==11'b11111111111)begin 
				   state_maskFSM <= maskReady_maskFSM;
		    end else if(bitCount< mutateBit)begin
					state_maskFSM <= bitCount_maskFSM;
			 end else begin
				  state_maskFSM <= maskCount_maskFSM;
		    end
		end
			  
		bitCount_maskFSM : 
			
			begin
				/*if(outOfBound)begin
					//mutationMask[maskCount][(randomBit[bitCount +: bitCountMutate])/3]<=1'b1;
					mutationMask[maskCount][partialRandom/3]<=1'b1;
				end else begin
					mutationMask[maskCount][partialRandom]<=1'b1;
				end*/
				bitCount <= bitCount+8'd1;
				state_maskFSM <= bitChange_maskFSM;
				//partialRandom <= RandomNum8192[timer[0+:12]+bitCount +: bitCountMutate];////
				//outOfBound<=0;
			end
			
		maskCount_maskFSM : 
		
			begin
				bitCount <= 0;
				maskCount <= maskCount-1;	
				state_maskFSM <= bitChange_maskFSM;		
			end
			
		maskReady_maskFSM : 
		
			begin
				maskReady<=1;
				if(maskUsed)begin
					state_maskFSM <= initial_maskFSM;
					//if(sortedGenesFitness[0]<8)begin	// halate moteghayer bara tedad bithaye mutation
						//mutateBit<=mutateCountSelect[2:0]+1;//mutateCountSelectBit
					//end else begin
						//mutateBit<=mutateCountSelect; // yek adade random
					//end
					//mutateBit<=selectGeneBit-bitCountMutate; // halate sabet bara tedad bit haye mutation
				end
			end
		default: 
		begin
		end					
	 endcase
	 end//reset
	 end//always
	 
	 endmodule