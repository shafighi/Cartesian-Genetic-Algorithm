`timescale 1ns/1ns

module mutationTest();
  
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


  reg rst=1'b0;
  reg clk=1'b0;
  wire [19:0]SRAM_ADDRESS_O;
  wire [15:0]SRAM_DATA_IO;
 // wire [7:0]LEDG;
  wire LEDR;

  wire SRAM_UB_N_O,SRAM_LB_N_O,SRAM_WE_N_O,SRAM_CE_N_O,SRAM_OE_N_O;
  mutation #(geneBit,row,column,selBit,funcBit,funcCount,geneResultBit,primaryInputCount,population,bestCount,maxSupport,bitCountMutate,mutationMaskCount,primaryInputBit,howGrowUp,funcResultBit,mutateCountSelectBit)mt(clk,rst,LEDR,SRAM_ADDRESS_O,SRAM_DATA_IO,SRAM_UB_N_O,SRAM_LB_N_O,SRAM_WE_N_O,SRAM_CE_N_O,SRAM_OE_N_O);  
    initial begin
     rst=1'b0;
     #100;
     rst=1'b1; 
    end
  
  always #10 clk=~clk;
  
endmodule

