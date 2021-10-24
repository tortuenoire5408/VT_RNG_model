`timescale 1 ns/ 10 ps
module VT_RNG_model(data, data2, reset, clk, x);//V-trapezoid method Random Number Generator
input [23:0] data;
input [15:0] data2;
input  clk, reset;
output [11:0] x;

reg [23:0] lfsr;
reg [15:0] lfsr2;
reg [11:0] x;
reg [9:0] i_t0;
reg s,s_t1;
reg [2:0] mi,mi_t1,mi_t2,mic;
reg [11:0] xl,xl_t1,xl_t2,xl_t3;
reg [7:0] ri,ri_t1;
reg [7:0] u1_t0,u2_t0,u3_t0,u1_t1,u2_t1,u3_t1;
reg q1,q1_t1;
reg [7:0] q2,q3,q3_t2;
reg [11:0] q4,q4_t3;


wire linear_feedback;
wire linear_feedback2;

//===================================================================================

assign linear_feedback = (lfsr[0]^lfsr[1]^lfsr[2]^lfsr[7]);
assign linear_feedback2 = (lfsr2[0] ^ lfsr2[2] ^ lfsr2[3] ^ lfsr2[5]);

// Time 0 ----------------------------------------------------------------------------

always @(posedge clk  or negedge reset)
if (!reset) begin
  lfsr  <= data ;
  lfsr2 <= data2 ;
end else begin
lfsr	<= {linear_feedback, lfsr[23:1]};
lfsr2	<= {linear_feedback2, lfsr2[15:1]};
u1_t0	<= {lfsr[13:12],lfsr[1:0],lfsr[7:6],lfsr[21:20]};
u2_t0	<= {lfsr[9:8],lfsr[23:22],lfsr[5:4],lfsr[17:16]};
u3_t0	<= {lfsr[19:18],lfsr[3:2],lfsr[11:10],lfsr[15:14]};
i_t0	<= {lfsr2[9:8],lfsr2[11:10],lfsr2[5:4],lfsr2[15:14],lfsr2[3:2]};
end

// Time 1 ----------------------------------------------------------------------------

always @(*) begin
	if(i_t0 >= 0 && i_t0 <= 18) begin s = 0; mi = 5; xl = 0; ri = 0; end
	else if(i_t0 >= 19 && i_t0 <= 134) begin s = 0; mi = 2; xl = 128; ri = 170; end
	else if(i_t0 >= 135 && i_t0 <= 250) begin s = 1; mi = 1; xl = 1152; ri = 170; end
	else if(i_t0 >= 251 && i_t0 <= 327) begin s = 1; mi = 0; xl = 1664; ri = 255; end
	else if(i_t0 >= 328 && i_t0 <= 520) begin s = 0; mi = 1; xl = 1920; ri = 102; end
	else if(i_t0 >= 521 && i_t0 <= 675) begin s = 1; mi = 5; xl = 2432; ri = 255; end
	else if(i_t0 >= 676 && i_t0 <= 868) begin s = 1; mi = 2; xl = 2560; ri = 102; end
	else if(i_t0 >= 869 && i_t0 <= 1023) begin s = 0; mi = 1; xl = 3584; ri = 128; end

	if(u2_t0 < u3_t0) begin q1 = 1; end
	else if(u2_t0 > u3_t0) begin q1 = 0;end
end

always @(posedge clk)
begin
	s_t1 <= s;
	mi_t1 <= mi;
	xl_t1 <= xl;
	ri_t1 <= ri;
	u1_t1 <= u1_t0;
	u2_t1 <= u2_t0;
	u3_t1 <= u3_t0;
	q1_t1 <= q1;
end

// Time 2 ----------------------------------------------------------------------------

always @(*) begin
	q2 = (s_t1 ^ q1_t1) ? u3_t1 : u2_t1;
	q3 = (u1_t1 < ri_t1) ? u2_t1 : q2;
end

always @(posedge clk)
begin
	q3_t2 <= q3;
	mi_t2 <= mi_t1;
	xl_t2 <= xl_t1;
end


// Time 3 ----------------------------------------------------------------------------

always @(*) begin
	q4 = (mi_t2[2]) ? q3_t2 >> mi_t2[1:0] : q3_t2 << mi_t2[1:0];
end

always @(posedge clk)
begin
	xl_t3 <= xl_t2;
	q4_t3 <= q4;
end

// Time 4 ----------------------------------------------------------------------------

always @(posedge clk)
begin
	x <= q4_t3 + xl_t3;
end

//===================================================================================

endmodule
