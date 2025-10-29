module cpu(
  input clock, reset,
  inout [7:0] mbr,
  output logic we,
  output logic [7:0] mar, pc, ir);
  
  typedef enum logic [1:0] {FETCH, DECODE, EXECUTE} statetype;
  statetype state, nextstate;
  
  logic [7:0] acc, vaddr;
  
  always @(posedge clock or posedge reset)
  begin
    if (reset) begin
      pc <= 'b0;
      vaddr <= 8'b10000000; // 128
      state <= FETCH;
    end
    else begin
      case(state)
      FETCH: begin
        we <= 0;
        pc <= pc + 1;
        mar <= pc;
      end
      DECODE: begin
        ir = mbr;
        if (ir[7:5] == 3'b000)       // load/store video
          mar <= vaddr;
        else 
          mar <= {4'b1111, ir[3:0]};
      end
      EXECUTE: begin
        if (ir[7] == 1'b1 && acc != 8'b00000000) // jnz
          pc <= {1'b0, ir[6:0]};
        else if (ir[7:4] == 4'b0100) // indirect load 
          acc <= mbr;
        else if (ir[7:4] == 4'b0101) // add acc + data
          acc <= acc + mbr;
        else if (ir[7:4] == 4'b0110) // sub acc - data
          acc <= acc - mbr;
        else if (ir[7:4] == 4'b0011) // store
          we <= 1'b1;
        else if (ir[7:4] == 4'b0000) // load video
          acc <= mbr;
        else if (ir[7:4] == 4'b0001) // store video
        begin
          we <= 1'b1;
          vaddr <= vaddr + 1;
          if (vaddr > 207) 
            vaddr <= 8'b10000000;  // 128
        end
      end
      endcase  
      state <= nextstate;                  
    end
  end
  
  always_comb
    casex(state)
      FETCH:   nextstate = DECODE;
      DECODE:  nextstate = EXECUTE;
      EXECUTE: nextstate = FETCH;
      default: nextstate = FETCH; 
    endcase
  
  assign mbr = we ? acc : 'bz;
endmodule
