module mem #(parameter filename = "ram.hex")
          (input clock, we,
           input [7:0] address,
           inout [7:0] data,
           input [7:0] vaddr,
           output [7:0] vdata);

  logic [7:0] RAM[255:0];

  initial
    $readmemb(filename, RAM);

  assign data  = we ? 'bz : RAM[address]; 
  assign vdata = RAM[vaddr]; 

  always @(posedge clock)
    if (we) RAM[address] <= data;
endmodule
