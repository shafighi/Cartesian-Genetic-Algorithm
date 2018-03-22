`timescale 1ns/1ns

module lfsr(clk,rst,seedIsReady,result,seed,tap);//seed sefr nabashe
  
  parameter width = 107;

  parameter initial_lfrsFSM = 1'b0,
			generate_lfsrFSM = 1'b1; 
			
  input clk,rst,seedIsReady;
  input [width-1:0] seed,tap;
  output [width-1:0] result;
  
   reg [width-1:0]LFSR_Reg;
	wire feedBack;
	wire [width-1:0]xorLFSR;
	reg state_lfsrFSM;
	
	assign result = LFSR_Reg;
	assign feedBack = tap[0]^LFSR_Reg[0];	
	assign xorLFSR = feedBack ? (LFSR_Reg ^ tap) :  LFSR_Reg;
	
	always @(posedge clk)begin  	
	  if(rst)begin
		  LFSR_Reg=0;
		  state_lfsrFSM = initial_lfrsFSM;
	  end else begin 
		  case(state_lfsrFSM)
		  
		  initial_lfrsFSM :
		  begin
				if(seedIsReady)begin
					LFSR_Reg = seed;
					state_lfsrFSM = generate_lfsrFSM;
				end
		  end
		  
		  generate_lfsrFSM :
		  begin
				LFSR_Reg = {feedBack,xorLFSR[width-1 : 1]};
				//LFSR_Reg[width-1]<= feedBack;	  ////
		  end
		  endcase
	  end
	end//alway
endmodule