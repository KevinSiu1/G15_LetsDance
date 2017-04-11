`timescale 1ns / 1ps

module Stream_Interface(

    input wire [23:0] stream_data,
    input wire stream_last,
    input wire stream_rdy,
    input wire stream_user,
    input wire stream_valid,
    input wire stream_clk,
    input wire stream_resetn,
        
    output wire [23:0] DATA_IN,
    output wire DATA_IN_VALID,
    output wire [10:0] X_VALUE,
    output wire [9:0] Y_VALUE

    );
    
    reg [23:0] data_in;
    reg data_in_vld;
    reg [10:0] x_value;
    reg [9:0] y_value;
    reg next_line;
    
    assign DATA_IN = data_in;
    assign DATA_IN_VALID = data_in_vld;
    assign X_VALUE = x_value;
    assign Y_VALUE = y_value;
    
    always @(posedge stream_clk)
      begin
        if (!stream_resetn)
          begin
            data_in <= 0;
            data_in_vld <= 0;
            x_value <= 0;
            y_value <= 0;
            next_line <= 0;
          end
        else
          begin
            if (stream_rdy && stream_valid)
              begin
                data_in_vld <= 1;
                data_in <= stream_data;
                x_value <= (stream_user || next_line) ? 0 : x_value + 1;
                y_value <= (stream_user) ? 0 : (next_line) ? y_value + 1 : y_value;
                next_line <= (stream_last) ? 1 : 0;                 
              end
            else
              begin
                data_in_vld <= 0;
              end
          end
      end
    
endmodule
