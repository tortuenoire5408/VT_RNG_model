`timescale 1 ns/ 10 ps
`define CYCLE      10                //clock period
`define SDFFILE    "./VT_RNG_model.sdf"    //sdf file name
`define End_CYCLE  100006            // Check out 10e5 Records
`define EXP        "./golden.dat"

module testbench();


reg [23:0] data;
reg [15:0] data2;
reg clk;
reg reset;
wire [11:0] x;

integer exp_num, error;
parameter N_EXP   = 100006;
reg [11:0] exp_mem [0:N_EXP-1];

integer out_f;

VT_RNG_model u1(
	.data(data),
	.data2(data2),
	.reset(reset),
	.clk(clk),
	.x(x)
);

`ifdef SDFFILE
    initial $sdf_annotate(`SDFFILE, u1);
`endif

initial	$readmemh (`EXP, exp_mem);

initial begin
    //$dumpfile("VT_RNG_model.vcd");
    //$dumpvars();
    out_f = $fopen("out.dat");
    if (out_f == 0) begin
            $display("Output file open error !");
            $finish;
    end
end

initial begin
    #0;     clk = 0; //set clk to 0
            reset = 1'b0;
            data = 6995554;
            data2 = 8765;
            exp_num = 0;
            error = 0;
end

// Control the clk signal that drives the design block. Cycle time = 10 ns
always begin #(`CYCLE/2) clk = ~clk; end

initial begin
   #(`CYCLE*1);    reset = 1'b1;
end

always@(posedge clk)begin
    $fdisplay(out_f,"%h", x);
    if(x !== exp_mem[exp_num]) begin
        error = error + 1;
        $display("%dth %h !== %h", exp_num, x, exp_mem[exp_num]);
    end
    exp_num = exp_num + 1;
end

initial begin
    #(`CYCLE*`End_CYCLE);
    $display("Total error = %g", error);
    $finish;
end

endmodule