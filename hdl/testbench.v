`timescale 1ns/1ps

module testbench(

    );
    
reg clk = 1'b1;
always #1
    clk <= !clk;

wire[31:0] PCout;

reg rst_x = 1'b1;
    
main tg(
.CLK(clk),
.RST_X(rst_x),
.PCout(pcout));
    
integer CYCLECNT = 0;
initial begin

@(posedge clk);

$vcdpluson;

rst_x <= 1'b0;
@(posedge clk);
@(posedge clk);
rst_x <= 1'b1;

//Run
for (CYCLECNT=0; CYCLECNT < 32'hFFFFFFFF; CYCLECNT=CYCLECNT+1) begin
    @(posedge clk);
    if (CYCLECNT[13:0] == 14'd0)
        $display(CYCLECNT);//$display("%h", tg.PC << 1);
    
	//if (!tg.csFetchStallRequest)
	//	$display("%h", tg.PC << 1);
    
	if (tg.csValid && tg.csInstruction == 32'h2110_4FFF) begin
        $display("[SUBRISC] Execution completed: ", CYCLECNT, " cycle(s)");
        $finish();
        $vcdplusclose;
    end
end

end 
   
endmodule
