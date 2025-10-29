module top(
  input CLOCK_50, 
  output [3:0] VGA_R, VGA_G, VGA_B, 
  output VGA_HS, VGA_VS);

  wire clk, reset;
  integer count = 0;
  always @(posedge CLOCK_50)
    count = count + 1;
  assign clk = count[0];
  assign reset = !(|count);

  reg [9:0] CounterX, CounterY;
  reg inDisplayArea;
  reg vga_HS, vga_VS;

  wire CounterXmaxed = (CounterX == 800); // 16 + 48 + 96 + 640
  wire CounterYmaxed = (CounterY == 525); // 10 +  2 + 33 + 480
  wire [3:0] row, col;

  always @(posedge clk)
    if (reset)
      CounterX <= 0;
    else 
      if (CounterXmaxed)
        CounterX <= 0;
      else
        CounterX <= CounterX + 1;

  always @(posedge clk)
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

  always @(posedge clk)
  begin
    vga_HS <= (CounterX > (640 + 16) && (CounterX < (640 + 16 + 96)));   // active for 96 clocks
    vga_VS <= (CounterY > (480 + 10) && (CounterY < (480 + 10 +  2)));   // active for  2 clocks
    inDisplayArea <= (CounterX < 640) && (CounterY < 480);
  end

  assign VGA_HS = ~vga_HS;
  assign VGA_VS = ~vga_VS;  

  assign VGA_R = (inDisplayArea && (CounterX < 320)) ? 4'b1111 : 4'b0000;
  assign VGA_G = inDisplayArea ? CounterX[6:3]                 : 4'b0000;
  assign VGA_B = inDisplayArea ? CounterY[7:4]                 : 4'b0000;
endmodule