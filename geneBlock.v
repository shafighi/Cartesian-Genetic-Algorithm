`timescale 1ns/1ns
module geneBlock(clk,rst,geneIsReady,gene,functionMem,state_controller,result,blockResultIsReady,state_geneBlockFSM);
                 
  /*
  this is the block of the nodes which we have determine the dimensions at first in parameters
  we connected the nodes, inputs, outputs and generate the total output of the block which is 
  the bits which in gene have been introduced as the out put
  
  */
  parameter geneBit = 107;
  parameter row = 3;
  parameter column = 3;
  parameter selBit = 4;
  parameter funcBit = 3;
  parameter funcCount=4;
  parameter resultBit=2;
  parameter primaryInputBit=3;
  parameter funcResultBit = 4;
  parameter fitness_controller = 3'b001;
  parameter initial_geneBlockFSM = 2'b00,
            geneIsReady_geneBlockFSM = 2'b01,
            waitForResult_geneBlockFSM = 2'b10,
            finished_geneBlockFSM = 2'b11;
  
  
  
  input clk,rst,geneIsReady;
  input [geneBit-1:0] gene;
  input [funcCount*funcResultBit-1:0]functionMem;
  input [2:0]state_controller;
  output [resultBit-1:0]result;
  output reg blockResultIsReady;
  output reg [1:0]state_geneBlockFSM;
 // output blockResultIsReady;
  genvar i,j,k;
  integer index;
  reg [7:0]packCounter;
  reg [row*column+primaryInputBit-1:0]muxChoices;
  wire [row*column-1:0]out;
  //reg [choicesBit+row-1:0]outReg;
  reg [15:0] pack[column-1:0];//=`{1,0,0,0,0,0,0,0};
  reg [31:0]columnCounter;//bayad did ke coulum chand bite
  
  //reg [3:0]selBit;
  
  generate
    //always@(posedge clk) begin
      for ( i=0; i<row ; i=i+1) begin:rowFor
        //pack =  pack*(i*row + j)+2*(encoderOut)+funcbit;
        for ( j=0; j<column ; j=j+1) begin:columnFor
          //integer whichBlock = i*row + j;
          //priorityEncoder #(choicesBit) pe (enable,(j+1)*row,encoderOut);
          if(j*row+primaryInputBit-1<2)begin
          oneBitBlock #(j*row+primaryInputBit,1,funcBit,funcCount,funcResultBit)U (clk,rst,muxChoices[j*row+primaryInputBit-1:0],gene[pack[j]+i*(1+1+funcBit) +: 1],gene[pack[j]+i*(1+1+funcBit)+1 +: 1],gene[pack[j]+i*(1+1+funcBit)+2*(1) +: funcBit],functionMem,out[j*row + i]);
          end else if(j*row+primaryInputBit-1<4)begin
            oneBitBlock #(j*row+primaryInputBit,2,funcBit,funcCount,funcResultBit)U (clk,rst,muxChoices[j*row+primaryInputBit-1:0],gene[pack[j]+i*(2+2+funcBit) +: 2],gene[pack[j]+i*(2+2+funcBit)+2 +: 2],gene[pack[j]+i*(2+2+funcBit)+2*(2) +: funcBit],functionMem,out[j*row + i]);
            end else if(j*row+primaryInputBit-1<8)begin
              oneBitBlock #(j*row+primaryInputBit,3,funcBit,funcCount,funcResultBit)U (clk,rst,muxChoices[j*row+primaryInputBit-1:0],gene[pack[j]+i*(3+3+funcBit) +: 3],gene[pack[j]+i*(3+3+funcBit)+3 +: 3],gene[pack[j]+i*(3+3+funcBit)+2*(3) +: funcBit],functionMem,out[j*row + i]);
              end else if(j*row+primaryInputBit-1<16)begin
                oneBitBlock #(j*row+primaryInputBit,4,funcBit,funcCount,funcResultBit)U (clk,rst,muxChoices[j*row+primaryInputBit-1:0],gene[pack[j]+i*(4+4+funcBit) +: 4],gene[pack[j]+i*(4+4+funcBit)+4 +: 4],gene[pack[j]+i*(4+4+funcBit)+2*(4) +: funcBit],functionMem,out[j*row + i]);
                end else if(j*row+primaryInputBit-1<32)begin
                  oneBitBlock #(j*row+primaryInputBit,5,funcBit,funcCount,funcResultBit)U (clk,rst,muxChoices[j*row+primaryInputBit-1:0],gene[pack[j]+i*(5+5+funcBit) +: 5],gene[pack[j]+i*(5+5+funcBit)+5 +: 5],gene[pack[j]+i*(5+5+funcBit)+2*(5) +: funcBit],functionMem,out[j*row + i]);
                  end else if(j*row+primaryInputBit-1<64)begin
                    oneBitBlock #(j*row+primaryInputBit,6,funcBit,funcCount,funcResultBit)U (clk,rst,muxChoices[j*row+primaryInputBit-1:0],gene[pack[j]+i*(6+6+funcBit) +: 6],gene[pack[j]+i*(6+6+funcBit)+6 +: 6],gene[pack[j]+i*(6+6+funcBit)+2*(6) +: funcBit],functionMem,out[j*row + i]);  
                    end else if(j*row+primaryInputBit-1<128)begin
                      oneBitBlock #(j*row+primaryInputBit,7,funcBit,funcCount,funcResultBit)U (clk,rst,muxChoices[j*row+primaryInputBit-1:0],gene[pack[j]+i*(7+7+funcBit) +: 7],gene[pack[j]+i*(7+7+funcBit)+7 +: 7],gene[pack[j]+i*(7+7+funcBit)+2*(7) +: funcBit],functionMem,out[j*row + i]);
                      end else if(j*row+primaryInputBit-1<256)begin
                         oneBitBlock #(j*row+primaryInputBit,8,funcBit,funcCount,funcResultBit)U (clk,rst,muxChoices[j*row+primaryInputBit-1:0],gene[pack[j]+i*(8+8+funcBit) +: 8],gene[pack[j]+i*(8+8+funcBit)+8 +: 8],gene[pack[j]+i*(8+8+funcBit)+2*(8) +: funcBit],functionMem,out[j*row + i]);
                         end
        end//for

      end//for
    //end//always
  endgenerate
  
  //assign muxChoices={ outReg[0 +: choicesBit],gene[geneBit-1 -: primaryInputBit]};//out[choicesBit-1 -: inoutCount]//{gene[0 +: row] , out[outinputCount-1:0]};//(row*(column-1))]};
  
  generate 
  for( k=resultBit-1 ; k>-1 ; k=k-1)begin : resultFor
    //assign result[resultBit-k-1]= (gene[geneBit-1-k*selBit-primaryInputBit -: selBit]<(choicesBit+primaryInputBit)) ? outReg[gene[geneBit-1-k*selBit-primaryInputBit -: selBit]]:outReg[gene[geneBit-1-k*selBit-primaryInputBit-1 -: selBit-1]] ;//moshkel dare 
    assign result[resultBit-k-1]= (gene[geneBit-1-k*selBit-primaryInputBit -: selBit]<(row*column+primaryInputBit)) ? muxChoices[gene[geneBit-1-k*selBit-primaryInputBit -: selBit]]:muxChoices[gene[geneBit-1-k*selBit-primaryInputBit-1 -: selBit-1]] ;//moshkel dare 
  end
  endgenerate 
  
   always@(posedge clk) begin
  	   if(rst)begin
		    state_geneBlockFSM <= initial_geneBlockFSM;
        packCounter<=1;
        pack[0]<=0;//primaryInputBit-1;
        muxChoices<=0;
        blockResultIsReady<=0;
        columnCounter<=0;
	     end else if(state_controller==fitness_controller)begin
	
		   case(state_geneBlockFSM)
		
			 initial_geneBlockFSM :
          if(packCounter<column)begin
            if((packCounter-1)*row+primaryInputBit-1<2)begin    
              pack[packCounter]<=pack[packCounter-1]+(1+1+funcBit)*row;//packMem[p*16 +: 16];
              //selBit <= 4'd1;
            end
          else if((packCounter-1)*row+primaryInputBit-1<4)begin    
            pack[packCounter]<=pack[packCounter-1]+(2+2+funcBit)*row;//packMem[p*16 +: 16];
            //selBit <= 4'd2;
          end
          else if((packCounter-1)*row+primaryInputBit-1<8)begin    
            pack[packCounter]<=pack[packCounter-1]+(3+3+funcBit)*row;//packMem[p*16 +: 16];
            //selBit <= 4'd3;
          end
          else if((packCounter-1)*row+primaryInputBit-1<16)begin    
            pack[packCounter]<=pack[packCounter-1]+(4+4+funcBit)*row;//packMem[p*16 +: 16];
            //selBit <= 4'd4;
          end
          else if((packCounter-1)*row+primaryInputBit-1<32)begin    
            pack[packCounter]<=pack[packCounter-1]+(5+5+funcBit)*row;//packMem[p*16 +: 16];
            //selBit <= 4'd5;
          end
          else if((packCounter-1)*row+primaryInputBit-1<64)begin    
            pack[packCounter]<=pack[packCounter-1]+(6+6+funcBit)*row;//packMem[p*16 +: 16];
            //selBit <= 4'd6;
          end
          else if((packCounter-1)*row+primaryInputBit-1<128)begin    
            pack[packCounter]<=pack[packCounter-1]+(7+7+funcBit)*row;//packMem[p*16 +: 16];
            //selBit <= 4'd7;
          end
          else if((packCounter-1)*row+primaryInputBit-1<256)begin    
            pack[packCounter]<=pack[packCounter-1]+(8+8+funcBit)*row;//packMem[p*16 +: 16];
            //selBit <= 4'd8;
          end
          else if((packCounter-1)*row+primaryInputBit-1<512)begin    
            pack[packCounter]<=pack[packCounter-1]+(9+9+funcBit)*row;//packMem[p*16 +: 16];
            //selBit <= 4'd9;
          end
          packCounter<=packCounter+1;
        end else begin
          state_geneBlockFSM <= geneIsReady_geneBlockFSM;
        end
      
      
      geneIsReady_geneBlockFSM :
      begin     
        if(geneIsReady)begin
          muxChoices <= { out[0 +: row*column],gene[geneBit-1 -: primaryInputBit]};
          state_geneBlockFSM <= waitForResult_geneBlockFSM;
          columnCounter<=0;
        end
        blockResultIsReady<=0;
      end
      

      waitForResult_geneBlockFSM : 
      begin
      
      if(columnCounter>=column)begin
        blockResultIsReady<=1;
        state_geneBlockFSM <= geneIsReady_geneBlockFSM;
      end else begin
        columnCounter <= columnCounter+1;
        muxChoices <= { out[0 +: row*column],gene[geneBit-1 -: primaryInputBit]};
      end
    
      end
      
      finished_geneBlockFSM:
      begin
        
      end
     endcase
   end//if
 end//always


  /*end else if(packCounter==0)begin
    end else  else if(geneIsReady)begin
      outReg[choicesBit+row-1:primaryInputBit]<=out;
        //for( index=0 ; index<primaryInputBit ; index=index+1)begin : outPrimary
        //outReg[index]=gene[geneBit-primaryInputBit+index];
      //end
    end 
  end*/
endmodule