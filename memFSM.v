`timescale 1ns/1ns

module memFSM(CLOCK_50,reset,done,state_controller,start,rw,address,state_memFSM);

parameter memory_controller = 3'b101;
parameter initial_memFSM=2'b00,
          write_memFSM=2'b01,
          writeTime_memFSM=2'b10,
          finished_memFSM=2'b11;
          

input CLOCK_50,reset,done;
input [2:0]state_controller;
output reg start,rw;
output reg [19:0]address;
//output reg memoryFinished;
output reg [1:0]state_memFSM;



parameter initial_fitFSM = 3'b000,
			gene_fitFSM = 3'b001;
	always@(posedge CLOCK_50)begin//controller
	 if(reset)begin
		  state_memFSM <= initial_memFSM;
	 end 
	 else if(state_controller==memory_controller)begin  
	 
	 case(state_memFSM)
	   
	   initial_memFSM :
	   begin
	     state_memFSM <= write_memFSM;
	   end
	     
	   write_memFSM :
	   begin
		   address<=20'd0;
			 start<=1'b1;
			 rw<=1'b1;
		   //dataOut<=geneFound;
			 if(done==1 && start==1)begin
					start<=0;
					state_memFSM <= writeTime_memFSM;
				end 
     end
		 writeTime_memFSM :
		 begin
		      address<=20'd1;
					start<=1'b1;
					rw<=1'b1;
					//dataOut<=timer;
					if(done==1 && start==1)begin
					  state_memFSM <= finished_memFSM;
						//memoryFinished<=1;
						start<=0;
					end 
		 end
		 
		 finished_memFSM :
		 begin
		   $stop;
		 end
		   
		 endcase
		 end else begin//if
		    state_memFSM<=initial_memFSM;
		 end
		 end//always
		
				
	endmodule