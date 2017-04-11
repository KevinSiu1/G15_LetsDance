`timescale 1ns / 1ps

module ColorDetect(
    input reset_n,
    input clk,
    input enable,
    
    input [23:0] DATA_IN,
    input DATA_IN_VALID,
    input [10:0] X_VALUE,
    input [9:0] Y_VALUE,
    input [1:0] COLOR,
	input [15:0] FRAME_WAIT,
    
    output [31:0] X_SUM,
    output [31:0] Y_SUM,
    output [31:0] COUNTER,
    output READY
    );
    
    reg ready;
    wire EN;
    reg [31:0] x_sum, y_sum, counter;
    
    Internal_EN dut (
        .CLK(clk),
        .RESET(reset_n),
        .EN_IN(enable),
        .NEW_FRAME(DATA_IN_VALID && (X_VALUE == 11'b0) && (Y_VALUE == 10'b0)),
        .FRAME_WAIT(FRAME_WAIT),
        .EN_OUT(EN)
    );
        
    always @(posedge clk)
    begin
        if (!reset_n || !EN)
        begin
            x_sum <= 0;
            y_sum <= 0;
            counter <= 0;
            ready <= 1'b0;
        end        
        else if (EN && DATA_IN_VALID)
        begin
            // read pixel
            case (COLOR)
            2'b00 : //red
            begin
              if ( DATA_IN[23:16] >= 180      // R
                  && DATA_IN[15:8] <= 80     // B
                  && DATA_IN[7:0] <= 80 )    // G
              begin     
                  x_sum <= x_sum + X_VALUE;
                  y_sum <= y_sum + Y_VALUE;
                  counter <= counter + 1;
              end
            end
            2'b01 :     // green
            begin
              if ( DATA_IN[23:16] <= 120    // R
                  && DATA_IN[15:8] <= 120   // B
                  && DATA_IN[7:0] >= 135)   // G
              begin     
                  x_sum <= x_sum + X_VALUE;
                  y_sum <= y_sum + Y_VALUE;
                  counter <= counter + 1;
              end
            end
            2'b10 :     // blue
              begin
                if ( DATA_IN[23:16] <= 45      // R
                    && DATA_IN[15:8] >= 100    // B
                    && DATA_IN[7:0] <= 170)    // G
                begin     
                    x_sum <= x_sum + X_VALUE;
                    y_sum <= y_sum + Y_VALUE;
                    counter <= counter + 1;
                end
              end
            2'b11 :     // yellow
              begin
                if ( DATA_IN[23:16] >= 220     // R
                    && DATA_IN[15:8] <= 160    // B
                    && DATA_IN[7:0] >= 210)     // G
                begin     
                    x_sum <= x_sum + X_VALUE;
                    y_sum <= y_sum + Y_VALUE;
                    counter <= counter + 1;
                end
              end                 
            endcase
        end
            
        // increment x and y
        // to get new pixel
        
        if( X_VALUE == 1279 && Y_VALUE == 719 && DATA_IN_VALID && EN) begin  // max, reset everything
            ready <= 1'b1;            
        end 
		else begin	
			ready <= 1'b0;
		end
    end  
    
    assign READY = ready;
    assign X_SUM = x_sum;
    assign Y_SUM = y_sum;
    assign COUNTER = (counter != 0) ? counter : 1;
    
endmodule

module Internal_EN(
    input CLK,
    input RESET,
    input EN_IN,
    input NEW_FRAME,
    input [15:0] FRAME_WAIT,
    output EN_OUT
    );
    
    reg en_out;
    reg [15:0] frames;   
    
    always @ (posedge CLK) begin
        if (!EN_IN || !RESET) begin
            en_out <= 1'b0;
            frames <= 0;
        end
        else if (EN_IN && NEW_FRAME) begin
            if (frames == FRAME_WAIT) begin
                frames <= 0;
                en_out <= 1'b1;
            end
            else begin
                frames <= frames + 1;
                en_out <= 1'b0;
            end
        end
    end
    
    assign EN_OUT = en_out;    
endmodule