`default_nettype none

module tt_um_hex_counter #(
    parameter integer CLOCK_HZ = 1000000
) (
    input  wire [7:0] ui_in,
    output reg  [7:0] uo_out,
    input  wire [7:0] uio_in,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,
    input  wire       ena,
    input  wire       clk,
    input  wire       rst_n
);
    localparam integer TIMER_BITS = (CLOCK_HZ > 1) ? $clog2(CLOCK_HZ) : 1;
    reg [TIMER_BITS-1:0] timer;
    reg [3:0] digit;

    // Synchronous active-low reset; keep the project clock running during reset.
    always @(posedge clk) begin
        if (!rst_n) begin
            timer <= 0;
            digit <= 0;
        end else if (ena) begin
            if (timer == CLOCK_HZ - 1) begin
                timer <= 0;
                digit <= digit + 1'b1;
            end else begin
                timer <= timer + 1'b1;
            end
        end
    end

    // Active-high outputs: {decimal point, g, f, e, d, c, b, a}.
    // Lowercase b and d distinguish them from 8 and 0 on seven segments.
    always @* begin
        case (digit)
            4'h0: uo_out = 8'h3f;
            4'h1: uo_out = 8'h06;
            4'h2: uo_out = 8'h5b;
            4'h3: uo_out = 8'h4f;
            4'h4: uo_out = 8'h66;
            4'h5: uo_out = 8'h6d;
            4'h6: uo_out = 8'h7d;
            4'h7: uo_out = 8'h07;
            4'h8: uo_out = 8'h7f;
            4'h9: uo_out = 8'h6f;
            4'ha: uo_out = 8'h77;
            4'hb: uo_out = 8'h7c;
            4'hc: uo_out = 8'h39;
            4'hd: uo_out = 8'h5e;
            4'he: uo_out = 8'h79;
            4'hf: uo_out = 8'h71;
            default: uo_out = 8'h00;
        endcase
    end

    assign uio_out = 8'h00;
    assign uio_oe = 8'h00;
    wire unused = &{1'b0, ui_in, uio_in};
endmodule

`default_nettype wire
