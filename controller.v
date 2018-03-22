`timescale 1ns/1ns
module controller(CLOCK_50,reset,state_initFSM,state_evaluationFSM,state_sortFSM,state_mutationFSM,state_memFSM,state_controller);	

/* 
this state machine control all the other state machines.
It determine which state machine should be active and when transaction should happen
*/


  parameter finished_evaluationFSM = 3'b100,
			      geneFound_evaluationFSM = 3'b101,
			      finished_memFSM = 2'b11, 
			      finished_sortFSM = 4'b1000,
			      finished_mutationFSM = 4'b1001,
			      finished_initFSM = 2'b11;	
			      	
  parameter initial_controller = 3'b000,
			fitness_controller = 3'b001,
			sort_controller = 3'b010,
			mutation_controller = 3'b011,
			memory_controller = 3'b101,
			finished_controller = 3'b110;
  
  
  input CLOCK_50,reset;
  input [1:0]state_initFSM;
  input [2:0]state_evaluationFSM;
  input [3:0]state_sortFSM,state_mutationFSM;
  input [1:0]state_memFSM;
  output reg [2:0]state_controller;
  //output reg LEDR;
	
	
	always@(posedge CLOCK_50)begin//controller
	 if(reset)begin
		  state_controller <= initial_controller;
		  //LEDG<=0;  
	 end 
	 else begin 
	 
	 case(state_controller)
	 
		initial_controller :
		begin
			if(state_initFSM==finished_initFSM)begin
				state_controller <= fitness_controller;
				//LEDG[0]<=1;
			end

		end	
		fitness_controller :
			if(state_evaluationFSM==geneFound_evaluationFSM)begin
			  state_controller <= memory_controller;
			end else if(state_evaluationFSM==finished_evaluationFSM)begin
				state_controller <= sort_controller;
				//LEDG[1]<=1;
				//LEDG[0]<=0;
				//LEDG[3]<=0;
			end
			
		sort_controller :
		
			if( state_sortFSM==finished_sortFSM)begin
				state_controller <= mutation_controller;
				//LEDG[2]<=1;
				//LEDG[1]<=0;
			end
			
		mutation_controller :
		
			if(state_mutationFSM==finished_mutationFSM)begin
				state_controller <= fitness_controller;
				//LEDG[3]<=1;
				//LEDG[2]<=0;
			end
			
		memory_controller:
		  if( state_memFSM==finished_memFSM)begin
		    state_controller <= finished_controller;
		  end
		finished_controller:
		begin
		  end
		 
		default: 
		begin
		end
		
	 endcase
	 end//if
	 end//always
	 
	 endmodule