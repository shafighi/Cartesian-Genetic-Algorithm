`timescale 1ns/1ns
module oneBitBlock(clk,rst,muxChoices,muxSel0,muxSel1,func,functionMem,result);

	/*
		in this function the inputs of the nodes have been selected. 

	*/
  parameter choicesBit = 9;
  parameter selBit = 4;
  parameter funcBit = 2;
  parameter funcCount=4;
  parameter funcResultBit = 4;

	  
  input clk,rst;
  input [choicesBit-1:0] muxChoices;
  input [selBit-1:0] muxSel0,muxSel1;
  input [funcBit-1:0] func;
  input [funcCount*funcResultBit-1:0]functionMem;
  output result;
  
  wire [1:0]in;
  wire funcResult;
	
  assign result = (rst) ? 1'b0:functionMem[func*funcResultBit+in]; 
  assign in[0] = (muxSel0<choicesBit) ? muxChoices[muxSel0]:muxChoices[muxSel0[selBit-2:0]] ;
  assign in[1] = (muxSel1<choicesBit) ? muxChoices[muxSel1]:muxChoices[muxSel1[selBit-2:0]] ;


endmodule