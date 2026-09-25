`default_nettype none
`timescale 1ns/1ps

module tb;
    // Simulator-generated 1 MHz clock: avoids Python callbacks on every edge.
    reg clk = 0;
    always #500 clk = ~clk;
    reg rst_n = 0;
    reg ena = 0;
    reg [7:0] ui_in = 0;
    reg [7:0] uio_in = 0;
    wire [7:0] uo_out, uio_out, uio_oe;
`ifdef GL_TEST
    wire VPWR;
    wire VGND;
    assign VPWR = 1'b1;
    assign VGND = 1'b0;
`endif

    // Keep the real million-cycle divider in both RTL and gate-level tests.
    tt_um_hex_counter user_project (
`ifdef GL_TEST
        .VPWR(VPWR), .VGND(VGND),
`endif
        .clk(clk), .rst_n(rst_n), .ena(ena),
        .ui_in(ui_in), .uio_in(uio_in), .uo_out(uo_out),
        .uio_out(uio_out), .uio_oe(uio_oe)
    );
    // No waveform dump by default: a full count takes 16 million cycles.
endmodule
`default_nettype wire
