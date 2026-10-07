module top (
    input clk,
    input resetn,
    output tmds_clk_n,
    output tmds_clk_p,
    output [2:0] tmds_d_n,
    output [2:0] tmds_d_p
);
    localparam H_ACTIVE = 640;
    localparam H_FRONT  = 16;
    localparam H_SYNC   = 96;
    localparam H_BACK   = 48;
    localparam H_TOTAL  = H_ACTIVE + H_FRONT + H_SYNC + H_BACK;

    localparam V_ACTIVE = 480;
    localparam V_FRONT  = 10;
    localparam V_SYNC   = 2;
    localparam V_BACK   = 33;
    localparam V_TOTAL  = V_ACTIVE + V_FRONT + V_SYNC + V_BACK;

    wire clk_pixel_5x;
    wire clk_pixel;
    wire pll_lock;
    wire [2:0] serial_data;
    wire reset_ready = resetn & pll_lock;
    reg [3:0] reset_count = 4'b0;
    reg [9:0] h_count = 10'b0;
    reg [9:0] v_count = 10'b0;

    pixel_clock_pll pll (
        .clkin(clk),
        .clkout(clk_pixel_5x),
        .lock(pll_lock)
    );

    pixel_clock_divider pixel_divider (
        .clkout(clk_pixel),
        .hclkin(clk_pixel_5x),
        .resetn(pll_lock)
    );

    always @(posedge clk_pixel or negedge reset_ready) begin
        if (!reset_ready)
            reset_count <= 4'b0;
        else if (!(&reset_count))
            reset_count <= reset_count + 1'b1;
    end

    wire video_resetn = &reset_count;

    always @(posedge clk_pixel or negedge video_resetn) begin
        if (!video_resetn) begin
            h_count <= 10'b0;
            v_count <= 10'b0;
        end else if (h_count == H_TOTAL - 1) begin
            h_count <= 10'b0;
            if (v_count == V_TOTAL - 1)
                v_count <= 10'b0;
            else
                v_count <= v_count + 1'b1;
        end else begin
            h_count <= h_count + 1'b1;
        end
    end

    wire active_video = (h_count < H_ACTIVE) && (v_count < V_ACTIVE);
    wire hsync = !((h_count >= H_ACTIVE + H_FRONT) &&
                   (h_count < H_ACTIVE + H_FRONT + H_SYNC));
    wire vsync = !((v_count >= V_ACTIVE + V_FRONT) &&
                   (v_count < V_ACTIVE + V_FRONT + V_SYNC));

    wire [9:0] blue_code;
    wire [9:0] green_code;
    wire [9:0] red_code;

    // HDMI lane 0 carries blue and the horizontal/vertical sync control bits.
    tmds_encoder encode_blue (
        .clk(clk_pixel), .resetn(video_resetn), .de(active_video),
        .ctrl({vsync, hsync}), .din(8'hff), .dout(blue_code)
    );
    tmds_encoder encode_green (
        .clk(clk_pixel), .resetn(video_resetn), .de(active_video),
        .ctrl(2'b00), .din(8'h00), .dout(green_code)
    );
    tmds_encoder encode_red (
        .clk(clk_pixel), .resetn(video_resetn), .de(active_video),
        .ctrl(2'b00), .din(8'h00), .dout(red_code)
    );

    OSER10 tmds_serializer [2:0] (
        .Q(serial_data),
        .D0({red_code[0], green_code[0], blue_code[0]}),
        .D1({red_code[1], green_code[1], blue_code[1]}),
        .D2({red_code[2], green_code[2], blue_code[2]}),
        .D3({red_code[3], green_code[3], blue_code[3]}),
        .D4({red_code[4], green_code[4], blue_code[4]}),
        .D5({red_code[5], green_code[5], blue_code[5]}),
        .D6({red_code[6], green_code[6], blue_code[6]}),
        .D7({red_code[7], green_code[7], blue_code[7]}),
        .D8({red_code[8], green_code[8], blue_code[8]}),
        .D9({red_code[9], green_code[9], blue_code[9]}),
        .PCLK(clk_pixel),
        .FCLK(clk_pixel_5x),
        .RESET(~video_resetn)
    );

    ELVDS_OBUF tmds_output_buffer [3:0] (
        .I({clk_pixel, serial_data}),
        .O({tmds_clk_p, tmds_d_p}),
        .OB({tmds_clk_n, tmds_d_n})
    );
endmodule
