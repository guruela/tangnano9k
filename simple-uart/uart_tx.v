// UART transmitter, 8 data bits, no parity, 1 stop bit (8N1)
module uart_tx #(
    parameter CLK_FREQ = 27000000,   // sys_clk frequency in Hz
    parameter BAUD     = 115200
) (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       start,         // pulse high to begin transmission
    input  wire [7:0] data,
    output reg        tx,            // UART TX line
    output wire       busy
);

localparam CLKS_PER_BIT = CLK_FREQ / BAUD;

reg [15:0] clk_cnt;
reg [3:0]  bit_idx;
reg [9:0]  shift;                    // {stop, data[7:0], start}
reg        active;

assign busy = active;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        tx      <= 1'b1;
        active  <= 1'b0;
        clk_cnt <= 16'd0;
        bit_idx <= 4'd0;
        shift   <= 10'b1111111111;
    end else if (!active) begin
        tx      <= 1'b1;
        clk_cnt <= 16'd0;
        bit_idx <= 4'd0;
        if (start) begin
            shift  <= {1'b1, data, 1'b0};   // stop, data, start
            active <= 1'b1;
        end
    end else begin
        if (clk_cnt < CLKS_PER_BIT - 1) begin
            clk_cnt <= clk_cnt + 1'b1;
            tx      <= shift[0];
        end else begin
            clk_cnt <= 16'd0;
            shift   <= {1'b1, shift[9:1]};
            bit_idx <= bit_idx + 1'b1;
            if (bit_idx == 4'd9) begin
                active <= 1'b0;
                tx     <= 1'b1;
            end else begin
                tx <= shift[1];
            end
        end
    end
end

endmodule
