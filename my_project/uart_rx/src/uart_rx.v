module uart_rx (
    input clk,
    input rst,
    input rx,                  // serial input line
    output reg [7:0] data_out, // received byte
    output reg rx_done         // pulses high for 1 cycle when byte received
);

    parameter CLKS_PER_BIT = 5208;

    reg [12:0] clk_count = 0;
    reg [2:0]  bit_index = 0;
    reg [3:0]  state = 0;

    localparam IDLE   = 0;
    localparam START  = 1;
    localparam DATA   = 2;
    localparam STOP   = 3;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state     <= IDLE;
            clk_count <= 0;
            bit_index <= 0;
            rx_done   <= 1'b0;
            data_out  <= 8'b0;
        end else begin
            rx_done <= 1'b0;

            case (state)
                IDLE: begin
                    if (rx == 1'b0) begin
                        state     <= START;
                        clk_count <= 0;
                    end
                end

                START: begin
                    if (clk_count < (CLKS_PER_BIT - 1) / 2) begin
                        clk_count <= clk_count + 1;
                    end else begin
                        if (rx == 1'b0) begin
                            clk_count <= 0;
                            state     <= DATA;
                        end else begin
                            state <= IDLE;
                        end
                    end
                end

                DATA: begin
                    if (clk_count < CLKS_PER_BIT - 1) begin
                        clk_count <= clk_count + 1;
                    end else begin
                        clk_count <= 0;
                        data_out[bit_index] <= rx;
                        if (bit_index < 7) begin
                            bit_index <= bit_index + 1;
                        end else begin
                            bit_index <= 0;
                            state     <= STOP;
                        end
                    end
                end

                STOP: begin
                    if (clk_count < CLKS_PER_BIT - 1) begin
                        clk_count <= clk_count + 1;
                    end else begin
                        clk_count <= 0;
                        rx_done   <= 1'b1;
                        state     <= IDLE;
                    end
                end
            endcase
        end
    end

endmodule