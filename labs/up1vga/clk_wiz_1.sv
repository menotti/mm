// Substitutes Xilinx IP core for simulation purposes
module clk_wiz_1(output reg clk_out = 0, input clk_in);
   always@(posedge clk_in)
      clk_out = ~clk_out;
endmodule