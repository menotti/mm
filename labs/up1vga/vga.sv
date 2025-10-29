module vga(
  input clk, reset,
  input  [7:0] vdata,
  output [7:0] vaddr,
  output [3:0] VGA_R, VGA_G, VGA_B, 
  output VGA_HS, VGA_VS);

  reg [9:0] CounterX, CounterY;
  reg inDisplayArea;
  reg vga_HS, vga_VS;

  wire CounterXmaxed = (CounterX == 800); // 16 + 48 + 96 + 640
  wire CounterYmaxed = (CounterY == 525); // 10 +  2 + 33 + 480
  wire [3:0] row, col;

  always @(posedge clk or posedge reset)
    if (reset)
      CounterX <= 0;
    else 
      if (CounterXmaxed)
        CounterX <= 0;
      else
        CounterX <= CounterX + 1;

  always @(posedge clk or posedge reset)
    if (reset)
      CounterY <= 0;
    else 
      if (CounterXmaxed)
        if(CounterYmaxed)
          CounterY <= 0;
        else
          CounterY <= CounterY + 1;

  assign row = (CounterY>>6);
  assign col = (CounterX>>6);
  assign vaddr = {1'b1,col[3:0],row[2:0]}; 

  always @(posedge clk)
  begin
    vga_HS <= (CounterX > (640 + 16) && (CounterX < (640 + 16 + 96)));   // active for 96 clocks
    vga_VS <= (CounterY > (480 + 10) && (CounterY < (480 + 10 +  2)));   // active for  2 clocks
    inDisplayArea <= (CounterX < 640) && (CounterY < 480);
  end

  assign VGA_HS = ~vga_HS;
  assign VGA_VS = ~vga_VS;  

  assign VGA_R = inDisplayArea ? {vdata[5:4], 2'b00} : 4'b0000;
  assign VGA_G = inDisplayArea ? {vdata[3:2], 2'b00} : 4'b0000;
  assign VGA_B = inDisplayArea ? {vdata[1:0], 2'b00} : 4'b0000;
endmodule
