
`timescale 1 ns / 1 ps

	module ColorDetect2_v1_0 #
	(
		// Users to add parameters here

		// User parameters ends
		// Do not modify the parameters beyond this line


		// Parameters of Axi Slave Bus Interface S00_AXI
		parameter integer C_S00_AXI_DATA_WIDTH	= 32,
		parameter integer C_S00_AXI_ADDR_WIDTH	= 4
	)
	(
		// Users to add ports here
        input wire [23:0] stream_data,
        input wire stream_last,
        input wire stream_rdy,
        input wire stream_user,
        input wire stream_valid,
        input wire stream_clk,
        input wire stream_resetn,
        input wire [1:0] color_1,
        input wire [1:0] color_2,
        /*input wire [1:0] color_3,
        input wire [1:0] color_4,*/
        input wire color_detect_enable,
        //output wire [31:0] coordinates_1,
        //output wire [31:0] coordinates_2,
        //output wire [31:0] coordinates_3,
        //output wire [31:0] coordinates_4,
        output wire [31:0] xsum_1,
        output wire [31:0] ysum_1,
        output wire [31:0] counter_1,
        output wire ready_out_1,
        output wire [31:0] xsum_2,
        output wire [31:0] ysum_2,
        output wire [31:0] counter_2,
        output wire ready_out_2,
		// User ports ends
		// Do not modify the ports beyond this line


		// Ports of Axi Slave Bus Interface S00_AXI
		input wire  s00_axi_aclk,
		input wire  s00_axi_aresetn,
		input wire [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_awaddr,
		input wire [2 : 0] s00_axi_awprot,
		input wire  s00_axi_awvalid,
		output wire  s00_axi_awready,
		input wire [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_wdata,
		input wire [(C_S00_AXI_DATA_WIDTH/8)-1 : 0] s00_axi_wstrb,
		input wire  s00_axi_wvalid,
		output wire  s00_axi_wready,
		output wire [1 : 0] s00_axi_bresp,
		output wire  s00_axi_bvalid,
		input wire  s00_axi_bready,
		input wire [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_araddr,
		input wire [2 : 0] s00_axi_arprot,
		input wire  s00_axi_arvalid,
		output wire  s00_axi_arready,
		output wire [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_rdata,
		output wire [1 : 0] s00_axi_rresp,
		output wire  s00_axi_rvalid,
		input wire  s00_axi_rready
	);
// Instantiation of Axi Bus Interface S00_AXI

	wire [23:0] data_in;
	wire data_vld;
	wire [10:0] x_value;
	wire [9:0] y_value;
	wire [15:0] num_frames_to_wait;
	
/*	
	wire [31:0] xsum_1;
	wire [31:0] xsum_2;
	wire [31:0] xsum_3;
	wire [31:0] xsum_4;
	wire [31:0] ysum_1; 
	wire [31:0] ysum_2;
	wire [31:0] ysum_3;
	wire [31:0] ysum_4;
	wire [31:0] counter_1;
	wire [31:0] counter_2;
	wire [31:0] counter_3;
	wire [31:0] counter_4;
	wire ready_out_1;
	wire ready_out_2;
	wire ready_out_3;
	wire ready_out_4;

    reg [31:0] xsum_12_out;
    reg [31:0] xsum_12_wait;
    reg [31:0] xsum_34_out;
    reg [31:0] xsum_34_wait;
    reg [31:0] ysum_12_out;
    reg [31:0] ysum_12_wait;
    reg [31:0] ysum_34_out;
    reg [31:0] ysum_34_wait;
    reg [31:0] counter_12_out;
    reg [31:0] counter_12_wait;
    reg [31:0] counter_34_out;
    reg [31:0] counter_34_wait;
    
    reg wait_12_vld;
    reg out_12_vld;
    reg wait_34_vld;
    reg out_34_vld;
*/
	ColorDetect2_v1_0_S00_AXI # ( 
		.C_S_AXI_DATA_WIDTH(C_S00_AXI_DATA_WIDTH),
		.C_S_AXI_ADDR_WIDTH(C_S00_AXI_ADDR_WIDTH)
	) ColorDetect2_v1_0_S00_AXI_inst (
	    .num_frames_to_wait(num_frames_to_wait),
	    //.x_value(x_value),
        //.y_value(y_value),
        //.new_frame(stream_user),
        //.stream_rdy(stream_rdy),
        //.in_data(data_in),
        //.data_vld(stream_valid),
		.S_AXI_ACLK(s00_axi_aclk),
		.S_AXI_ARESETN(s00_axi_aresetn),
		.S_AXI_AWADDR(s00_axi_awaddr),
		.S_AXI_AWPROT(s00_axi_awprot),
		.S_AXI_AWVALID(s00_axi_awvalid),
		.S_AXI_AWREADY(s00_axi_awready),
		.S_AXI_WDATA(s00_axi_wdata),
		.S_AXI_WSTRB(s00_axi_wstrb),
		.S_AXI_WVALID(s00_axi_wvalid),
		.S_AXI_WREADY(s00_axi_wready),
		.S_AXI_BRESP(s00_axi_bresp),
		.S_AXI_BVALID(s00_axi_bvalid),
		.S_AXI_BREADY(s00_axi_bready),
		.S_AXI_ARADDR(s00_axi_araddr),
		.S_AXI_ARPROT(s00_axi_arprot),
		.S_AXI_ARVALID(s00_axi_arvalid),
		.S_AXI_ARREADY(s00_axi_arready),
		.S_AXI_RDATA(s00_axi_rdata),
		.S_AXI_RRESP(s00_axi_rresp),
		.S_AXI_RVALID(s00_axi_rvalid),
		.S_AXI_RREADY(s00_axi_rready)
	);

	// Add user logic here
	
    ColorDetect color_detect_core_1 (
        .reset_n(stream_resetn),
        .clk(stream_clk),
        .enable(color_detect_enable),
        
        .DATA_IN(data_in),
        .DATA_IN_VALID(data_vld),
        .X_VALUE(x_value),
        .Y_VALUE(y_value),
        .COLOR(color_1),
        .FRAME_WAIT(num_frames_to_wait),
        
        .X_SUM(xsum_1),
        .Y_SUM(ysum_1),
        .COUNTER(counter_1),
        .READY(ready_out_1)
        
    );

    ColorDetect color_detect_core_2 (
        .reset_n(stream_resetn),
        .clk(stream_clk),
        .enable(color_detect_enable),
        
        .DATA_IN(data_in),
        .DATA_IN_VALID(data_vld),
        .X_VALUE(x_value),
        .Y_VALUE(y_value),
        .COLOR(color_2),
        .FRAME_WAIT(num_frames_to_wait),
        
        .X_SUM(xsum_2),
        .Y_SUM(ysum_2),
        .COUNTER(counter_2),
        .READY(ready_out_2)
        
    );
/*
    ColorDetect color_detect_core_3 (
        .reset_n(stream_resetn),
        .clk(stream_clk),
        .enable(color_detect_enable),
        
        .DATA_IN(data_in),
        .DATA_IN_VALID(data_vld),
        .X_VALUE(x_value),
        .Y_VALUE(y_value),
        .COLOR(color_3),
        .FRAME_WAIT(num_frames_to_wait),
        
        .X_SUM(xsum_3),
        .Y_SUM(ysum_3),
        .COUNTER(counter_3),
        .READY(ready_out_3)
        
    );

    ColorDetect color_detect_core_4 (
        .reset_n(stream_resetn),
        .clk(stream_clk),
        .enable(color_detect_enable),
        
        .DATA_IN(data_in),
        .DATA_IN_VALID(data_vld),
        .X_VALUE(x_value),
        .Y_VALUE(y_value),
        .COLOR(color_4),
        .FRAME_WAIT(num_frames_to_wait),
        
        .X_SUM(xsum_4),
        .Y_SUM(ysum_4),
        .COUNTER(counter_4),
        .READY(ready_out_4)
        
    );
*/
    Stream_Interface stream_interface (

        .stream_data(stream_data),
        .stream_last(stream_last),
        .stream_rdy(stream_rdy),
        .stream_user(stream_user),
        .stream_valid(stream_valid),
        .stream_clk(stream_clk),
        .stream_resetn(stream_resetn),
        
        .DATA_IN(data_in),
        .DATA_IN_VALID(data_vld),
        .X_VALUE(x_value),
        .Y_VALUE(y_value)
        
    );
/*
    //FSM for the outputs x_sum and y_sum
    always @(posedge stream_clk)
      begin
        if (stream_resetn == 0)
          begin
              wait_12_vld <= 0;
              out_12_vld <= 0;
          end
        else
          begin
            if (ready_out_1 && ready_out_2)
              begin
                wait_12_vld <= 1'b1;
                out_12_vld <= 1'b1;
                xsum_12_out <= xsum_1;
                xsum_12_wait <= xsum_2;
                ysum_12_out <= ysum_1;
                ysum_12_wait <= ysum_2;
                counter_12_out <= counter_1;
                counter_12_wait <= counter_2;
              end
            else if (out_12_vld && wait_12_vld)
              begin
                wait_12_vld <= 1'b0;
                xsum_12_out <= xsum_12_wait;
                ysum_12_out <= ysum_12_wait;
                counter_12_out <= counter_12_wait;
              end
            else if (out_12_vld)
              begin
                out_12_vld <= 1'b0;
              end
          end
      end
      assign xsum_12 = xsum_12_out;
      assign ysum_12 = ysum_12_out;
      assign counter_12 = counter_12_out;
      assign ready_out_12 = out_12_vld;
      
      always @(posedge stream_clk)
        begin
          if (stream_resetn == 0)
            begin
                wait_34_vld <= 0;
                out_34_vld <= 0;
            end
          else
            begin
              if (ready_out_3 && ready_out_4)
                begin
                  wait_34_vld <= 1'b1;
                  out_34_vld <= 1'b1;
                  xsum_34_out <= xsum_3;
                  xsum_34_wait <= xsum_4;
                  ysum_34_out <= ysum_3;
                  ysum_34_wait <= ysum_4;
                  counter_34_out <= counter_3;
                  counter_34_wait <= counter_4;
                end
              else if (out_34_vld && wait_34_vld)
                begin
                  wait_34_vld <= 1'b0;
                  xsum_34_out <= xsum_34_wait;
                  ysum_34_out <= ysum_34_wait;
                  counter_34_out <= counter_34_wait;
                end
              else if (out_34_vld)
                begin
                  out_34_vld <= 1'b0;
                end
            end
        end
        assign xsum_34 = xsum_34_out;
        assign ysum_34 = ysum_34_out;
        assign counter_34 = counter_34_out;
        assign ready_out_34 = out_34_vld;
 */     
	// User logic ends

	endmodule
