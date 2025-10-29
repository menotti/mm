//////////////////////////////////////////////////////////////////////////////////
// Company: UFSCar
// Author: Ricardo Menotti
// 
// Create Date: 29.05.2021 13:50:41
// Project Name: Lab. Remoto de Lógica Digital - DC/UFSCar
// Design Name: uP1 with Video
// Module Name: top
// Target Devices: xc7z020
// Tool Versions: Vivado v2019.2 (64-bit)
//////////////////////////////////////////////////////////////////////////////////
`include "clk_wiz_1.sv"

module top(
  input CLOCK_50, // 125MHz
  output [3:0] VGA_R, VGA_G, VGA_B, 
  output VGA_HS, VGA_VS);

  wire pixel_clk, reset, we; 
  wire [7:0] address, data, vaddr, vdata;
  
  power_on_reset por(CLOCK_50, reset);
  clk_wiz_1 clockdiv(pixel_clk, CLOCK_50); // 25MHz
  cpu proc(CLOCK_50, reset, data, we, address);
  mem #("vga.bin") ram(CLOCK_50, we, address, data, vaddr, vdata); 
  vga video(pixel_clk, reset, vdata, vaddr, VGA_R, VGA_G, VGA_B, VGA_HS, VGA_VS);
endmodule



 
