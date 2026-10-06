module top (
    input  wire sys_clk,          // 27 MHz clock
    input  wire sys_rst_n,        // reset button (active low)
    output wire uart_tx
);

localparam MSG_LEN = 14;

// Message byte ROM: "Hello World!\r\n"
reg [7:0] msg [0:MSG_LEN-1];
initial begin
    msg[0]  = "H";
    msg[1]  = "e";
    msg[2]  = "l";
    msg[3]  = "l";
    msg[4]  = "o";
    msg[5]  = " ";
    msg[6]  = "W";
    msg[7]  = "o";
    msg[8]  = "r";
    msg[9]  = "l";
    msg[10] = "d";
    msg[11] = "!";
    msg[12] = 8'h0D;   // CR
    msg[13] = 8'h0A;   // LF
end

wire       tx_busy;
reg        tx_start;
reg  [7:0] tx_data;

uart_tx #(
    .CLK_FREQ (27000000),
    .BAUD     (115200)
) u_tx (
    .clk   (sys_clk),
    .rst_n (sys_rst_n),
    .start (tx_start),
    .data  (tx_data),
    .tx    (uart_tx),
    .busy  (tx_busy)
);

localparam DELAY_INIT   = 27000000 / 2;   // 0.5 s after reset
localparam DELAY_REPEAT = 27000000;       // 1 s between repeats

reg [25:0] delay_cnt;
reg [3:0]  idx;
reg        started;        // tx has accepted the current byte

localparam S_DELAY = 2'd0,
           S_START = 2'd1,
           S_BUSY  = 2'd2;

reg [1:0] state;

always @(posedge sys_clk or negedge sys_rst_n) begin
    if (!sys_rst_n) begin
        state     <= S_DELAY;
        delay_cnt <= DELAY_INIT;
        idx       <= 4'd0;
        tx_start  <= 1'b0;
        tx_data   <= 8'd0;
        started   <= 1'b0;
    end else begin
        case (state)
        S_DELAY: begin
            tx_start <= 1'b0;
            started  <= 1'b0;
            if (delay_cnt == 26'd0) begin
                idx   <= 4'd0;
                state <= S_START;
            end else begin
                delay_cnt <= delay_cnt - 1'b1;
            end
        end
        S_START: begin
            tx_data  <= msg[idx];
            tx_start <= 1'b1;
            state    <= S_BUSY;
        end
        S_BUSY: begin
            tx_start <= 1'b0;
            if (tx_busy)
                started <= 1'b1;
            if (started && !tx_busy) begin
                // byte finished transmitting
                if (idx == MSG_LEN - 1) begin
                    idx       <= 4'd0;
                    delay_cnt <= DELAY_REPEAT;
                    started   <= 1'b0;
                    state     <= S_DELAY;
                end else begin
                    idx     <= idx + 1'b1;
                    started <= 1'b0;
                    state   <= S_START;
                end
            end
        end
        endcase
    end
end

endmodule
