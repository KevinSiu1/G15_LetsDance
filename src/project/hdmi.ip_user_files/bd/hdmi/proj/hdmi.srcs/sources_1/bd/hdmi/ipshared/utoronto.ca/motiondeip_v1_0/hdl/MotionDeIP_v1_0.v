
`timescale 1 ns / 1 ps

	module MotionDeIP_v1_0 #
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
        input wire ready_x1,
        input wire ready_y1,
        input wire ready_x2,
        input wire ready_y2,       
        input wire [63:0] x1,
        input wire [63:0] y1, 
        input wire [63:0] x2,
        input wire [63:0] y2,       
        output wire s00_axi_color_ctl,
        output wire [1:0] s00_axi_color_c1,
        output wire [1:0] s00_axi_color_c2,
        /*output wire [1:0] s00_axi_color_c3,
        output wire [1:0] s00_axi_color_c4,*/
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
	
	reg [31:0] s00_axi_coord1;
	reg [31:0] s00_axi_coord2;
	/*reg [31:0] s00_axi_coord3;
	reg [31:0] s00_axi_coord4;*/
	
	reg ready_1_x;
	reg ready_1_y;
	reg ready_2_x;
    reg ready_2_y;
    /*reg ready_3_x;
    reg ready_3_y;
    reg ready_4_x;
    reg ready_4_y;*/
    
    reg ready_1;
    reg ready_2;
    /*reg ready_3;
    reg ready_4; 
	
	reg [1:0] state12;
	reg [1:0] state34;*/
	
// Instantiation of Axi Bus Interface S00_AXI
	MotionDeIP_v1_0_S00_AXI # ( 
		.C_S_AXI_DATA_WIDTH(C_S00_AXI_DATA_WIDTH),
		.C_S_AXI_ADDR_WIDTH(C_S00_AXI_ADDR_WIDTH)
	) MotionDeIP_v1_0_S00_AXI_inst (
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
		.S_AXI_RREADY(s00_axi_rready),
        .ready_read_color1(ready_1),
        .ready_read_color2(ready_2),
        /*.ready_read_color3(ready_3),
        .ready_read_color4(ready_4),*/       
        .coord1(s00_axi_coord1),
        .coord2(s00_axi_coord2),
        /*.coord3(s00_axi_coord3),
        .coord4(s00_axi_coord4),*/      
        .color_control(s00_axi_color_ctl),
        .color_choice1(s00_axi_color_c1),
        .color_choice2(s00_axi_color_c2)/*,
        .color_choice3(s00_axi_color_c3),
        .color_choice4(s00_axi_color_c4)*/
	);

	// Add user logic here
    
    always @(posedge s00_axi_aclk)
      begin
        if (!s00_axi_aresetn)
          begin
            s00_axi_coord1 <= 0;
            s00_axi_coord2 <= 0;
            ready_1_x <= 0;
            ready_1_y <= 0;
            ready_2_x <= 0;
            ready_2_y <= 0;
            ready_1 <= 0;
            ready_2 <= 0;
          end
        else
          begin
            if (ready_x1)
              begin
                ready_1_x <= 1'b1;
                s00_axi_coord1[31:16] <= x1[47:32];
              end
            if (ready_y1)
              begin
                ready_1_y <= 1'b1;
                s00_axi_coord1[15:0] <= y1[47:32];
              end
            if (ready_x2)
              begin
                ready_2_x <= 1'b1;
                s00_axi_coord2[31:16] <= x2[47:32];
              end
            if (ready_y2)
              begin
                ready_2_y <= 1'b1;
                s00_axi_coord2[15:0] <= y2[47:32];
              end
              
            if (ready_1_x && ready_1_y)
              begin
                ready_1 <= 1'b1;
                ready_1_x <= 1'b0;
                ready_1_y <= 1'b0;
              end
            else
              begin
                ready_1 <= 1'b0;
              end
              
            if (ready_2_x && ready_2_y)
              begin
                ready_2 <= 1'b1;
                ready_2_x <= 1'b0;
                ready_2_y <= 1'b0;
              end
            else
              begin
                ready_2 <= 1'b0;
              end           
          end
      end

/*	
	//FSM for Colours 1 and 2
	always @(posedge s00_axi_aclk)
	  begin
	    if (!s00_axi_aresetn)
	      begin
	        s00_axi_coord1 <= 0;
	        s00_axi_coord2 <= 0;
	        ready_1_x <= 0;
            ready_1_y <= 0;
            ready_2_x <= 0;
            ready_2_y <= 0;
            state12 <= 0;
	      end
	    else
	      begin
	        //Reset ready_x and ready_y when both are high (send signal to motion detect core)
            if (ready_1_x && ready_1_y)
              begin
                ready_1_x <= 1'b0;
                ready_1_y <= 1'b0;
              end
            if (ready_2_x && ready_2_y)
              begin
                ready_2_x <= 1'b0;
                ready_2_y <= 1'b0;
              end
              
            //FSM 0 indicates waiting for color 1, 1 indicates waiting for color 2. state12[0] - y, state12[1] - x           
            if (state12 == 2'b00)
              begin
                if (ready_x12 && ready_y12)
                  begin
                    ready_1_x <= 1'b1;
                    s00_axi_coord1[31:16] <= x12[47:32];
                    ready_1_y <= 1'b1;
                    s00_axi_coord1[15:0] <= y12[47:32];
                    state12 <= 2'b11;
                  end
                else if (ready_x12)
                  begin
                    ready_1_x <= 1'b1;
                    s00_axi_coord1[31:16] <= x12[47:32];
                    state12 <= 2'b10;
                  end
                else if (ready_y12)
                  begin
                    ready_1_y <= 1'b1;
                    s00_axi_coord1[15:0] <= y12[47:32];
                    state12 <= 2'b01;
                  end
              end
            else if (state12 == 2'b01)
              begin
                if (ready_x12 && ready_y12)
                  begin
                    ready_1_x <= 1'b1;
                    s00_axi_coord1[31:16] <= x12[47:32];
                    ready_2_y <= 1'b1;
                    s00_axi_coord2[15:0] <= y12[47:32];
                    state12 <= 2'b10;
                  end
                else if (ready_x12)
                  begin
                    ready_1_x <= 1'b1;
                    s00_axi_coord1[31:16] <= x12[47:32];
                    state12 <= 2'b11;
                  end
                else if (ready_y12)
                  begin
                    ready_2_y <= 1'b1;
                    s00_axi_coord2[15:0] <= y12[47:32];
                    state12 <= 2'b00;
                  end
              end
            else if (state12 == 2'b10)
              begin
                if (ready_x12 && ready_y12)
                  begin
                    ready_2_x <= 1'b1;
                    s00_axi_coord2[31:16] <= x12[47:32];
                    ready_1_y <= 1'b1;
                    s00_axi_coord1[15:0] <= y12[47:32];
                    state12 <= 2'b01;
                  end
                else if (ready_x12)
                  begin
                    ready_2_x <= 1'b1;
                    s00_axi_coord2[31:16] <= x12[47:32];
                    state12 <= 2'b00;
                  end
                else if (ready_y12)
                  begin
                    ready_1_y <= 1'b1;
                    s00_axi_coord1[15:0] <= y12[47:32];
                    state12 <= 2'b11;
                  end
              end
            else if (state12 == 2'b11)
              begin
                if (ready_x12 && ready_y12)
                  begin
                    ready_2_x <= 1'b1;
                    s00_axi_coord2[31:16] <= x12[47:32];
                    ready_2_y <= 1'b1;
                    s00_axi_coord2[15:0] <= y12[47:32];
                    state12 <= 2'b00;
                  end
                else if (ready_x12)
                  begin
                    ready_2_x <= 1'b1;
                    s00_axi_coord2[31:16] <= x12[47:32];
                    state12 <= 2'b01;
                  end
                else if (ready_y12)
                  begin
                    ready_2_y <= 1'b1;
                    s00_axi_coord2[15:0] <= y12[47:32];
                    state12 <= 2'b10;
                  end
              end
	      end
	  end

    //FSM for Colours 3 and 4
	always @(posedge s00_axi_aclk)
	  begin
	    if (!s00_axi_aresetn)
	      begin
	        s00_axi_coord3 <= 0;
	        s00_axi_coord4 <= 0;
	        ready_3_x <= 0;
            ready_3_y <= 0;
            ready_4_x <= 0;
            ready_4_y <= 0;
            state34 <= 0;
	      end
	    else
	      begin
	        //Reset ready_x and ready_y when both are high (send signal to motion detect core)
            if (ready_3_x && ready_3_y)
              begin
                ready_3_x <= 1'b0;
                ready_3_y <= 1'b0;
              end
            if (ready_4_x && ready_4_y)
              begin
                ready_4_x <= 1'b0;
                ready_4_y <= 1'b0;
              end
              
            //FSM 0 indicates waiting for color 3, 1 indicates waiting for color 4. state34[0] - y, state34[1] - x           
            if (state34 == 2'b00)
              begin
                if (ready_x34 && ready_y34)
                  begin
                    ready_3_x <= 1'b1;
                    s00_axi_coord3[31:16] <= x34[47:32];
                    ready_3_y <= 1'b1;
                    s00_axi_coord3[15:0] <= y34[47:32];
                    state34 <= 2'b11;
                  end
                else if (ready_x34)
                  begin
                    ready_3_x <= 1'b1;
                    s00_axi_coord3[31:16] <= x34[47:32];
                    state34 <= 2'b10;
                  end
                else if (ready_y34)
                  begin
                    ready_3_y <= 1'b1;
                    s00_axi_coord3[15:0] <= y34[47:32];
                    state34 <= 2'b01;
                  end
              end
            else if (state34 == 2'b01)
              begin
                if (ready_x34 && ready_y34)
                  begin
                    ready_3_x <= 1'b1;
                    s00_axi_coord3[31:16] <= x34[47:32];
                    ready_4_y <= 1'b1;
                    s00_axi_coord4[15:0] <= y34[47:32];
                    state34 <= 2'b10;
                  end
                else if (ready_x34)
                  begin
                    ready_3_x <= 1'b1;
                    s00_axi_coord3[31:16] <= x34[47:32];
                    state34 <= 2'b11;
                  end
                else if (ready_y34)
                  begin
                    ready_4_y <= 1'b1;
                    s00_axi_coord4[15:0] <= y34[47:32];
                    state34 <= 2'b00;
                  end
              end
            else if (state34 == 2'b10)
              begin
                if (ready_x34 && ready_y34)
                  begin
                    ready_4_x <= 1'b1;
                    s00_axi_coord4[31:16] <= x34[47:32];
                    ready_3_y <= 1'b1;
                    s00_axi_coord3[15:0] <= y34[47:32];
                    state34 <= 2'b01;
                  end
                else if (ready_x34)
                  begin
                    ready_4_x <= 1'b1;
                    s00_axi_coord4[31:16] <= x34[47:32];
                    state34 <= 2'b00;
                  end
                else if (ready_y34)
                  begin
                    ready_3_y <= 1'b1;
                    s00_axi_coord3[15:0] <= y34[47:32];
                    state34 <= 2'b11;
                  end
              end
            else if (state12 == 2'b11)
              begin
                if (ready_x34 && ready_y34)
                  begin
                    ready_4_x <= 1'b1;
                    s00_axi_coord4[31:16] <= x34[47:32];
                    ready_4_y <= 1'b1;
                    s00_axi_coord4[15:0] <= y34[47:32];
                    state34 <= 2'b00;
                  end
                else if (ready_x34)
                  begin
                    ready_4_x <= 1'b1;
                    s00_axi_coord4[31:16] <= x34[47:32];
                    state34 <= 2'b01;
                  end
                else if (ready_y34)
                  begin
                    ready_4_y <= 1'b1;
                    s00_axi_coord4[15:0] <= y34[47:32];
                    state34 <= 2'b10;
                  end
              end
	      end
	  end
	  
	  always @(posedge s00_axi_aclk)
	    begin
	      if (!s00_axi_aresetn)
	        begin
	          ready_1 <= 0;
	          ready_2 <= 0;
	          ready_3 <= 0;
	          ready_4 <= 0;
	        end
	      else
	        begin
              ready_1 <= (ready_1_x && ready_1_y) ? 1 : 0;
              ready_2 <= (ready_2_x && ready_2_y) ? 1 : 0;
              ready_3 <= (ready_3_x && ready_3_y) ? 1 : 0;
              ready_4 <= (ready_4_x && ready_4_y) ? 1 : 0;
	        end
	    end
*/	  
	// User logic ends

	endmodule
