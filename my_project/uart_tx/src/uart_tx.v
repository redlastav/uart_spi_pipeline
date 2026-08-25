module uart_tx (
    input clk,
    input rst,
    input tx_start,          // pulse high to begin sending
    input [7:0] data_in,     // byte to send
    output reg tx,           // serial output line
    output reg tx_busy       // high while transmitting
);

    parameter CLKS_PER_BIT = 5208; // 50MHz clk, 9600 baud

    reg [12:0] clk_count = 0;
    reg [2:0]  bit_index = 0;
    reg [3:0]  state = 0;

    localparam IDLE   = 0;
    localparam START  = 1;
    localparam DATA   = 2;
    localparam STOP   = 3;

    reg [7:0] tx_data;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state     <= IDLE;
            tx        <= 1'b1;
            tx_busy   <= 1'b0;
            clk_count <= 0;
            bit_index <= 0;
        end else begin
            case (state)
                IDLE: begin
                    tx <= 1'b1;
                    if (tx_start) begin
                        tx_data   <= data_in;
                        tx_busy   <= 1'b1;
                        state     <= START;
                        clk_count <= 0;
                    end
                end

                START: begin
                    tx <= 1'b0;
                    if (clk_count < CLKS_PER_BIT - 1) begin
                        clk_count <= clk_count + 1;
                    end else begin
                        clk_count <= 0;
                        state     <= DATA;
                    end
                end

                DATA: begin
                    tx <= tx_data[bit_index];
                    if (clk_count < CLKS_PER_BIT - 1) begin
                        clk_count <= clk_count + 1;
                    end else begin
                        clk_count <= 0;
                        if (bit_index < 7) begin
                            bit_index <= bit_index + 1;
                        end else begin
                            bit_index <= 0;
                            state     <= STOP;
                        end
                    end
                end

                STOP: begin
                    tx <= 1'b1;
                    if (clk_count < CLKS_PER_BIT - 1) begin
                        clk_count <= clk_count + 1;
                    end else begin
                        clk_count <= 0;
                        tx_busy   <= 1'b0;
                        state     <= IDLE;
                    end
                end
            endcase
        end
    end

endmodule