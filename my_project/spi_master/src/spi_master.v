module spi_master (
    input clk,
    input rst,
    input start,
    input [7:0] data_in,
    output reg [7:0] data_out,
    output reg sclk,
    output reg mosi,
    input miso,
    output reg cs,
    output reg spi_busy
);

    parameter CLK_DIV = 4;

    reg [2:0] bit_count;
    reg [7:0] shift_reg;
    reg [7:0] clk_div_count;

    localparam IDLE     = 0;
    localparam TRANSFER = 1;
    reg state;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state         <= IDLE;
            sclk          <= 1'b0;
            mosi          <= 1'b0;
            cs            <= 1'b1;
            spi_busy      <= 1'b0;
            bit_count     <= 0;
            clk_div_count <= 0;
            data_out      <= 8'b0;
        end else begin
            case (state)
                IDLE: begin
                    cs   <= 1'b1;
                    sclk <= 1'b0;
                    if (start) begin
                        shift_reg     <= data_in;
                        bit_count     <= 0;
                        clk_div_count <= 0;
                        cs            <= 1'b0;
                        spi_busy      <= 1'b1;
                        state         <= TRANSFER;
                    end
                end

                TRANSFER: begin
                    if (clk_div_count < CLK_DIV - 1) begin
                        clk_div_count <= clk_div_count + 1;
                    end else begin
                        clk_div_count <= 0;
                        sclk <= ~sclk;

                        if (sclk == 1'b0) begin
                            mosi <= shift_reg[7];
                        end else begin
                            shift_reg <= {shift_reg[6:0], miso};
                            bit_count <= bit_count + 1;

                            if (bit_count == 7) begin
                                data_out <= {shift_reg[6:0], miso};
                                cs       <= 1'b1;
                                spi_busy <= 1'b0;
                                state    <= IDLE;
                            end
                        end
                    end
                end
            endcase
        end
    end

endmodule