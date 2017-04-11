
`timescale 1 ns / 1 ps

	module MotionDeIP_v1_0_S00_AXI #
	(
		// Users to add parameters here
	    parameter integer thr1	= 30,
        parameter integer thr2    = 130,
        parameter integer thr3	= 80,
        parameter integer thr4  = 150,
        parameter integer thr5    = 80,
		// User parameters ends
		// Do not modify the parameters beyond this line

		// Width of S_AXI data bus
		parameter integer C_S_AXI_DATA_WIDTH	= 32,
		// Width of S_AXI address bus
		parameter integer C_S_AXI_ADDR_WIDTH	= 4
	)
	(
		// Users to add ports here
        input wire ready_read_color1,
        input wire ready_read_color2,
        /*input wire ready_read_color3,
        input wire ready_read_color4,*/       
        input wire [31:0] coord1,
        input wire [31:0] coord2,
        /*input wire [31:0] coord3,
        input wire [31:0] coord4,*/     
        output color_control,
        output [1:0] color_choice1,
        output [1:0] color_choice2,
        /*output [1:0] color_choice3,
        output [1:0] color_choice4,*/

		// User ports ends
		// Do not modify the ports beyond this line

		// Global Clock Signal
		input wire  S_AXI_ACLK,
		// Global Reset Signal. This Signal is Active LOW
		input wire  S_AXI_ARESETN,
		// Write address (issued by master, acceped by Slave)
		input wire [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_AWADDR,
		// Write channel Protection type. This signal indicates the
    		// privilege and security level of the transaction, and whether
    		// the transaction is a data access or an instruction access.
		input wire [2 : 0] S_AXI_AWPROT,
		// Write address valid. This signal indicates that the master signaling
    		// valid write address and control information.
		input wire  S_AXI_AWVALID,
		// Write address ready. This signal indicates that the slave is ready
    		// to accept an address and associated control signals.
		output wire  S_AXI_AWREADY,
		// Write data (issued by master, acceped by Slave) 
		input wire [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_WDATA,
		// Write strobes. This signal indicates which byte lanes hold
    		// valid data. There is one write strobe bit for each eight
    		// bits of the write data bus.    
		input wire [(C_S_AXI_DATA_WIDTH/8)-1 : 0] S_AXI_WSTRB,
		// Write valid. This signal indicates that valid write
    		// data and strobes are available.
		input wire  S_AXI_WVALID,
		// Write ready. This signal indicates that the slave
    		// can accept the write data.
		output wire  S_AXI_WREADY,
		// Write response. This signal indicates the status
    		// of the write transaction.
		output wire [1 : 0] S_AXI_BRESP,
		// Write response valid. This signal indicates that the channel
    		// is signaling a valid write response.
		output wire  S_AXI_BVALID,
		// Response ready. This signal indicates that the master
    		// can accept a write response.
		input wire  S_AXI_BREADY,
		// Read address (issued by master, acceped by Slave)
		input wire [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_ARADDR,
		// Protection type. This signal indicates the privilege
    		// and security level of the transaction, and whether the
    		// transaction is a data access or an instruction access.
		input wire [2 : 0] S_AXI_ARPROT,
		// Read address valid. This signal indicates that the channel
    		// is signaling valid read address and control information.
		input wire  S_AXI_ARVALID,
		// Read address ready. This signal indicates that the slave is
    		// ready to accept an address and associated control signals.
		output wire  S_AXI_ARREADY,
		// Read data (issued by slave)
		output wire [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_RDATA,
		// Read response. This signal indicates the status of the
    		// read transfer.
		output wire [1 : 0] S_AXI_RRESP,
		// Read valid. This signal indicates that the channel is
    		// signaling the required read data.
		output wire  S_AXI_RVALID,
		// Read ready. This signal indicates that the master can
    		// accept the read data and response information.
		input wire  S_AXI_RREADY
	);

	// AXI4LITE signals
	reg [C_S_AXI_ADDR_WIDTH-1 : 0] 	axi_awaddr;
	reg  	axi_awready;
	reg  	axi_wready;
	reg [1 : 0] 	axi_bresp;
	reg  	axi_bvalid;
	reg [C_S_AXI_ADDR_WIDTH-1 : 0] 	axi_araddr;
	reg  	axi_arready;
	reg [C_S_AXI_DATA_WIDTH-1 : 0] 	axi_rdata;
	reg [1 : 0] 	axi_rresp;
	reg  	axi_rvalid;

        reg [4:0] color_code_n_ctrl;
        reg [1:0] color_ready;
        reg [31:0] currP1;
        reg [31:0] currP2;
        /*reg [31:0] currP3;
        reg [31:0] currP4;*/
        reg [3:0] counter1;
        reg [3:0] counter2;
        /*reg [3:0] counter3;
        reg [3:0] counter4;*/
        reg [31:0] prevP1;
        reg [31:0] prevP2;
        /*reg [31:0] prevP3;
        reg [31:0] prevP4;*/
        reg [31:0] nextiniP1;
        reg [31:0] nextiniP2;
        /*reg [31:0] nextiniP3;
        reg [31:0] nextiniP4;*/
        reg [31:0] iniP1;
        reg [31:0] iniP2;
        /*reg [31:0] iniP3;
        reg [31:0] iniP4;*/
        reg [1:0] onTrack1;
        reg [1:0] onTrack2;
        /*reg onTrack3;
        reg onTrack4;*/
        reg [1:0] prevOnTrack1;
        reg [1:0] prevOnTrack2;
        /*reg prevOnTrack3;
        reg prevOnTrack4;*/
        reg [15:0] deltaX1;
        reg [15:0] deltaX2;
        /*reg [15:0] deltaX3;
        reg [15:0] deltaX4;*/
        reg [15:0] deltaY1;
        reg [15:0] deltaY2;
        /*reg [15:0] deltaY3;
        reg [15:0] deltaY4;*/
        reg [15:0] dispX1;
        reg [15:0] dispX2;
        /*reg [15:0] dispX3;
        reg [15:0] dispX4;*/
        reg [15:0] dispY1;
        reg [15:0] dispY2;
        /*reg [15:0] dispY3;
        reg [15:0] dispY4;*/
        reg result1;
        reg result2;
        /*reg result3;
        reg result4;*/
        reg signed [31:0] conc1;
        reg signed [31:0] conc2;
        reg signed [31:0] prevConc1;
        reg signed [31:0] prevConc2;
        reg signed [31:0] checkConc_sec1_1;
        reg signed [31:0] checkConc_sec1_2;
        reg signed [31:0] checkConc_sec2_1;
        reg signed [31:0] checkConc_sec2_2;
        reg signed [31:0] tempConc1;
        reg signed [31:0] tempConc2;
        reg [31:0] iniP_c1;
        reg [31:0] iniP_c2;
        reg [31:0] nextIniP_c1;
        reg [31:0] nextIniP_c2;
        //reg signed [16:0] sn1,
        //reg signed [16:0] sn2,
        reg signed [16:0] sn3;
        reg signed [16:0] sn4;
        reg signed [16:0] sn5;
        reg signed [16:0] sn6;
        reg signed [16:0] sn7;
        reg signed [16:0] sn8;
        reg signed [16:0] sn9;
        reg signed [16:0] sn10;
        reg signed [16:0] sn11;
        reg signed [16:0] sn12;
        reg signed [16:0] sn13;
        reg signed [16:0] sn14;

	// Example-specific design signals
	// local parameter for addressing 32 bit / 64 bit C_S_AXI_DATA_WIDTH
	// ADDR_LSB is used for addressing 32/64 bit registers/memories
	// ADDR_LSB = 2 for 32 bits (n downto 2)
	// ADDR_LSB = 3 for 64 bits (n downto 3)
	localparam integer ADDR_LSB = (C_S_AXI_DATA_WIDTH/32) + 1;
	localparam integer OPT_MEM_ADDR_BITS = 1;
	//----------------------------------------------
	//-- Signals for user logic register space example
	//------------------------------------------------
	//-- Number of Slave Registers 4
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg0;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg1;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg2;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg3;
	wire	 slv_reg_rden;
	wire	 slv_reg_wren;
	reg [C_S_AXI_DATA_WIDTH-1:0]	 reg_data_out;
	integer	 byte_index;

	// I/O Connections assignments

	assign S_AXI_AWREADY	= axi_awready;
	assign S_AXI_WREADY	= axi_wready;
	assign S_AXI_BRESP	= axi_bresp;
	assign S_AXI_BVALID	= axi_bvalid;
	assign S_AXI_ARREADY	= axi_arready;
	assign S_AXI_RDATA	= axi_rdata;
	assign S_AXI_RRESP	= axi_rresp;
	assign S_AXI_RVALID	= axi_rvalid;
	// Implement axi_awready generation
	// axi_awready is asserted for one S_AXI_ACLK clock cycle when both
	// S_AXI_AWVALID and S_AXI_WVALID are asserted. axi_awready is
	// de-asserted when reset is low.

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_awready <= 1'b0;
	    end 
	  else
	    begin    
	      if (~axi_awready && S_AXI_AWVALID && S_AXI_WVALID)
	        begin
	          // slave is ready to accept write address when 
	          // there is a valid write address and write data
	          // on the write address and data bus. This design 
	          // expects no outstanding transactions. 
	          axi_awready <= 1'b1;
	        end
	      else           
	        begin
	          axi_awready <= 1'b0;
	        end
	    end 
	end       

	// Implement axi_awaddr latching
	// This process is used to latch the address when both 
	// S_AXI_AWVALID and S_AXI_WVALID are valid. 

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_awaddr <= 0;
	    end 
	  else
	    begin    
	      if (~axi_awready && S_AXI_AWVALID && S_AXI_WVALID)
	        begin
	          // Write Address latching 
	          axi_awaddr <= S_AXI_AWADDR;
	        end
	    end 
	end       

	// Implement axi_wready generation
	// axi_wready is asserted for one S_AXI_ACLK clock cycle when both
	// S_AXI_AWVALID and S_AXI_WVALID are asserted. axi_wready is 
	// de-asserted when reset is low. 

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_wready <= 1'b0;
	    end 
	  else
	    begin    
	      if (~axi_wready && S_AXI_WVALID && S_AXI_AWVALID)
	        begin
	          // slave is ready to accept write data when 
	          // there is a valid write address and write data
	          // on the write address and data bus. This design 
	          // expects no outstanding transactions. 
	          axi_wready <= 1'b1;
	        end
	      else
	        begin
	          axi_wready <= 1'b0;
	        end
	    end 
	end       

	// Implement memory mapped register select and write logic generation
	// The write data is accepted and written to memory mapped registers when
	// axi_awready, S_AXI_WVALID, axi_wready and S_AXI_WVALID are asserted. Write strobes are used to
	// select byte enables of slave registers while writing.
	// These registers are cleared when reset (active low) is applied.
	// Slave register write enable is asserted when valid address and data are available
	// and the slave is ready to accept the write address and write data.
	assign slv_reg_wren = axi_wready && S_AXI_WVALID && axi_awready && S_AXI_AWVALID;

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      slv_reg0 <= 0;
	      //slv_reg2 <= 0;
	      //slv_reg3 <= 0;
	    end 
	  else begin
	    if (slv_reg_wren)
	      begin
	        case ( axi_awaddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] )
	          2'h0: begin
	            if (S_AXI_WDATA[0]) begin
                    for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
                      if ( S_AXI_WSTRB[byte_index] == 1 ) begin
                        // Respective byte enables are asserted as per write strobes 
                        // Slave register 0
                        slv_reg0[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
                      end
                 end
	             else
	               slv_reg0[0]<=0;
	          end       
	          /*2'h2:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 2
	                slv_reg2[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end*/  
	          /*2'h3:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 3
	                slv_reg3[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end*/  
	          default : begin
	                      slv_reg0 <= slv_reg0;
	                      //slv_reg2 <= slv_reg2;
	                      //slv_reg3 <= slv_reg3;
	                    end
	        endcase
	      end
	  end
	end    
	
	
	

	// Implement write response logic generation
	// The write response and response valid signals are asserted by the slave 
	// when axi_wready, S_AXI_WVALID, axi_wready and S_AXI_WVALID are asserted.  
	// This marks the acceptance of address and indicates the status of 
	// write transaction.

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_bvalid  <= 0;
	      axi_bresp   <= 2'b0;
	    end 
	  else
	    begin    
	      if (axi_awready && S_AXI_AWVALID && ~axi_bvalid && axi_wready && S_AXI_WVALID)
	        begin
	          // indicates a valid write response is available
	          axi_bvalid <= 1'b1;
	          axi_bresp  <= 2'b0; // 'OKAY' response 
	        end                   // work error responses in future
	      else
	        begin
	          if (S_AXI_BREADY && axi_bvalid) 
	            //check if bready is asserted while bvalid is high) 
	            //(there is a possibility that bready is always asserted high)   
	            begin
	              axi_bvalid <= 1'b0; 
	            end  
	        end
	    end
	end   

	// Implement axi_arready generation
	// axi_arready is asserted for one S_AXI_ACLK clock cycle when
	// S_AXI_ARVALID is asserted. axi_awready is 
	// de-asserted when reset (active low) is asserted. 
	// The read address is also latched when S_AXI_ARVALID is 
	// asserted. axi_araddr is reset to zero on reset assertion.

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_arready <= 1'b0;
	      axi_araddr  <= 32'b0;
	    end 
	  else
	    begin    
	      if (~axi_arready && S_AXI_ARVALID)
	        begin
	          // indicates that the slave has acceped the valid read address
	          axi_arready <= 1'b1;
	          // Read address latching
	          axi_araddr  <= S_AXI_ARADDR;
	        end
	      else
	        begin
	          axi_arready <= 1'b0;
	        end
	    end 
	end       

	// Implement axi_arvalid generation
	// axi_rvalid is asserted for one S_AXI_ACLK clock cycle when both 
	// S_AXI_ARVALID and axi_arready are asserted. The slave registers 
	// data are available on the axi_rdata bus at this instance. The 
	// assertion of axi_rvalid marks the validity of read data on the 
	// bus and axi_rresp indicates the status of read transaction.axi_rvalid 
	// is deasserted on reset (active low). axi_rresp and axi_rdata are 
	// cleared to zero on reset (active low).  
	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_rvalid <= 0;
	      axi_rresp  <= 0;
	    end 
	  else
	    begin    
	      if (axi_arready && S_AXI_ARVALID && ~axi_rvalid)
	        begin
	          // Valid read data is available at the read data bus
	          axi_rvalid <= 1'b1;
	          axi_rresp  <= 2'b0; // 'OKAY' response
	        end   
	      else if (axi_rvalid && S_AXI_RREADY)
	        begin
	          // Read data is accepted by the master
	          axi_rvalid <= 1'b0;
	        end                
	    end
	end    

	// Implement memory mapped register select and read logic generation
	// Slave register read enable is asserted when valid address is available
	// and the slave is ready to accept the read address.
	assign slv_reg_rden = axi_arready & S_AXI_ARVALID & ~axi_rvalid;
	always @(*)
	begin
	      // Address decoding for reading registers
	      case ( axi_araddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] )
	        2'h0   : reg_data_out <= slv_reg0;
	        2'h1   : reg_data_out <= slv_reg1;
	        2'h2   : reg_data_out <= slv_reg2;
	        2'h3   : reg_data_out <= slv_reg3;
	        default : reg_data_out <= 0;
	      endcase
	end

	// Output register or memory read data
	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_rdata  <= 0;
	    end 
	  else
	    begin    
	      // When there is a valid read address (S_AXI_ARVALID) with 
	      // acceptance of read address by the slave (axi_arready), 
	      // output the read dada 
	      if (slv_reg_rden)
	        begin
	          axi_rdata <= reg_data_out;     // register read data
	        end   
	    end
	end    

	// Add user logic here
                      
	always @( posedge S_AXI_ACLK )
    begin
        if ( S_AXI_ARESETN == 1'b0 )
          begin
            color_ready <= 0;
          end 
        else begin
          if (slv_reg_wren && axi_awaddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] == 2'h0 && S_AXI_WDATA[0]) begin
             color_ready <= 0;
          end 
          else begin
              color_ready[0] <= ready_read_color1;
              color_ready[1] <= ready_read_color2;
              /*color_ready[2] <= ready_read_color3;
              color_ready[3] <= ready_read_color4;*/
          end
        end  
    end
        
        
        
 // ----------------------------------------------------------------------------------------------------------------
  always @( posedge S_AXI_ACLK )
   begin
       if ( S_AXI_ARESETN == 1'b0 )
         begin
             currP1 <= 0;
             prevP1 <= 0;
             prevOnTrack1 <= 0;
             iniP1 <= 0;
             iniP_c1 <= 0;
             prevConc1 <= 0;
             counter1 <= 0;
         end 
       else begin
         if (slv_reg_wren && axi_awaddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] == 2'h0 && S_AXI_WDATA[0]) begin
             currP1 <= 0;
             prevP1 <= 0;
             prevOnTrack1 <= 0;
             iniP1 <= 0;
             iniP_c1 <= 0;
             prevConc1 <= 0;
             counter1 <= 0;
         end 
         else begin
          if (counter1!=10) begin
              if (color_code_n_ctrl[0]) begin
                 if (color_ready[0])  begin
                     currP1 <= coord1;
                     prevP1 <= currP1;
                     iniP1 <= nextiniP1;
                     iniP_c1 <= nextIniP_c1;
                     prevConc1 <= conc1;
                     counter1 <= counter1 + 1;
                     if (counter1>1)   prevOnTrack1 <= onTrack1;
                 end
               end
          end
         end          
       end
   end
   
   
   always @( posedge S_AXI_ACLK )
   begin
       if ( S_AXI_ARESETN == 1'b0 )
         begin
             currP2 <= 0;
             prevP2 <= 0;
             prevOnTrack2 <= 0;
             iniP2 <= 0;
             iniP_c2 <= 0;
             prevConc2 <= 0;
             counter2 <= 0;
         end 
       else begin
         if (slv_reg_wren && axi_awaddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] == 2'h0 && S_AXI_WDATA[0]) begin
             currP2 <= 0;
             prevP2 <= 0;
             prevOnTrack2 <= 0;
             iniP2 <= 0;
             iniP_c2 <= 0;
             prevConc2 <= 0;
             counter2 <= 0;
         end 
         else begin
          if (counter2!=10) begin
              if (color_code_n_ctrl[0]) begin
                 if (color_ready[1])  begin
                     currP2 <= coord2;
                     prevP2 <= currP2;
                     iniP2 <= nextiniP2;
                     iniP_c2 <= nextIniP_c2;
                     prevConc2 <= conc2;
                     counter2 <= counter2 + 1;
                     if (counter2>1)   prevOnTrack2 <= onTrack2;
                 end
               end
          end
         end          
       end
   end
    
/*    
    always @( posedge S_AXI_ACLK )
    begin
        if ( S_AXI_ARESETN == 1'b0 )
          begin
              currP3 <= 0;
              prevP3 <= 0;
              prevOnTrack3 <= 0;
              iniP3 <= 0;
              counter3 <= 0;
          end 
        else begin
          if (slv_reg_wren && axi_awaddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] == 2'h0 && S_AXI_WDATA[0]) begin
              currP3 <= 0;
              prevP3 <= 0;
              prevOnTrack3 <= 0;
              iniP3 <= 0;
              counter3 <= 0;
          end 
          else begin
           if (counter3!=10) begin
               if (color_code_n_ctrl[0]) begin
                  if (color_ready[2])  begin
                      currP3 <= coord3;
                      prevP3 <= currP3;
                      iniP3 <= nextiniP3;
                      counter3 <= counter3 + 1;
                      if (counter3>1)   prevOnTrack3 <= onTrack3;
                  end
                end
           end
          end          
        end
    end
    
    
    always @( posedge S_AXI_ACLK )
    begin
        if ( S_AXI_ARESETN == 1'b0 )
          begin
              currP4 <= 0;
              prevP4 <= 0;
              prevOnTrack4 <= 0;
              iniP4 <= 0;
              counter4 <= 0;
          end 
        else begin
          if (slv_reg_wren && axi_awaddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] == 2'h0 && S_AXI_WDATA[0]) begin
              currP4 <= 0;
              prevP4 <= 0;
              prevOnTrack4 <= 0;
              iniP4 <= 0;
              counter4 <= 0;
          end 
          else begin
           if (counter4!=10) begin
               if (color_code_n_ctrl[0]) begin
                  if (color_ready[3])  begin
                      currP4 <= coord4;
                      prevP4 <= currP4;
                      iniP4 <= nextiniP4;
                      counter4 <= counter4 + 1;
                      if (counter4>1)   prevOnTrack4 <= onTrack4;
                  end
                end
           end
          end          
        end
    end
*/    
     
    
// -------------------------------------------------------------------------------------------------------------------
    
    always@(currP1, prevP1, iniP1, prevOnTrack1)
    begin
        case(slv_reg0[19:16])
            4'b0000: //right
            begin
                if (prevOnTrack1==2'b00) begin
                    if ((((currP1[15:0]>prevP1[15:0])&&(currP1[15:0]-prevP1[15:0]<thr1)) || ((currP1[15:0]<=prevP1[15:0])&&(prevP1[15:0]-currP1[15:0]<thr1))) && (currP1[31:16]>prevP1[31:16]))
                        onTrack1=2'b01;
                    else onTrack1 = 2'b00;
                end
                else begin
                    if ((((currP1[15:0]>iniP1[15:0])&&(currP1[15:0]-iniP1[15:0]<thr1)) || ((currP1[15:0]<=iniP1[15:0])&&(iniP1[15:0]-currP1[15:0]<thr1))) && (currP1[31:16]>prevP1[31:16]))
                       onTrack1=2'b01;
                    else onTrack1 = 2'b00;
                end
            end
            4'b0001: //left
            begin
                if (prevOnTrack1==2'b00) begin
                    if ((((currP1[15:0]>prevP1[15:0])&&(currP1[15:0]-prevP1[15:0]<thr1)) || ((currP1[15:0]<=prevP1[15:0])&&(prevP1[15:0]-currP1[15:0]<thr1))) && (currP1[31:16]<prevP1[31:16]))
                       onTrack1=2'b01;
                    else onTrack1 = 2'b00;
                end
                else begin
                    if ((((currP1[15:0]>iniP1[15:0])&&(currP1[15:0]-iniP1[15:0]<thr1)) || ((currP1[15:0]<=iniP1[15:0])&&(iniP1[15:0]-currP1[15:0]<thr1))) && (currP1[31:16]<prevP1[31:16]))
                       onTrack1=2'b01;
                    else onTrack1 = 2'b00;
                end
            end
            4'b0010: //up
            begin
                if (prevOnTrack1==0) begin
                    if ((((currP1[31:16]>prevP1[31:16])&&(currP1[31:16]-prevP1[31:16]<thr1)) || ((currP1[31:16]<=prevP1[31:16])&&(prevP1[31:16]-currP1[31:16]<thr1))) && (currP1[15:0]<prevP1[15:0]))
                       onTrack1=2'b01;
                    else onTrack1 = 2'b00;
                end
                else begin
                    if ((((currP1[31:16]>iniP1[31:16])&&(currP1[31:16]-iniP1[31:16]<thr1)) || ((currP1[31:16]<=iniP1[31:16])&&(iniP1[31:16]-currP1[31:16]<thr1))) && (currP1[15:0]<prevP1[15:0]))
                       onTrack1=2'b01;
                    else onTrack1 = 2'b00;
                end
            end
            4'b0011: //down
            begin
                if (prevOnTrack1==0) begin
                    if ((((currP1[31:16]>prevP1[31:16])&&(currP1[31:16]-prevP1[31:16]<thr1)) || ((currP1[31:16]<=prevP1[31:16])&&(prevP1[31:16]-currP1[31:16]<thr1))) && (currP1[15:0]>prevP1[15:0]))
                      onTrack1=2'b01;
                    else onTrack1 = 2'b00;
                end
                else begin
                    if ((((currP1[31:16]>iniP1[31:16])&&(currP1[31:16]-iniP1[31:16]<thr1)) || ((currP1[31:16]<=iniP1[31:16])&&(iniP1[31:16]-currP1[31:16]<thr1))) && (currP1[15:0]>prevP1[15:0]))
                       onTrack1=2'b01;
                    else onTrack1 = 2'b00;
                end
            end
            4'b0100: // arc-moves up from right
            begin
                if (prevOnTrack1==0) begin
                    if ((currP1[31:16]>prevP1[31:16]) && (currP1[15:0]<prevP1[15:0]))
                        onTrack1=2'b01;
                    else onTrack1 = 2'b00;
                end
                else begin
                    if (currP1[15:0]>prevP1[15:0])   onTrack1 = 2'b00;
                    else begin
                        if (prevOnTrack1==2'b01) begin
                            if (currP1[31:16]<=prevP1[31:16]) begin
                                if ((prevP1[31:16]>iniP1[31:16])&&(prevP1[31:16]-iniP1[31:16]<thr3))   onTrack1 = 2'b00;
                                else begin
                                    if (checkConc_sec1_1>=0)  onTrack1 = 2'b10;
                                    else onTrack1 = 2'b00;
                                end
                            end
                        end
                        else begin
                            if (currP1[31:16]>prevP1[31:16])  onTrack1 = 2'b00;        
                        end
                    end
                end
            end
            //////////////////////////////////////////////////////////////
            4'b0101: // arc-moves down from right
            begin
                if (prevOnTrack1==0) begin
                    if ((currP1[31:16]>prevP1[31:16]) && (currP1[15:0]>prevP1[15:0]))
                        onTrack1=2'b01;
                    else onTrack1 = 2'b00;
                end
                else begin
                    if (currP1[15:0]<prevP1[15:0])   onTrack1 = 2'b00;
                    else begin
                        if (prevOnTrack1==2'b01) begin
                            if (currP1[31:16]<=prevP1[31:16]) begin
                                if ((prevP1[31:16]>iniP1[31:16])&&(prevP1[31:16]-iniP1[31:16]<thr3))   onTrack1 = 2'b00;
                                else begin
                                    if (checkConc_sec1_1<=0)  onTrack1 = 2'b10;
                                    else onTrack1 = 2'b00;
                                end
                            end
                        end
                        else begin
                            if (currP1[31:16]>prevP1[31:16])  onTrack1 = 2'b00;        
                        end
                    end
                end
            end
            4'b0110: // arc-moves up from left
            begin
                if (prevOnTrack1==0) begin
                    if ((currP1[31:16]<prevP1[31:16]) && (currP1[15:0]<prevP1[15:0]))
                        onTrack1=2'b01;
                    else onTrack1 = 2'b00;
                end
                else begin
                    if (currP1[15:0]>prevP1[15:0])   onTrack1 = 2'b00;
                    else begin
                        if (prevOnTrack1==2'b01) begin
                            if (currP1[31:16]>=prevP1[31:16]) begin
                                if ((prevP1[31:16]<iniP1[31:16])&&(iniP1[31:16]-prevP1[31:16]<thr3))   onTrack1 = 2'b00;
                                else begin
                                    if (checkConc_sec1_1<=0)  onTrack1 = 2'b10;
                                    else onTrack1 = 2'b00;
                                end
                            end
                        end
                        else begin
                            if (currP1[31:16]<prevP1[31:16])  onTrack1 = 2'b00;        
                        end
                    end
                end
            end
            4'b0111: // arc-moves down from left
            begin
                if (prevOnTrack1==0) begin
                    if ((currP1[31:16]<prevP1[31:16]) && (currP1[15:0]>prevP1[15:0]))
                        onTrack1=2'b01;
                    else onTrack1 = 2'b00;
                end
                else begin
                    if (currP1[15:0]<prevP1[15:0])   onTrack1 = 2'b00;
                    else begin
                        if (prevOnTrack1==2'b01) begin
                            if (currP1[31:16]>=prevP1[31:16]) begin
                                if ((prevP1[31:16]<iniP1[31:16])&&(iniP1[31:16]-prevP1[31:16]<thr3))   onTrack1 = 2'b00;
                                else begin
                                    if (checkConc_sec1_1>=0)  onTrack1 = 2'b10;
                                    else onTrack1 = 2'b00;
                                end
                            end
                        end
                        else begin
                            if (currP1[31:16]<prevP1[31:16])  onTrack1 = 2'b00;        
                        end
                    end
                end
            end
            4'b1000: // arc-moves to the right from top
            begin
                if (prevOnTrack1==0) begin
                    if ((currP1[31:16]>prevP1[31:16]) && (currP1[15:0]<prevP1[15:0]))
                        onTrack1=2'b01;
                    else onTrack1 = 2'b00;
                end
                else begin
                    if (currP1[31:16]<prevP1[31:16])   onTrack1 = 2'b00;
                    else begin
                        if (prevOnTrack1==2'b01) begin
                            if (currP1[15:0]>=prevP1[15:0]) begin
                                if ((prevP1[15:0]<iniP1[15:0])&&(iniP1[15:0]-prevP1[15:0]<thr3))   onTrack1 = 2'b00;
                                else begin
                                    if (checkConc_sec1_1<=0)  onTrack1 = 2'b10;
                                    else onTrack1 = 2'b00;
                                end
                            end
                        end
                        else begin
                            if (currP1[15:0]<prevP1[15:0])  onTrack1 = 2'b00;        
                        end
                    end
                end
            end
            4'b1001: // arc-moves to the left from top
            begin
                if (prevOnTrack1==0) begin
                    if ((currP1[31:16]<prevP1[31:16]) && (currP1[15:0]<prevP1[15:0]))
                        onTrack1=2'b01;
                    else onTrack1 = 2'b00;
                end
                else begin
                    if (currP1[31:16]>prevP1[31:16])   onTrack1 = 2'b00;
                    else begin
                        if (prevOnTrack1==2'b01) begin
                            if (currP1[15:0]>=prevP1[15:0]) begin
                                if ((prevP1[15:0]<iniP1[15:0])&&(iniP1[15:0]-prevP1[15:0]<thr3))   onTrack1 = 2'b00;
                                else begin
                                    if (checkConc_sec1_1>=0)  onTrack1 = 2'b10;
                                    else onTrack1 = 2'b00;
                                end
                            end
                        end
                        else begin
                            if (currP1[15:0]>prevP1[15:0])  onTrack1 = 2'b00;        
                        end
                    end
                end
            end
            4'b1010: // arc-moves to the right from bottom
            begin
                if (prevOnTrack1==0) begin
                    if ((currP1[31:16]>prevP1[31:16]) && (currP1[15:0]>prevP1[15:0]))
                        onTrack1=2'b01;
                    else onTrack1 = 2'b00;
                end
                else begin
                    if (currP1[31:16]<prevP1[31:16])   onTrack1 = 2'b00;
                    else begin
                        if (prevOnTrack1==2'b01) begin
                            if (currP1[15:0]<=prevP1[15:0]) begin
                                if ((prevP1[15:0]>iniP1[15:0])&&(prevP1[15:0]-iniP1[15:0]<thr3))   onTrack1 = 2'b00;
                                else begin
                                    if (checkConc_sec1_1>=0)  onTrack1 = 2'b10;
                                    else onTrack1 = 2'b00;
                                end
                            end
                        end
                        else begin
                            if (currP1[15:0]>prevP1[15:0])  onTrack1 = 2'b00;        
                        end
                    end
                end
            end
            4'b1011: // arc-moves to the left from bottom
            begin
                if (prevOnTrack1==0) begin
                    if ((currP1[31:16]<prevP1[31:16]) && (currP1[15:0]>prevP1[15:0]))
                        onTrack1=2'b01;
                    else onTrack1 = 2'b00;
                end
                else begin
                    if (currP1[31:16]>prevP1[31:16])   onTrack1 = 2'b00;
                    else begin
                        if (prevOnTrack1==2'b01) begin
                            if (currP1[15:0]<=prevP1[15:0]) begin
                                if ((prevP1[15:0]>iniP1[15:0])&&(prevP1[15:0]-iniP1[15:0]<thr3))   onTrack1 = 2'b00;
                                else begin
                                    if (checkConc_sec1_1<=0)  onTrack1 = 2'b10;
                                    else onTrack1 = 2'b00;
                                end
                            end
                        end
                        else begin
                            if (currP1[15:0]>prevP1[15:0])  onTrack1 = 2'b00;        
                        end
                    end
                end
            end
            default: onTrack1 = 2'b00;
        endcase    
    end
    
    
    
    always@(currP2, prevP2, iniP2, prevOnTrack2)
    begin
        case(slv_reg0[23:20])
            4'b0000: //right
            begin
                if (prevOnTrack2==2'b00) begin
                    if ((((currP2[15:0]>prevP2[15:0])&&(currP2[15:0]-prevP2[15:0]<thr1)) || ((currP2[15:0]<=prevP2[15:0])&&(prevP2[15:0]-currP2[15:0]<thr1))) && (currP2[31:16]>prevP2[31:16]))
                        onTrack2=2'b01;
                    else onTrack2 = 2'b00;
                end
                else begin
                    if ((((currP2[15:0]>iniP2[15:0])&&(currP2[15:0]-iniP2[15:0]<thr1)) || ((currP2[15:0]<=iniP2[15:0])&&(iniP2[15:0]-currP2[15:0]<thr1))) && (currP2[31:16]>prevP2[31:16]))
                       onTrack2=2'b01;
                    else onTrack2 = 2'b01;
                end
            end
            4'b0001: //left
            begin
                if (prevOnTrack2==2'b00) begin
                    if ((((currP2[15:0]>prevP2[15:0])&&(currP2[15:0]-prevP2[15:0]<thr1)) || ((currP2[15:0]<=prevP2[15:0])&&(prevP2[15:0]-currP2[15:0]<thr1))) && (currP2[31:16]<prevP2[31:16]))
                       onTrack2=2'b01;
                    else onTrack2 = 2'b00;
                end
                else begin
                    if ((((currP2[15:0]>iniP2[15:0])&&(currP2[15:0]-iniP2[15:0]<thr1)) || ((currP2[15:0]<=iniP2[15:0])&&(iniP2[15:0]-currP2[15:0]<thr1))) && (currP2[31:16]<prevP2[31:16]))
                       onTrack2=2'b01;
                    else onTrack2 = 2'b00;
                end
            end
            4'b0010: //up
            begin
                if (prevOnTrack2==2'b00) begin
                    if ((((currP2[31:16]>prevP2[31:16])&&(currP2[31:16]-prevP2[31:16]<thr1)) || ((currP2[31:16]<=prevP2[31:16])&&(prevP2[31:16]-currP2[31:16]<thr1))) && (currP2[15:0]<prevP2[15:0]))
                       onTrack2=2'b01;
                    else onTrack2 = 2'b00;
                end
                else begin
                    if ((((currP2[31:16]>iniP2[31:16])&&(currP2[31:16]-iniP2[31:16]<thr1)) || ((currP2[31:16]<=iniP2[31:16])&&(iniP2[31:16]-currP2[31:16]<thr1))) && (currP2[15:0]<prevP2[15:0]))
                       onTrack2=2'b01;
                    else onTrack2 = 2'b00;
                end
            end
            4'b0011: //down
            begin
                if (prevOnTrack2==2'b00) begin
                    if ((((currP2[31:16]>prevP2[31:16])&&(currP2[31:16]-prevP2[31:16]<thr1)) || ((currP2[31:16]<=prevP2[31:16])&&(prevP2[31:16]-currP2[31:16]<thr1))) && (currP2[15:0]>prevP2[15:0]))
                      onTrack2=2'b01;
                    else onTrack2 = 2'b00;
                end
                else begin
                    if ((((currP2[31:16]>iniP2[31:16])&&(currP2[31:16]-iniP2[31:16]<thr1)) || ((currP2[31:16]<=iniP2[31:16])&&(iniP2[31:16]-currP2[31:16]<thr1))) && (currP2[15:0]>prevP2[15:0]))
                       onTrack2=2'b01;
                    else onTrack2 = 2'b00;
                end
            end
            4'b0100: // arc-moves up from right
            begin
                if (prevOnTrack2==2'b00) begin
                    if ((currP2[31:16]>prevP2[31:16]) && (currP2[15:0]<prevP2[15:0]))
                        onTrack2=2'b01;
                    else onTrack2 = 2'b00;
                end
                else begin
                    if (currP2[15:0]>prevP2[15:0])   onTrack2 = 2'b00;
                    else begin
                        if (prevOnTrack2==2'b01) begin
                            if (currP2[31:16]<=prevP2[31:16]) begin
                                if ((prevP2[31:16]>iniP2[31:16])&&(prevP2[31:16]-iniP2[31:16]<thr3))   onTrack2 = 2'b00;
                                else begin
                                    if (checkConc_sec1_2>=0)  onTrack2 = 2'b10;
                                    else onTrack2 = 2'b00;
                                end
                            end
                        end
                        else begin
                            if (currP2[31:16]>prevP2[31:16])  onTrack2 = 2'b00;        
                        end
                    end
                end
            end
            //////////////////////////////////////////////////////////////
            4'b0101: // arc-moves down from right
            begin
                if (prevOnTrack2==0) begin
                    if ((currP2[31:16]>prevP2[31:16]) && (currP2[15:0]>prevP2[15:0]))
                        onTrack2=2'b01;
                    else onTrack2 = 2'b00;
                end
                else begin
                    if (currP2[15:0]<prevP2[15:0])   onTrack2 = 2'b00;
                    else begin
                        if (prevOnTrack2==2'b01) begin
                            if (currP2[31:16]<=prevP2[31:16]) begin
                                if ((prevP2[31:16]>iniP2[31:16])&&(prevP2[31:16]-iniP2[31:16]<thr3))   onTrack2 = 2'b00;
                                else begin
                                    if (checkConc_sec1_2<=0)  onTrack2 = 2'b10;
                                    else onTrack2 = 2'b00;
                                end
                            end
                        end
                        else begin
                            if (currP2[31:16]>prevP2[31:16])  onTrack2 = 2'b00;        
                        end
                    end
                end
            end
            4'b0110: // arc-moves up from left
            begin
                if (prevOnTrack2==0) begin
                    if ((currP2[31:16]<prevP2[31:16]) && (currP2[15:0]<prevP2[15:0]))
                        onTrack2=2'b01;
                    else onTrack2 = 2'b00;
                end
                else begin
                    if (currP2[15:0]>prevP2[15:0])   onTrack2 = 2'b00;
                    else begin
                        if (prevOnTrack2==2'b01) begin
                            if (currP2[31:16]>=prevP2[31:16]) begin
                                if ((prevP2[31:16]<iniP2[31:16])&&(iniP2[31:16]-prevP2[31:16]<thr3))   onTrack2 = 2'b00;
                                else begin
                                    if (checkConc_sec1_2<=0)  onTrack2 = 2'b10;
                                    else onTrack2 = 2'b00;
                                end
                            end
                        end
                        else begin
                            if (currP2[31:16]<prevP2[31:16])  onTrack2 = 2'b00;        
                        end
                    end
                end
            end
            4'b0111: // arc-moves down from left
            begin
                if (prevOnTrack2==0) begin
                    if ((currP2[31:16]<prevP2[31:16]) && (currP2[15:0]>prevP2[15:0]))
                        onTrack2=2'b01;
                    else onTrack2 = 2'b00;
                end
                else begin
                    if (currP2[15:0]<prevP2[15:0])   onTrack2 = 2'b00;
                    else begin
                        if (prevOnTrack2==2'b01) begin
                            if (currP2[31:16]>=prevP2[31:16]) begin
                                if ((prevP2[31:16]<iniP2[31:16])&&(iniP2[31:16]-prevP2[31:16]<thr3))   onTrack2 = 2'b00;
                                else begin
                                    if (checkConc_sec1_2>=0)  onTrack2 = 2'b10;
                                    else onTrack2 = 2'b00;
                                end
                            end
                        end
                        else begin
                            if (currP2[31:16]<prevP2[31:16])  onTrack2 = 2'b00;        
                        end
                    end
                end
            end
            4'b1000: // arc-moves to the right from top
            begin
                if (prevOnTrack2==0) begin
                    if ((currP2[31:16]>prevP2[31:16]) && (currP2[15:0]<prevP2[15:0]))
                        onTrack2=2'b01;
                    else onTrack2 = 2'b00;
                end
                else begin
                    if (currP2[31:16]<prevP2[31:16])   onTrack2 = 2'b00;
                    else begin
                        if (prevOnTrack2==2'b01) begin
                            if (currP2[15:0]>=prevP2[15:0]) begin
                                if ((prevP2[15:0]<iniP2[15:0])&&(iniP2[15:0]-prevP2[15:0]<thr3))   onTrack2 = 2'b00;
                                else begin
                                    if (checkConc_sec1_2<=0)  onTrack2 = 2'b10;
                                    else onTrack2 = 2'b00;
                                end
                            end
                        end
                        else begin
                            if (currP2[15:0]<prevP2[15:0])  onTrack2 = 2'b00;        
                        end
                    end
                end
            end
            4'b1001: // arc-moves to the left from top
            begin
                if (prevOnTrack2==0) begin
                    if ((currP2[31:16]<prevP2[31:16]) && (currP2[15:0]<prevP2[15:0]))
                        onTrack2=2'b01;
                    else onTrack2 = 2'b00;
                end
                else begin
                    if (currP2[31:16]>prevP2[31:16])   onTrack2 = 2'b00;
                    else begin
                        if (prevOnTrack2==2'b01) begin
                            if (currP2[15:0]>=prevP2[15:0]) begin
                                if ((prevP2[15:0]<iniP2[15:0])&&(iniP2[15:0]-prevP2[15:0]<thr3))   onTrack2 = 2'b00;
                                else begin
                                    if (checkConc_sec1_2>=0)  onTrack2 = 2'b10;
                                    else onTrack2 = 2'b00;
                                end
                            end
                        end
                        else begin
                            if (currP2[15:0]>prevP2[15:0])  onTrack2 = 2'b00;        
                        end
                    end
                end
            end
            4'b1010: // arc-moves to the right from bottom
            begin
                if (prevOnTrack2==0) begin
                    if ((currP2[31:16]>prevP2[31:16]) && (currP2[15:0]>prevP2[15:0]))
                        onTrack2=2'b01;
                    else onTrack2 = 2'b00;
                end
                else begin
                    if (currP2[31:16]<prevP2[31:16])   onTrack2 = 2'b00;
                    else begin
                        if (prevOnTrack2==2'b01) begin
                            if (currP2[15:0]<=prevP2[15:0]) begin
                                if ((prevP2[15:0]>iniP2[15:0])&&(prevP2[15:0]-iniP2[15:0]<thr3))   onTrack2 = 2'b00;
                                else begin
                                    if (checkConc_sec1_2>=0)  onTrack2 = 2'b10;
                                    else onTrack2 = 2'b00;
                                end
                            end
                        end
                        else begin
                            if (currP2[15:0]>prevP2[15:0])  onTrack2 = 2'b00;        
                        end
                    end
                end
            end
            4'b1011: // arc-moves to the left from bottom
            begin
                if (prevOnTrack2==0) begin
                    if ((currP2[31:16]<prevP2[31:16]) && (currP2[15:0]>prevP2[15:0]))
                        onTrack2=2'b01;
                    else onTrack2 = 2'b00;
                end
                else begin
                    if (currP2[31:16]>prevP2[31:16])   onTrack2 = 2'b00;
                    else begin
                        if (prevOnTrack2==2'b01) begin
                            if (currP2[15:0]<=prevP2[15:0]) begin
                                if ((prevP2[15:0]>iniP2[15:0])&&(prevP2[15:0]-iniP2[15:0]<thr3))   onTrack2 = 2'b00;
                                else begin
                                    if (checkConc_sec1_2<=0)  onTrack2 = 2'b10;
                                    else onTrack2 = 2'b00;
                                end
                            end
                        end
                        else begin
                            if (currP2[15:0]>prevP2[15:0])  onTrack2 = 2'b00;        
                        end
                    end
                end
            end
            default: onTrack2 = 2'b00;
        endcase    
    end
    
/*    
    always@(currP3, prevP3, iniP3, prevOnTrack3)
    begin
        case(slv_reg0[27:24])
            4'b0000: //right
            begin
                if (~prevOnTrack3) begin
                    if ((((currP3[15:0]>prevP3[15:0])&&(currP3[15:0]-prevP3[15:0]<thr1)) || ((currP3[15:0]<=prevP3[15:0])&&(prevP3[15:0]-currP3[15:0]<thr1))) && (currP3[31:16]>prevP3[31:16]))
                        onTrack3=1;
                    else onTrack3 = 0;
                end
                else begin
                    if ((((currP3[15:0]>iniP3[15:0])&&(currP3[15:0]-iniP3[15:0]<thr1)) || ((currP3[15:0]<=iniP3[15:0])&&(iniP3[15:0]-currP3[15:0]<thr1))) && (currP3[31:16]>prevP3[31:16]))
                       onTrack3=1;
                    else onTrack3 = 0;
                end
            end
            4'b0001: //left
            begin
                if (~prevOnTrack3) begin
                    if ((((currP3[15:0]>prevP3[15:0])&&(currP3[15:0]-prevP3[15:0]<10)) || ((currP3[15:0]<=prevP3[15:0])&&(prevP3[15:0]-currP3[15:0]<10))) && (currP3[31:16]<prevP3[31:16]))
                       onTrack3=1;
                    else onTrack3 = 0;
                end
                else begin
                    if ((((currP3[15:0]>iniP3[15:0])&&(currP3[15:0]-iniP3[15:0]<10)) || ((currP3[15:0]<=iniP3[15:0])&&(iniP3[15:0]-currP3[15:0]<10))) && (currP3[31:16]<prevP3[31:16]))
                       onTrack3=1;
                    else onTrack3 = 0;
                end
            end
            4'b0010: //up
            begin
                if (~prevOnTrack3) begin
                    if ((((currP3[31:16]>prevP3[31:16])&&(currP3[31:16]-prevP3[31:16]<thr1)) || ((currP3[31:16]<=prevP3[31:16])&&(prevP3[31:16]-currP3[31:16]<thr1))) && (currP3[15:0]<prevP3[15:0]))
                       onTrack3=1;
                    else onTrack3 = 0;
                end
                else begin
                    if ((((currP3[31:16]>iniP3[31:16])&&(currP3[31:16]-iniP3[31:16]<thr1)) || ((currP3[31:16]<=iniP3[31:16])&&(iniP3[31:16]-currP3[31:16]<thr1))) && (currP3[15:0]<prevP3[15:0]))
                       onTrack3=1;
                    else onTrack3 = 0;
                end
            end
            4'b0011: //down
            begin
                if (~prevOnTrack3) begin
                    if ((((currP3[31:16]>prevP3[31:16])&&(currP3[31:16]-prevP3[31:16]<thr1)) || ((currP3[31:16]<=prevP3[31:16])&&(prevP3[31:16]-currP3[31:16]<thr1))) && (currP3[15:0]>prevP3[15:0]))
                      onTrack3=1;
                    else onTrack3 = 0;
                end
                else begin
                    if ((((currP3[31:16]>iniP3[31:16])&&(currP3[31:16]-iniP3[31:16]<thr1)) || ((currP3[31:16]<=iniP3[31:16])&&(iniP3[31:16]-currP3[31:16]<thr1))) && (currP3[15:0]>prevP3[15:0]))
                       onTrack3=1;
                    else onTrack3 = 0;
                end
            end
            default: onTrack3 = 0;
        endcase    
    end
    
    
    
    always@(currP4, prevP4, iniP4, prevOnTrack4)
    begin
        case(slv_reg0[31:28])
            4'b0000: //right
            begin
                if (~prevOnTrack4) begin
                    if ((((currP4[15:0]>prevP4[15:0])&&(currP4[15:0]-prevP4[15:0]<thr1)) || ((currP4[15:0]<=prevP4[15:0])&&(prevP4[15:0]-currP4[15:0]<thr1))) && (currP4[31:16]>prevP4[31:16]))
                        onTrack4=1;
                    else onTrack4 = 0;
                end
                else begin
                    if ((((currP4[15:0]>iniP4[15:0])&&(currP4[15:0]-iniP4[15:0]<thr1)) || ((currP4[15:0]<=iniP4[15:0])&&(iniP4[15:0]-currP4[15:0]<thr1))) && (currP4[31:16]>prevP4[31:16]))
                       onTrack4=1;
                    else onTrack4 = 0;
                end
            end
            4'b0001: //left
            begin
                if (~prevOnTrack4) begin
                    if ((((currP4[15:0]>prevP4[15:0])&&(currP4[15:0]-prevP4[15:0]<thr1)) || ((currP4[15:0]<=prevP4[15:0])&&(prevP4[15:0]-currP4[15:0]<thr1))) && (currP4[31:16]<prevP4[31:16]))
                       onTrack4=1;
                    else onTrack4 = 0;
                end
                else begin
                    if ((((currP4[15:0]>iniP4[15:0])&&(currP4[15:0]-iniP4[15:0]<thr1)) || ((currP4[15:0]<=iniP4[15:0])&&(iniP4[15:0]-currP4[15:0]<thr1))) && (currP4[31:16]<prevP4[31:16]))
                       onTrack4=1;
                    else onTrack4 = 0;
                end
            end
            4'b0010: //up
            begin
                if (~prevOnTrack4) begin
                    if ((((currP4[31:16]>prevP4[31:16])&&(currP4[31:16]-prevP4[31:16]<thr1)) || ((currP4[31:16]<=prevP4[31:16])&&(prevP4[31:16]-currP4[31:16]<thr1))) && (currP4[15:0]<prevP4[15:0]))
                       onTrack4=1;
                    else onTrack4 = 0;
                end
                else begin
                    if ((((currP4[31:16]>iniP4[31:16])&&(currP4[31:16]-iniP4[31:16]<thr1)) || ((currP4[31:16]<=iniP4[31:16])&&(iniP4[31:16]-currP4[31:16]<thr1))) && (currP4[15:0]<prevP4[15:0]))
                       onTrack4=1;
                    else onTrack4 = 0;
                end
            end
            4'b0011: //down
            begin
                if (~prevOnTrack4) begin
                    if ((((currP4[31:16]>prevP4[31:16])&&(currP4[31:16]-prevP4[31:16]<thr1)) || ((currP4[31:16]<=prevP4[31:16])&&(prevP4[31:16]-currP4[31:16]<thr1))) && (currP4[15:0]>prevP4[15:0]))
                      onTrack4=1;
                    else onTrack4 = 0;
                end
                else begin
                    if ((((currP4[31:16]>iniP4[31:16])&&(currP4[31:16]-iniP4[31:16]<thr1)) || ((currP4[31:16]<=iniP4[31:16])&&(iniP4[31:16]-currP4[31:16]<thr1))) && (currP4[15:0]>prevP4[15:0]))
                       onTrack4=1;
                    else onTrack4 = 0;
                end
            end
            default: onTrack4 = 0;
        endcase    
    end
*/    
    
    
// ---------------------------------------------------------------------------------------------------
    
    always@(currP1, prevP1, prevOnTrack1,iniP1)
    begin
        case(slv_reg0[19:16])
            4'b0000: //right
            begin
                if ((((currP1[15:0]>prevP1[15:0])&&(currP1[15:0]-prevP1[15:0]<thr1)) || ((currP1[15:0]<=prevP1[15:0])&&(prevP1[15:0]-currP1[15:0]<thr1))) && (currP1[31:16]>prevP1[31:16]) && (prevOnTrack1==2'b00))
                  nextiniP1=prevP1;
                else nextiniP1=iniP1;
            end
            4'b0001: //left
            begin
                if ((((currP1[15:0]>prevP1[15:0])&&(currP1[15:0]-prevP1[15:0]<thr1)) || ((currP1[15:0]<=prevP1[15:0])&&(prevP1[15:0]-currP1[15:0]<thr1))) && (currP1[31:16]<prevP1[31:16]) && (prevOnTrack1==2'b00))
                  nextiniP1=prevP1;
                else nextiniP1=iniP1;
            end
            4'b0010: //up
            begin
                if ((((currP1[31:16]>prevP1[31:16])&&(currP1[31:16]-prevP1[31:16]<thr1)) || ((currP1[31:16]<=prevP1[31:16])&&(prevP1[31:16]-currP1[31:16]<thr1))) && (currP1[15:0]<prevP1[15:0]) && (prevOnTrack1==2'b00))
                  nextiniP1=prevP1;
                else nextiniP1=iniP1;
            end
            4'b0011: //down
            begin
                if ((((currP1[31:16]>prevP1[31:16])&&(currP1[31:16]-prevP1[31:16]<thr1)) || ((currP1[31:16]<=prevP1[31:16])&&(prevP1[31:16]-currP1[31:16]<thr1))) && (currP1[15:0]>prevP1[15:0]) && (prevOnTrack1==2'b00))
                  nextiniP1=prevP1;
                else nextiniP1=iniP1;
            end
            4'b0100: // arc-moves up from right
            begin
                if ((prevOnTrack1==2'b00) && ((currP1[31:16]>prevP1[31:16]) && (currP1[15:0]<prevP1[15:0])))
                    nextiniP1=prevP1;
                else nextiniP1=iniP1;
            end
            //////////////////////////////////////////////////////////////
            4'b0101: // arc-moves down from right
            begin
                if ((prevOnTrack1==2'b00) && ((currP1[31:16]>prevP1[31:16]) && (currP1[15:0]>prevP1[15:0])))
                    nextiniP1=prevP1;
                else nextiniP1=iniP1;
            end
            4'b0110: // arc-moves up from left
            begin
                if ((prevOnTrack1==2'b00) && ((currP1[31:16]<prevP1[31:16]) && (currP1[15:0]<prevP1[15:0])))
                    nextiniP1=prevP1;
                else nextiniP1=iniP1;
            end
            4'b0111: // arc-moves down from left
            begin
                if ((prevOnTrack1==2'b00) && ((currP1[31:16]<prevP1[31:16]) && (currP1[15:0]>prevP1[15:0])))
                    nextiniP1=prevP1;
                else nextiniP1=iniP1;
            end
            4'b1000: // arc-moves to the right from top
            begin
                if ((prevOnTrack1==2'b00) && ((currP1[31:16]>prevP1[31:16]) && (currP1[15:0]<prevP1[15:0])))
                    nextiniP1=prevP1;
                else nextiniP1=iniP1;
            end
            4'b1001: // arc-moves to the left from top
            begin
                if ((prevOnTrack1==2'b00) && ((currP1[31:16]<prevP1[31:16]) && (currP1[15:0]<prevP1[15:0])))
                    nextiniP1=prevP1;
                else nextiniP1=iniP1;
            end
            4'b1010: // arc-moves to the right from bottom
            begin
                if ((prevOnTrack1==2'b00) && ((currP1[31:16]>prevP1[31:16]) && (currP1[15:0]>prevP1[15:0])))
                    nextiniP1=prevP1;
                else nextiniP1=iniP1;
            end
            4'b01011: //  arc-moves to the left from bottom
            begin
                if ((prevOnTrack1==2'b00) && ((currP1[31:16]<prevP1[31:16]) && (currP1[15:0]>prevP1[15:0])))
                    nextiniP1=prevP1;
                else nextiniP1=iniP1;
            end
            default: nextiniP1=iniP1;
        endcase    
    end
    
    
    
    always@(currP2, prevP2, prevOnTrack2,iniP2)
    begin
        case(slv_reg0[23:20])
            4'b0000: //right
            begin
                if ((((currP2[15:0]>prevP2[15:0])&&(currP2[15:0]-prevP2[15:0]<thr1)) || ((currP2[15:0]<=prevP2[15:0])&&(prevP2[15:0]-currP2[15:0]<thr1))) && (currP2[31:16]>prevP2[31:16]) && (prevOnTrack2==2'b00))
                  nextiniP2=prevP2;
                else nextiniP2=iniP2;
            end
            4'b0001: //left
            begin
                if ((((currP2[15:0]>prevP2[15:0])&&(currP2[15:0]-prevP2[15:0]<thr1)) || ((currP2[15:0]<=prevP2[15:0])&&(prevP2[15:0]-currP2[15:0]<thr1))) && (currP2[31:16]<prevP2[31:16]) && (prevOnTrack2==2'b00))
                  nextiniP2=prevP2;
                else nextiniP2=iniP2;
            end
            4'b0010: //up
            begin
                if ((((currP2[31:16]>prevP2[31:16])&&(currP2[31:16]-prevP2[31:16]<thr1)) || ((currP2[31:16]<=prevP2[31:16])&&(prevP2[31:16]-currP2[31:16]<thr1))) && (currP2[15:0]<prevP2[15:0]) && (prevOnTrack2==2'b00))
                  nextiniP2=prevP2;
                else nextiniP2=iniP2;
            end
            4'b0011: //down
           begin
                if ((((currP2[31:16]>prevP2[31:16])&&(currP2[31:16]-prevP2[31:16]<thr1)) || ((currP2[31:16]<=prevP2[31:16])&&(prevP2[31:16]-currP2[31:16]<thr1))) && (currP2[15:0]>prevP2[15:0]) && (prevOnTrack2==2'b00))
                  nextiniP2=prevP2;
                else nextiniP2=iniP2;
            end
            4'b0100: // arc-moves up from right
            begin
                if ((prevOnTrack2==2'b00) && ((currP2[31:16]>prevP2[31:16]) && (currP2[15:0]<prevP2[15:0])))
                    nextiniP2=prevP2;
                else nextiniP2=iniP2;
            end
            //////////////////////////////////////////////////////////////
            4'b0101: // arc-moves down from right
            begin
                if ((prevOnTrack2==2'b00) && ((currP2[31:16]>prevP2[31:16]) && (currP2[15:0]>prevP2[15:0])))
                    nextiniP2=prevP2;
                else nextiniP2=iniP2;
            end
            4'b0110: // arc-moves up from left
            begin
                if ((prevOnTrack2==2'b00) && ((currP2[31:16]<prevP2[31:16]) && (currP2[15:0]<prevP2[15:0])))
                    nextiniP2=prevP2;
                else nextiniP2=iniP2;
            end
            4'b0111: // arc-moves down from left
            begin
                if ((prevOnTrack2==2'b00) && ((currP2[31:16]<prevP2[31:16]) && (currP2[15:0]>prevP2[15:0])))
                    nextiniP2=prevP2;
                else nextiniP2=iniP2;
            end
            4'b1000: // arc-moves to the right from top
            begin
                if ((prevOnTrack2==2'b00) && ((currP2[31:16]>prevP2[31:16]) && (currP2[15:0]<prevP2[15:0])))
                    nextiniP2=prevP2;
                else nextiniP2=iniP2;
            end
            4'b1001: // arc-moves to the left from top
            begin
                if ((prevOnTrack2==2'b00) && ((currP2[31:16]<prevP2[31:16]) && (currP2[15:0]<prevP2[15:0])))
                    nextiniP2=prevP2;
                else nextiniP2=iniP2;
            end
            4'b1010: // arc-moves to the right from bottom
            begin
                if ((prevOnTrack2==2'b00) && ((currP2[31:16]>prevP2[31:16]) && (currP2[15:0]>prevP2[15:0])))
                    nextiniP2=prevP2;
                else nextiniP2=iniP2;
            end
            4'b01011: //  arc-moves to the left from bottom
            begin
                if ((prevOnTrack2==2'b00) && ((currP2[31:16]<prevP2[31:16]) && (currP2[15:0]>prevP2[15:0])))
                    nextiniP2=prevP2;
                else nextiniP2=iniP2;
            end
            default: nextiniP2=iniP2;
        endcase    
    end
    
    
/*    
    always@(currP3, prevP3, prevOnTrack3,iniP3)
    begin
        case(slv_reg0[27:24])
            4'b0000: //right
            begin
                if ((((currP3[15:0]>prevP3[15:0])&&(currP3[15:0]-prevP3[15:0]<thr1)) || ((currP3[15:0]<=prevP3[15:0])&&(prevP3[15:0]-currP3[15:0]<thr1))) && (currP3[31:16]>prevP3[31:16]) && (~prevOnTrack3))
                  nextiniP3=prevP3;
                else nextiniP3=iniP3;
            end
            4'b0001: //left
            begin
                if ((((currP3[15:0]>prevP3[15:0])&&(currP3[15:0]-prevP3[15:0]<thr1)) || ((currP3[15:0]<=prevP3[15:0])&&(prevP3[15:0]-currP3[15:0]<thr1))) && (currP3[31:16]<prevP3[31:16]) && (~prevOnTrack3))
                  nextiniP3=prevP3;
                else nextiniP3=iniP3;
            end
            4'b0010: //up
            begin
                if ((((currP3[31:16]>prevP3[31:16])&&(currP3[31:16]-prevP3[31:16]<thr1)) || ((currP3[31:16]<=prevP3[31:16])&&(prevP3[31:16]-currP3[31:16]<thr1))) && (currP3[15:0]<prevP3[15:0]) && (~prevOnTrack3))
                  nextiniP3=prevP3;
                else nextiniP3=iniP3;
            end
            4'b0011: //down
           begin
                if ((((currP3[31:16]>prevP3[31:16])&&(currP3[31:16]-prevP3[31:16]<thr1)) || ((currP3[31:16]<=prevP3[31:16])&&(prevP3[31:16]-currP3[31:16]<thr1))) && (currP3[15:0]>prevP3[15:0]) && (~prevOnTrack3))
                  nextiniP3=prevP3;
                else nextiniP3=iniP3;
            end
            default: nextiniP3=iniP3;
        endcase    
    end
    
    
    
    always@(currP4, prevP4, prevOnTrack4,iniP4)
    begin
        case(slv_reg0[31:28])
            4'b0000: //right
            begin
                if ((((currP4[15:0]>prevP4[15:0])&&(currP4[15:0]-prevP4[15:0]<thr1)) || ((currP4[15:0]<=prevP4[15:0])&&(prevP4[15:0]-currP4[15:0]<thr1))) && (currP4[31:16]>prevP4[31:16]) && (~prevOnTrack4))
                  nextiniP4=prevP4;
                else nextiniP4=iniP4;
            end
            4'b0001: //left
            begin
                if ((((currP4[15:0]>prevP4[15:0])&&(currP4[15:0]-prevP4[15:0]<thr1)) || ((currP4[15:0]<=prevP4[15:0])&&(prevP4[15:0]-currP4[15:0]<thr1))) && (currP4[31:16]<prevP4[31:16]) && (~prevOnTrack4))
                  nextiniP4=prevP4;
                else nextiniP4=iniP4;
            end
            4'b0010: //up
            begin
                if ((((currP4[31:16]>prevP4[31:16])&&(currP4[31:16]-prevP4[31:16]<thr1)) || ((currP4[31:16]<=prevP4[31:16])&&(prevP4[31:16]-currP4[31:16]<thr1))) && (currP4[15:0]<prevP4[15:0]) && (~prevOnTrack4))
                  nextiniP4=prevP4;
                else nextiniP4=iniP4;
            end
            4'b0011: //down
           begin
                if ((((currP4[31:16]>prevP4[31:16])&&(currP4[31:16]-prevP4[31:16]<thr1)) || ((currP4[31:16]<=prevP4[31:16])&&(prevP4[31:16]-currP4[31:16]<thr1))) && (currP4[15:0]>prevP4[15:0]) && (~prevOnTrack4))
                  nextiniP4=prevP4;
                else nextiniP4=iniP4;
            end
            default: nextiniP4=iniP4;
        endcase    
    end
*/    
    
    
    
// ---------------------------------------------------------------------------------------------------
    
    
    
    always@(currP1, prevP1)
    begin
        if (currP1[31:16]>prevP1[31:16])
            sn3=currP1[31:16]-prevP1[31:16];
        else begin
            sn3=prevP1[31:16]-currP1[31:16];
            sn3=0-sn3;
        end
        
        sn4=currP1[15:0]+prevP1[15:0];
        tempConc1=sn3*sn4;
    end
    
    
    always@(currP2, prevP2)
        begin
            if (currP2[31:16]>prevP2[31:16])
                sn5=currP2[31:16]-prevP2[31:16];
            else begin
                sn5=prevP2[31:16]-currP2[31:16];
                sn5=0-sn5;
            end
            
            sn6=currP2[15:0]+prevP2[15:0];
            tempConc2=sn5*sn6;
        end
    
    
    
// ---------------------------------------------------------------------------------------------------
            
    
    
    always@(iniP1, prevP1, prevConc1)
    begin
        if (iniP1[31:16]>prevP1[31:16])
            sn7=iniP1[31:16]-prevP1[31:16];
        else begin
            sn7=prevP1[31:16]-iniP1[31:16];
            sn7=0-sn7;
        end
        
        sn8=iniP1[15:0]+prevP1[15:0];
        checkConc_sec1_1=sn7*sn8+prevConc1;
    end
    
    
    always@(iniP2, prevP2, prevConc2)
    begin
        if (iniP2[31:16]>prevP2[31:16])
            sn9=iniP2[31:16]-prevP2[31:16];
        else begin
            sn9=prevP2[31:16]-iniP2[31:16];
            sn9=0-sn9;
        end
        
        sn10=iniP2[15:0]+prevP2[15:0];
        checkConc_sec1_2=sn9*sn10+prevConc2;
    end
    
    
    
    
// ---------------------------------------------------------------------------------------------------
                
        
        
    always@(iniP_c1, currP1, sn3, sn4, prevConc1)
    begin
        if (iniP_c1[31:16]>currP1[31:16])
            sn11=iniP_c1[31:16]-currP1[31:16];
        else begin
            sn11=currP1[31:16]-iniP_c1[31:16];
            sn11=0-sn11;
        end
        
        sn12=iniP_c1[15:0]+currP1[15:0];
        checkConc_sec2_1=sn3*sn4+sn11*sn12+prevConc1;
    end
    
    
        
    always@(iniP_c2, currP2, sn5, sn6, prevConc2)
    begin
        if (iniP_c2[31:16]>currP2[31:16])
            sn13=iniP_c2[31:16]-currP2[31:16];
        else begin
            sn13=currP2[31:16]-iniP_c2[31:16];
            sn13=0-sn13;
        end
        
        sn14=iniP_c2[15:0]+currP2[15:0];
        checkConc_sec2_2=sn5*sn6+sn13*sn14+prevConc2;
    end
    
    

// ---------------------------------------------------------------------------------------------------
    
    
    always@(currP1, prevP1, prevOnTrack1, iniP1, tempConc1, checkConc_sec1_1, checkConc_sec2_1)
    begin
        case(slv_reg0[19:16])
            4'b0100: // arc-moves up from right
            begin
                if (prevOnTrack1==2'b00) begin
                    if ((currP1[31:16]>prevP1[31:16]) && (currP1[15:0]<prevP1[15:0])) begin
                        conc1=tempConc1;
                    end
                end
                else begin
                    if (currP1[15:0]<=prevP1[15:0]) begin
                        if (prevOnTrack1==2'b01) begin
                            if (currP1[31:16]<=prevP1[31:16]) begin
                                if ((prevP1[31:16]>iniP1[31:16])&&(prevP1[31:16]-iniP1[31:16]>=thr3)) begin
                                    if (checkConc_sec1_1>=0)  conc1=tempConc1;
                                end
                            end
                            else  conc1=prevConc1+tempConc1;
                        end
                        else begin
                            if (currP1[31:16]<=prevP1[31:16]) begin
                                if (((iniP_c1[31:16]>currP1[31:16])&&(iniP_c1[31:16]-currP1[31:16]>thr5))&&((iniP1[15:0]>currP1[15:0])&&(iniP1[15:0]-currP1[15:0]>thr4))) begin
                                    if (checkConc_sec2_1<0)  conc1=prevConc1+tempConc1;
                                end
                                else conc1=prevConc1+tempConc1;
                            end
                        end
                    end
                end
            end
            //////////////////////////////////////////////////////////////
            4'b0101: // arc-moves down from right
            begin
                if (prevOnTrack1==2'b00) begin
                    if ((currP1[31:16]>prevP1[31:16]) && (currP1[15:0]>prevP1[15:0])) begin
                        conc1=tempConc1;
                    end
                end
                else begin
                    if (currP1[15:0]>=prevP1[15:0]) begin
                        if (prevOnTrack1==2'b01) begin
                            if (currP1[31:16]<=prevP1[31:16]) begin
                                if ((prevP1[31:16]>iniP1[31:16])&&(prevP1[31:16]-iniP1[31:16]>=thr3)) begin
                                    if (checkConc_sec1_1<=0)  conc1=tempConc1;
                                end
                            end
                            else  conc1=prevConc1+tempConc1;
                        end
                        else begin
                            if (currP1[31:16]<=prevP1[31:16]) begin
                                if (((iniP_c1[31:16]>currP1[31:16])&&(iniP_c1[31:16]-currP1[31:16]>thr5))&&((iniP1[15:0]<currP1[15:0])&&(currP1[15:0]-iniP1[15:0]>thr4))) begin
                                    if (checkConc_sec2_1>0)  conc1=prevConc1+tempConc1;
                                end
                                else conc1=prevConc1+tempConc1;
                            end
                        end
                    end
                end
            end
            4'b0110: // arc-moves up from left
            begin
                if (prevOnTrack1==2'b00) begin
                    if ((currP1[31:16]<prevP1[31:16]) && (currP1[15:0]<prevP1[15:0])) begin
                        conc1=tempConc1;
                    end
                end
                else begin
                    if (currP1[15:0]<=prevP1[15:0]) begin
                        if (prevOnTrack1==2'b01) begin
                            if (currP1[31:16]>=prevP1[31:16]) begin
                                if ((prevP1[31:16]>iniP1[31:16])&&(prevP1[31:16]-iniP1[31:16]>=thr3)) begin
                                    if (checkConc_sec1_1<=0)  conc1=tempConc1;
                                end
                            end
                            else  conc1=prevConc1+tempConc1;
                        end
                        else begin
                            if (currP1[31:16]>=prevP1[31:16]) begin
                                if (((iniP_c1[31:16]<currP1[31:16])&&(currP1[31:16]-iniP_c1[31:16]>thr5))&&((iniP1[15:0]>currP1[15:0])&&(iniP1[15:0]-currP1[15:0]>thr4))) begin
                                    if (checkConc_sec2_1>0)  conc1=prevConc1+tempConc1;
                                end
                                else conc1=prevConc1+tempConc1;
                            end
                        end
                    end
                end
            end
            4'b0111: // arc-moves down from left
            begin
                if (prevOnTrack1==2'b00) begin
                    if ((currP1[31:16]<prevP1[31:16]) && (currP1[15:0]>prevP1[15:0])) begin
                        conc1=tempConc1;
                    end
                end
                else begin
                    if (currP1[15:0]>=prevP1[15:0]) begin
                        if (prevOnTrack1==2'b01) begin
                            if (currP1[31:16]>=prevP1[31:16]) begin
                                if ((prevP1[31:16]<iniP1[31:16])&&(iniP1[31:16]-prevP1[31:16]>=thr3)) begin
                                    if (checkConc_sec1_1>=0)  conc1=tempConc1;
                                end
                            end
                            else  conc1=prevConc1+tempConc1;
                        end
                        else begin
                            if (currP1[31:16]>=prevP1[31:16]) begin
                                if (((iniP_c1[31:16]<currP1[31:16])&&(currP1[31:16]-iniP_c1[31:16]>thr5))&&((iniP1[15:0]<currP1[15:0])&&(currP1[15:0]-iniP1[15:0]>thr4))) begin
                                    if (checkConc_sec2_1<0)  conc1=prevConc1+tempConc1;
                                end
                                else conc1=prevConc1+tempConc1;
                            end
                        end
                    end
                end
            end
            4'b1000: // arc-moves to the right from top
            begin
                if (prevOnTrack1==2'b00) begin
                    if ((currP1[31:16]>prevP1[31:16]) && (currP1[15:0]<prevP1[15:0])) begin
                        conc1=tempConc1;
                    end
                end
                else begin
                    if (currP1[31:16]>=prevP1[31:16]) begin
                        if (prevOnTrack1==2'b01) begin
                            if (currP1[15:0]>=prevP1[15:0]) begin
                                if ((prevP1[15:0]<iniP1[15:0])&&(iniP1[15:0]-prevP1[15:0]>=thr3)) begin
                                    if (checkConc_sec1_1<=0)  conc1=tempConc1;
                                end
                            end
                            else  conc1=prevConc1+tempConc1;
                        end
                        else begin
                            if (currP1[15:0]>=prevP1[15:0]) begin//
                                if (((iniP_c1[15:0]<currP1[15:0])&&(currP1[15:0]-iniP_c1[15:0]>thr5))&&((iniP1[31:16]<currP1[31:16])&&(currP1[31:16]-iniP1[31:16]>thr4))) begin
                                    if (checkConc_sec2_1>0)  conc1=prevConc1+tempConc1;
                                end
                                else conc1=prevConc1+tempConc1;
                            end
                        end
                    end
                end
            end
            4'b1001: // arc-moves to the left from top
            begin
                if (prevOnTrack1==2'b00) begin
                    if ((currP1[31:16]<prevP1[31:16]) && (currP1[15:0]<prevP1[15:0])) begin
                        conc1=tempConc1;
                    end
                end
                else begin
                    if (currP1[31:16]<=prevP1[31:16]) begin
                        if (prevOnTrack1==2'b01) begin
                            if (currP1[15:0]>=prevP1[15:0]) begin
                                if ((prevP1[15:0]<iniP1[15:0])&&(iniP1[15:0]-prevP1[15:0]>=thr3)) begin
                                    if (checkConc_sec1_1>=0)  conc1=tempConc1;
                                end
                            end
                            else  conc1=prevConc1+tempConc1;
                        end
                        else begin
                            if (currP1[15:0]<=prevP1[15:0]) begin
                                if (((iniP_c1[15:0]<currP1[15:0])&&(currP1[15:0]-iniP_c1[15:0]>thr5))&&((iniP1[31:16]>currP1[31:16])&&(iniP1[31:16]-currP1[31:16]>thr4))) begin
                                    if (checkConc_sec2_1<0)  conc1=prevConc1+tempConc1;
                                end
                                else conc1=prevConc1+tempConc1;
                            end
                        end
                    end
                end
            end
            4'b1010: // arc-moves to the right from bottom
            begin
                if (prevOnTrack1==2'b00) begin
                    if ((currP1[31:16]>prevP1[31:16]) && (currP1[15:0]>prevP1[15:0])) begin
                        conc1=tempConc1;
                    end
                end
                else begin
                    if (currP1[31:16]>=prevP1[31:16]) begin
                        if (prevOnTrack1==2'b01) begin
                            if (currP1[15:0]<=prevP1[15:0]) begin
                                if ((prevP1[15:0]>iniP1[15:0])&&(prevP1[15:0]-iniP1[15:0]>=thr3)) begin
                                    if (checkConc_sec1_1>=0)  conc1=tempConc1;
                                end
                            end
                            else  conc1=prevConc1+tempConc1;
                        end
                        else begin
                            if (currP1[15:0]<=prevP1[15:0]) begin
                                if (((iniP_c1[15:0]>currP1[15:0])&&(iniP_c1[15:0]-currP1[15:0]>thr5))&&((iniP1[31:16]<currP1[31:16])&&(currP1[31:16]-iniP1[31:16]>thr4))) begin
                                    if (checkConc_sec2_1<0)  conc1=prevConc1+tempConc1;
                                end
                                else conc1=prevConc1+tempConc1;
                            end
                        end
                    end
                end
            end
            4'b1011: // arc-moves to the left from bottom
            begin
                if (prevOnTrack1==2'b00) begin
                    if ((currP1[31:16]<prevP1[31:16]) && (currP1[15:0]>prevP1[15:0])) begin
                        conc1=tempConc1;
                    end
                end
                else begin
                    if (currP1[31:16]<=prevP1[31:16]) begin
                        if (prevOnTrack1==2'b01) begin
                            if (currP1[15:0]<=prevP1[15:0]) begin
                                if ((prevP1[15:0]>iniP1[15:0])&&(prevP1[15:0]-iniP1[15:0]>=thr3)) begin
                                    if (checkConc_sec1_1<=0)  conc1=tempConc1;
                                end
                            end
                            else  conc1=prevConc1+tempConc1;
                        end
                        else begin
                            if (currP1[15:0]<=prevP1[15:0]) begin
                                if (((iniP_c1[15:0]>currP1[15:0])&&(iniP_c1[15:0]-currP1[15:0]>thr5))&&((iniP1[31:16]>currP1[31:16])&&(iniP1[31:16]-currP1[31:16]>thr4))) begin
                                    if (checkConc_sec2_1>0)  conc1=prevConc1+tempConc1;
                                end
                                else conc1=prevConc1+tempConc1;
                            end
                        end
                    end
                end
            end
            default: conc1=0;
        endcase    
    end
    

    
    
    
    always@(currP2, prevP2, prevOnTrack2, iniP2, tempConc2, checkConc_sec1_2, checkConc_sec2_2)
    begin
        case(slv_reg0[23:20])
            4'b0100: // arc-moves up from right
            begin
                if (prevOnTrack2==2'b00) begin
                    if ((currP2[31:16]>prevP2[31:16]) && (currP2[15:0]<prevP2[15:0])) begin
                        conc2=tempConc2;
                    end
                end
                else begin
                    if (currP2[15:0]<=prevP2[15:0]) begin
                        if (prevOnTrack2==2'b01) begin
                            if (currP2[31:16]<=prevP2[31:16]) begin
                                if ((prevP2[31:16]>iniP2[31:16])&&(prevP2[31:16]-iniP2[31:16]>=thr3)) begin
                                    if (checkConc_sec1_2>=0)  conc2=tempConc2;
                                end
                            end
                            else  conc2=prevConc2+tempConc2;
                        end
                        else begin
                            if (currP2[31:16]<=prevP2[31:16]) begin
                                if (((iniP_c2[31:16]>currP2[31:16])&&(iniP_c2[31:16]-currP2[31:16]>thr5))&&((iniP2[15:0]>currP2[15:0])&&(iniP2[15:0]-currP2[15:0]>thr4))) begin
                                    if (checkConc_sec2_2<0)  conc2=prevConc2+tempConc2;
                                end
                                else conc2=prevConc2+tempConc2;
                            end
                        end
                    end
                end
            end
            //////////////////////////////////////////////////////////////
            4'b0101: // arc-moves down from right
            begin
                if (prevOnTrack2==2'b00) begin
                    if ((currP2[31:16]>prevP2[31:16]) && (currP2[15:0]>prevP2[15:0])) begin
                        conc2=tempConc2;
                    end
                end
                else begin
                    if (currP2[15:0]>=prevP2[15:0]) begin
                        if (prevOnTrack2==2'b01) begin
                            if (currP2[31:16]<=prevP2[31:16]) begin
                                if ((prevP2[31:16]>iniP2[31:16])&&(prevP2[31:16]-iniP2[31:16]>=thr3)) begin
                                    if (checkConc_sec1_2<=0)  conc2=tempConc2;
                                end
                            end
                            else  conc2=prevConc2+tempConc2;
                        end
                        else begin
                            if (currP2[31:16]<=prevP2[31:16]) begin
                                if (((iniP_c2[31:16]>currP2[31:16])&&(iniP_c2[31:16]-currP2[31:16]>thr5))&&((iniP2[15:0]<currP2[15:0])&&(currP2[15:0]-iniP2[15:0]>thr4))) begin
                                    if (checkConc_sec2_2>0)  conc2=prevConc2+tempConc2;
                                end
                                else conc2=prevConc2+tempConc2;
                            end
                        end
                    end
                end
            end
            4'b0110: // arc-moves up from left
            begin
                if (prevOnTrack2==2'b00) begin
                    if ((currP2[31:16]<prevP2[31:16]) && (currP2[15:0]<prevP2[15:0])) begin
                        conc2=tempConc2;
                    end
                end
                else begin
                    if (currP2[15:0]<=prevP2[15:0]) begin
                        if (prevOnTrack2==2'b01) begin
                            if (currP2[31:16]>=prevP2[31:16]) begin
                                if ((prevP2[31:16]>iniP2[31:16])&&(prevP2[31:16]-iniP2[31:16]>=thr3)) begin
                                    if (checkConc_sec1_2<=0)  conc2=tempConc2;
                                end
                            end
                            else  conc2=prevConc2+tempConc2;
                        end
                        else begin
                            if (currP2[31:16]>=prevP2[31:16]) begin
                                if (((iniP_c2[31:16]<currP2[31:16])&&(currP2[31:16]-iniP_c2[31:16]>thr5))&&((iniP2[15:0]>currP2[15:0])&&(iniP2[15:0]-currP2[15:0]>thr4))) begin
                                    if (checkConc_sec2_2>0)  conc2=prevConc2+tempConc2;
                                end
                                else conc2=prevConc2+tempConc2;
                            end
                        end
                    end
                end
            end
            4'b0111: // arc-moves down from left
            begin
                if (prevOnTrack2==2'b00) begin
                    if ((currP2[31:16]<prevP2[31:16]) && (currP2[15:0]>prevP2[15:0])) begin
                        conc2=tempConc2;
                    end
                end
                else begin
                    if (currP2[15:0]>=prevP2[15:0]) begin
                        if (prevOnTrack2==2'b01) begin
                            if (currP2[31:16]>=prevP2[31:16]) begin
                                if ((prevP2[31:16]<iniP2[31:16])&&(iniP2[31:16]-prevP2[31:16]>=thr3)) begin
                                    if (checkConc_sec1_2>=0)  conc2=tempConc2;
                                end
                            end
                            else  conc2=prevConc2+tempConc2;
                        end
                        else begin
                            if (currP2[31:16]>=prevP2[31:16]) begin
                                if (((iniP_c2[31:16]<currP2[31:16])&&(currP2[31:16]-iniP_c2[31:16]>thr5))&&((iniP2[15:0]<currP2[15:0])&&(currP2[15:0]-iniP2[15:0]>thr4))) begin
                                    if (checkConc_sec2_2<0)  conc2=prevConc2+tempConc2;
                                end
                                else conc2=prevConc2+tempConc2;
                            end
                        end
                    end
                end
            end
            4'b1000: // arc-moves to the right from top
            begin
                if (prevOnTrack2==2'b00) begin
                    if ((currP2[31:16]>prevP2[31:16]) && (currP2[15:0]<prevP2[15:0])) begin
                        conc2=tempConc2;
                    end
                end
                else begin
                    if (currP2[31:16]>=prevP2[31:16]) begin
                        if (prevOnTrack2==2'b01) begin
                            if (currP2[15:0]>=prevP2[15:0]) begin
                                if ((prevP2[15:0]<iniP2[15:0])&&(iniP2[15:0]-prevP2[15:0]>=thr3)) begin
                                    if (checkConc_sec1_2<=0)  conc2=tempConc2;
                                end
                            end
                            else  conc2=prevConc2+tempConc2;
                        end
                        else begin
                            if (currP2[15:0]>=prevP2[15:0]) begin//
                                if (((iniP_c2[15:0]<currP2[15:0])&&(currP2[15:0]-iniP_c2[15:0]>thr5))&&((iniP2[31:16]<currP2[31:16])&&(currP2[31:16]-iniP2[31:16]>thr4))) begin
                                    if (checkConc_sec2_2>0)  conc2=prevConc2+tempConc2;
                                end
                                else conc2=prevConc2+tempConc2;
                            end
                        end
                    end
                end
            end
            4'b1001: // arc-moves to the left from top
            begin
                if (prevOnTrack2==2'b00) begin
                    if ((currP2[31:16]<prevP2[31:16]) && (currP2[15:0]<prevP2[15:0])) begin
                        conc2=tempConc2;
                    end
                end
                else begin
                    if (currP2[31:16]<=prevP2[31:16]) begin
                        if (prevOnTrack2==2'b01) begin
                            if (currP2[15:0]>=prevP2[15:0]) begin
                                if ((prevP2[15:0]<iniP2[15:0])&&(iniP2[15:0]-prevP2[15:0]>=thr3)) begin
                                    if (checkConc_sec1_2>=0)  conc2=tempConc2;
                                end
                            end
                            else  conc2=prevConc2+tempConc2;
                        end
                        else begin
                            if (currP2[15:0]<=prevP2[15:0]) begin
                                if (((iniP_c2[15:0]<currP2[15:0])&&(currP2[15:0]-iniP_c2[15:0]>thr5))&&((iniP2[31:16]>currP2[31:16])&&(iniP2[31:16]-currP2[31:16]>thr4))) begin
                                    if (checkConc_sec2_2<0)  conc2=prevConc2+tempConc2;
                                end
                                else conc2=prevConc2+tempConc2;
                            end
                        end
                    end
                end
            end
            4'b1010: // arc-moves to the right from bottom
            begin
                if (prevOnTrack2==2'b00) begin
                    if ((currP2[31:16]>prevP2[31:16]) && (currP2[15:0]>prevP2[15:0])) begin
                        conc2=tempConc2;
                    end
                end
                else begin
                    if (currP2[31:16]>=prevP2[31:16]) begin
                        if (prevOnTrack2==2'b01) begin
                            if (currP2[15:0]<=prevP2[15:0]) begin
                                if ((prevP2[15:0]>iniP2[15:0])&&(prevP2[15:0]-iniP2[15:0]>=thr3)) begin
                                    if (checkConc_sec1_2>=0)  conc2=tempConc2;
                                end
                            end
                            else  conc2=prevConc2+tempConc2;
                        end
                        else begin
                            if (currP2[15:0]<=prevP2[15:0]) begin
                                if (((iniP_c2[15:0]>currP2[15:0])&&(iniP_c2[15:0]-currP2[15:0]>thr5))&&((iniP2[31:16]<currP2[31:16])&&(currP2[31:16]-iniP2[31:16]>thr4))) begin
                                    if (checkConc_sec2_2<0)  conc2=prevConc2+tempConc2;
                                end
                                else conc2=prevConc2+tempConc2;
                            end
                        end
                    end
                end
            end
            4'b1011: // arc-moves to the left from bottom
            begin
                if (prevOnTrack2==2'b00) begin
                    if ((currP2[31:16]<prevP2[31:16]) && (currP2[15:0]>prevP2[15:0])) begin
                        conc2=tempConc2;
                    end
                end
                else begin
                    if (currP2[31:16]<=prevP2[31:16]) begin
                        if (prevOnTrack2==2'b01) begin
                            if (currP2[15:0]<=prevP2[15:0]) begin
                                if ((prevP2[15:0]>iniP2[15:0])&&(prevP2[15:0]-iniP2[15:0]>=thr3)) begin
                                    if (checkConc_sec1_2<=0)  conc2=tempConc2;
                                end
                            end
                            else  conc2=prevConc2+tempConc2;
                        end
                        else begin
                            if (currP2[15:0]<=prevP2[15:0]) begin
                                if (((iniP_c2[15:0]>currP2[15:0])&&(iniP_c2[15:0]-currP2[15:0]>thr5))&&((iniP2[31:16]>currP2[31:16])&&(iniP2[31:16]-currP2[31:16]>thr4))) begin
                                    if (checkConc_sec2_2>0)  conc2=prevConc2+tempConc2;
                                end
                                else conc2=prevConc2+tempConc2;
                            end
                        end
                    end
                end
            end
            default: conc2=0;
        endcase    
    end


// ---------------------------------------------------------------------------------------------------
    
    always@(currP1, prevP1, prevOnTrack1,iniP1)
    begin
        case(slv_reg0[19:16])
            4'b0100: // arc-moves up from right
            begin
                if ((prevOnTrack1==2'b01) && (currP1[15:0]<=prevP1[15:0]) && (currP1[31:16]<=prevP1[31:16]) && ((prevP1[31:16]>iniP1[31:16])&&(prevP1[31:16]-iniP1[31:16]>=thr3)) && (checkConc_sec1_1>=0))
                    nextIniP_c1=prevP1;
                else nextIniP_c1=iniP_c1;
            end
            //////////////////////////////////////////////////////////////
            4'b0101: // arc-moves up from right
            begin
                if ((prevOnTrack1==2'b01) && (currP1[15:0]>=prevP1[15:0]) && (currP1[31:16]<=prevP1[31:16]) && ((prevP1[31:16]>iniP1[31:16])&&(prevP1[31:16]-iniP1[31:16]>=thr3)) && (checkConc_sec1_1<=0))
                    nextIniP_c1=prevP1;
                else nextIniP_c1=iniP_c1;
            end
            4'b0110: // arc-moves up from right
            begin
                if ((prevOnTrack1==2'b01) && (currP1[15:0]<=prevP1[15:0]) && (currP1[31:16]>=prevP1[31:16]) && ((prevP1[31:16]<iniP1[31:16])&&(iniP1[31:16]-prevP1[31:16]>=thr3)) && (checkConc_sec1_1<=0))
                    nextIniP_c1=prevP1;
                else nextIniP_c1=iniP_c1;
            end
            4'b0111: // arc-moves up from right
            begin
                if ((prevOnTrack1==2'b01) && (currP1[15:0]>=prevP1[15:0]) && (currP1[31:16]>=prevP1[31:16]) && ((prevP1[31:16]<iniP1[31:16])&&(iniP1[31:16]-prevP1[31:16]>=thr3)) && (checkConc_sec1_1>=0))
                    nextIniP_c1=prevP1;
                else nextIniP_c1=iniP_c1;
            end
            4'b1000: // arc-moves up from right
            begin
                if ((prevOnTrack1==2'b01) && (currP1[15:0]>=prevP1[15:0]) && (currP1[31:16]>=prevP1[31:16]) && ((prevP1[15:0]<iniP1[15:0])&&(iniP1[15:0]-prevP1[15:0]>=thr3)) && (checkConc_sec1_1<=0))
                    nextIniP_c1=prevP1;
                else nextIniP_c1=iniP_c1;
            end
            4'b1001: // arc-moves up from right
            begin
                if ((prevOnTrack1==2'b01) && (currP1[15:0]>=prevP1[15:0]) && (currP1[31:16]<=prevP1[31:16]) && ((prevP1[15:0]<iniP1[15:0])&&(iniP1[15:0]-prevP1[15:0]>=thr3)) && (checkConc_sec1_1>=0))
                    nextIniP_c1=prevP1;
                else nextIniP_c1=iniP_c1;
            end
            4'b1010: // arc-moves up from right
            begin
                if ((prevOnTrack1==2'b01) && (currP1[15:0]<=prevP1[15:0]) && (currP1[31:16]>=prevP1[31:16]) && ((prevP1[15:0]>iniP1[15:0])&&(prevP1[15:0]-iniP1[15:0]>=thr3)) && (checkConc_sec1_1>=0))
                    nextIniP_c1=prevP1;
                else nextIniP_c1=iniP_c1;
            end
            4'b1011: // arc-moves up from right
            begin
                if ((prevOnTrack1==2'b01) && (currP1[15:0]<=prevP1[15:0]) && (currP1[31:16]<=prevP1[31:16]) && ((prevP1[15:0]>iniP1[15:0])&&(prevP1[15:0]-iniP1[15:0]>=thr3)) && (checkConc_sec1_1<=0))
                    nextIniP_c1=prevP1;
                else nextIniP_c1=iniP_c1;
            end
            default: nextIniP_c1=0;
        endcase    
    end
    
     
     
   
     always@(currP2, prevP2, prevOnTrack2,iniP2)
     begin
         case(slv_reg0[23:20])
             4'b0100: // arc-moves up from right
             begin
                 if ((prevOnTrack2==2'b01) && (currP2[15:0]<=prevP2[15:0]) && (currP2[31:16]<=prevP2[31:16]) && ((prevP2[31:16]>iniP2[31:16])&&(prevP2[31:16]-iniP2[31:16]>=thr3)) && (checkConc_sec1_2>=0))
                     nextIniP_c2=prevP2;
                 else nextIniP_c2=iniP_c2;
             end
             //////////////////////////////////////////////////////////////
             4'b0101: // arc-moves up from right
             begin
                 if ((prevOnTrack2==2'b01) && (currP2[15:0]>=prevP2[15:0]) && (currP2[31:16]<=prevP2[31:16]) && ((prevP2[31:16]>iniP2[31:16])&&(prevP2[31:16]-iniP2[31:16]>=thr3)) && (checkConc_sec1_2<=0))
                     nextIniP_c2=prevP2;
                 else nextIniP_c2=iniP_c2;
             end
             4'b0110: // arc-moves up from right
             begin
                 if ((prevOnTrack2==2'b01) && (currP2[15:0]<=prevP2[15:0]) && (currP2[31:16]>=prevP2[31:16]) && ((prevP2[31:16]<iniP2[31:16])&&(iniP2[31:16]-prevP2[31:16]>=thr3)) && (checkConc_sec1_2<=0))
                     nextIniP_c2=prevP2;
                 else nextIniP_c2=iniP_c2;
             end
             4'b0111: // arc-moves up from right
             begin
                 if ((prevOnTrack2==2'b01) && (currP2[15:0]>=prevP2[15:0]) && (currP2[31:16]>=prevP2[31:16]) && ((prevP2[31:16]<iniP2[31:16])&&(iniP2[31:16]-prevP2[31:16]>=thr3)) && (checkConc_sec1_2>=0))
                     nextIniP_c2=prevP2;
                 else nextIniP_c2=iniP_c2;
             end
             4'b1000: // arc-moves up from right
             begin
                 if ((prevOnTrack2==2'b01) && (currP2[15:0]>=prevP2[15:0]) && (currP2[31:16]>=prevP2[31:16]) && ((prevP2[15:0]<iniP2[15:0])&&(iniP2[15:0]-prevP2[15:0]>=thr3)) && (checkConc_sec1_2<=0))
                     nextIniP_c2=prevP2;
                 else nextIniP_c2=iniP_c2;
             end
             4'b1001: // arc-moves up from right
             begin
                 if ((prevOnTrack2==2'b01) && (currP2[15:0]>=prevP2[15:0]) && (currP2[31:16]<=prevP2[31:16]) && ((prevP2[15:0]<iniP2[15:0])&&(iniP2[15:0]-prevP2[15:0]>=thr3)) && (checkConc_sec1_2>=0))
                     nextIniP_c2=prevP2;
                 else nextIniP_c2=iniP_c2;
             end
             4'b1010: // arc-moves up from right
             begin
                 if ((prevOnTrack2==2'b01) && (currP2[15:0]<=prevP2[15:0]) && (currP2[31:16]>=prevP2[31:16]) && ((prevP2[15:0]>iniP2[15:0])&&(prevP2[15:0]-iniP2[15:0]>=thr3)) && (checkConc_sec1_2>=0))
                     nextIniP_c2=prevP2;
                 else nextIniP_c2=iniP_c2;
             end
             4'b1011: // arc-moves up from right
             begin
                 if ((prevOnTrack2==2'b01) && (currP2[15:0]<=prevP2[15:0]) && (currP2[31:16]<=prevP2[31:16]) && ((prevP2[15:0]>iniP2[15:0])&&(prevP2[15:0]-iniP2[15:0]>=thr3)) && (checkConc_sec1_2<=0))
                     nextIniP_c2=prevP2;
                 else nextIniP_c2=iniP_c2;
             end
             default: nextIniP_c2=0;
         endcase    
     end
     
      
     
    
    
// ------------------------------------------------------------------------------------------------------------------    
    
    always@(currP1, prevP1, iniP1, prevOnTrack1)
    begin
       if (~slv_reg1[1]) begin
           case(slv_reg0[19:16])
               4'b0000: //right
               begin
                   if ((((currP1[15:0]>iniP1[15:0])&&(currP1[15:0]-iniP1[15:0]<thr1)) || ((currP1[15:0]<=iniP1[15:0])&&(iniP1[15:0]-currP1[15:0]<thr1))) && (currP1[31:16]>prevP1[31:16]) && ((currP1[31:16]>iniP1[31:16]) && ((currP1[31:16]-iniP1[31:16])>thr2)) && (prevOnTrack1==2'b01))
                     result1=1;
                   else result1=0;
               end
               4'b0001: //left
               begin
                   if ((((currP1[15:0]>iniP1[15:0])&&(currP1[15:0]-iniP1[15:0]<thr1)) || ((currP1[15:0]<=iniP1[15:0])&&(iniP1[15:0]-currP1[15:0]<thr1))) && (currP1[31:16]<prevP1[31:16]) && ((currP1[31:16]<iniP1[31:16]) && ((iniP1[31:16]-currP1[31:16])>thr2)) && (prevOnTrack1==2'b01))
                     result1=1;
                   else result1=0;
               end
               4'b0010: //up
               begin
                   if ((((currP1[31:16]>iniP1[31:16])&&(currP1[31:16]-iniP1[31:16]<thr1)) || ((currP1[31:16]<=iniP1[31:16])&&(iniP1[31:16]-currP1[31:16]<thr1))) && (currP1[15:0]<prevP1[15:0]) && ((currP1[15:0]<iniP1[15:0]) && ((iniP1[15:0]-currP1[15:0])>thr2)) && (prevOnTrack1==2'b01))
                     result1=1;
                   else result1=0;
               end
               4'b0011: //down
               begin
                  if ((((currP1[31:16]>iniP1[31:16])&&(currP1[31:16]-iniP1[31:16]<thr1)) || ((currP1[31:16]<=iniP1[31:16])&&(iniP1[31:16]-currP1[31:16]<thr1))) && (currP1[15:0]>prevP1[15:0]) && ((currP1[15:0]>iniP1[15:0]) && ((currP1[15:0]-iniP1[15:0])>thr2)) && (prevOnTrack1==2'b01))
                    result1=1;
                  else result1=0;
               end
               4'b0100: // arc-moves up from right
               begin
                if ((prevOnTrack1==2'b10) && (currP1[15:0]<=prevP1[15:0]) && (currP1[31:16]<=prevP1[31:16]) && (((iniP_c1[31:16]>currP1[31:16])&&(iniP_c1[31:16]-currP1[31:16]>thr5))&&((iniP1[15:0]>currP1[15:0])&&(iniP1[15:0]-currP1[15:0]>thr4))) && (checkConc_sec2_1>=0))
                    result1=1;
                else
                    result1=0;
               end
               //////////////////////////////////////////////////////////////
               4'b0101: // arc-moves up from right
                begin
                if ((prevOnTrack1==2'b10) && (currP1[15:0]>=prevP1[15:0]) && (currP1[31:16]<=prevP1[31:16]) && (((iniP_c1[31:16]>currP1[31:16])&&(iniP_c1[31:16]-currP1[31:16]>thr5))&&((iniP1[15:0]<currP1[15:0])&&(currP1[15:0]-iniP1[15:0]>thr4))) && (checkConc_sec2_1<=0))
                   result1=1;
                else
                   result1=0;
                end
                4'b0110: // arc-moves up from right
                begin
                    if ((prevOnTrack1==2'b10) && (currP1[15:0]<=prevP1[15:0]) && (currP1[31:16]>=prevP1[31:16]) && (((iniP_c1[31:16]<currP1[31:16])&&(currP1[31:16]-iniP_c1[31:16]>thr5))&&((iniP1[15:0]>currP1[15:0])&&(iniP1[15:0]-currP1[15:0]>thr4))) && (checkConc_sec2_1<=0))
                        result1=1;
                    else
                        result1=0;
                end
                4'b0111: // arc-moves up from right
                begin
                    if ((prevOnTrack1==2'b10) && (currP1[15:0]>=prevP1[15:0]) && (currP1[31:16]>=prevP1[31:16]) && (((iniP_c1[31:16]<currP1[31:16])&&(currP1[31:16]-iniP_c1[31:16]>thr5))&&((iniP1[15:0]<currP1[15:0])&&(currP1[15:0]-iniP1[15:0]>thr4))) && (checkConc_sec2_1>=0))
                        result1=1;
                    else
                        result1=0;
                end
                4'b1000: // arc-moves up from right
                begin
                    if ((prevOnTrack1==2'b10) && (currP1[15:0]>=prevP1[15:0]) && (currP1[31:16]>=prevP1[31:16]) && (((iniP_c1[15:0]<currP1[15:0])&&(currP1[15:0]-iniP_c1[15:0]>thr5))&&((iniP1[31:16]<currP1[31:16])&&(currP1[31:16]-iniP1[31:16]>thr4))) && (checkConc_sec2_1<=0))
                        result1=1;
                    else
                        result1=0;
                end
                4'b1001: // arc-moves up from right
                begin
                    if ((prevOnTrack1==2'b10) && (currP1[15:0]<=prevP1[15:0]) && (currP1[31:16]<=prevP1[31:16]) && (((iniP_c1[15:0]<currP1[15:0])&&(currP1[15:0]-iniP_c1[15:0]>thr5))&&((iniP1[31:16]>currP1[31:16])&&(iniP1[31:16]-currP1[31:16]>thr4))) && (checkConc_sec2_1>=0))
                        result1=1;
                    else
                        result1=0;
                end
                4'b1010: // arc-moves up from right
                begin
                    if ((prevOnTrack1==2'b10) && (currP1[15:0]<=prevP1[15:0]) && (currP1[31:16]>=prevP1[31:16]) && (((iniP_c1[15:0]>currP1[15:0])&&(iniP_c1[15:0]-currP1[15:0]>thr5))&&((iniP1[31:16]<currP1[31:16])&&(currP1[31:16]-iniP1[31:16]>thr4))) && (checkConc_sec2_1>=0))
                        result1=1;
                    else
                        result1=0;
                end
                4'b1011: // arc-moves up from right
                begin
                    if ((prevOnTrack1==2'b10) && (currP1[15:0]<=prevP1[15:0]) && (currP1[31:16]<=prevP1[31:16]) && (((iniP_c1[15:0]>currP1[15:0])&&(iniP_c1[15:0]-currP1[15:0]>thr5))&&((iniP1[31:16]>currP1[31:16])&&(iniP1[31:16]-currP1[31:16]>thr4))) && (checkConc_sec2_1<=0))
                        result1=1;
                    else
                        result1=0;
                end
               default: result1=0;
           endcase   
       end 
    end
    
    
    
    always@(currP2, prevP2, iniP2, prevOnTrack2)
    begin
       if (~slv_reg1[2]) begin
           case(slv_reg0[23:20])
               4'b0000: //right
               begin
                   if ((((currP2[15:0]>iniP2[15:0])&&(currP2[15:0]-iniP2[15:0]<thr1)) || ((currP2[15:0]<=iniP2[15:0])&&(iniP2[15:0]-currP2[15:0]<thr1))) && (currP2[31:16]>prevP2[31:16]) && ((currP2[31:16]>iniP2[31:16]) && ((currP2[31:16]-iniP2[31:16])>thr2)) && (prevOnTrack2==2'b01))
                     result2=1;
                   else result2=0;
               end
               4'b0001: //left
               begin
                   if ((((currP2[15:0]>iniP2[15:0])&&(currP2[15:0]-iniP2[15:0]<thr1)) || ((currP2[15:0]<=iniP2[15:0])&&(iniP2[15:0]-currP2[15:0]<thr1))) && (currP2[31:16]<prevP2[31:16]) && ((currP2[31:16]<iniP2[31:16]) && ((iniP2[31:16]-currP2[31:16])>thr2)) && (prevOnTrack2==2'b01))
                     result2=1;
                   else result2=0;
               end
               4'b0010: //up
               begin
                   if ((((currP2[31:16]>iniP2[31:16])&&(currP2[31:16]-iniP2[31:16]<thr1)) || ((currP2[31:16]<=iniP2[31:16])&&(iniP2[31:16]-currP2[31:16]<thr1))) && (currP2[15:0]<prevP2[15:0]) && ((currP2[15:0]<iniP2[15:0]) && ((iniP2[15:0]-currP2[15:0])>thr2)) && (prevOnTrack2==2'b01))
                     result2=1;
                   else result2=0;
               end
               4'b0011: //down
              begin
                  if ((((currP2[31:16]>iniP2[31:16])&&(currP2[31:16]-iniP2[31:16]<thr1)) || ((currP2[31:16]<=iniP2[31:16])&&(iniP2[31:16]-currP2[31:16]<thr1))) && (currP2[15:0]>prevP2[15:0]) && ((currP2[15:0]>iniP2[15:0]) && ((currP2[15:0]-iniP2[15:0])>thr2)) && (prevOnTrack2==2'b01))
                    result2=1;
                  else result2=0;
               end
               4'b0100: // arc-moves up from right
              begin
               if ((prevOnTrack2==2'b10) && (currP2[15:0]<=prevP2[15:0]) && (currP2[31:16]<=prevP2[31:16]) && (((iniP_c2[31:16]>currP2[31:16])&&(iniP_c2[31:16]-currP2[31:16]>thr5))&&((iniP2[15:0]>currP2[15:0])&&(iniP2[15:0]-currP2[15:0]>thr4))) && (checkConc_sec2_2>=0))
                   result2=1;
               else
                   result2=0;
              end
              //////////////////////////////////////////////////////////////
              4'b0101: // arc-moves up from right
              begin
              if ((prevOnTrack2==2'b10) && (currP2[15:0]>=prevP2[15:0]) && (currP2[31:16]<=prevP2[31:16]) && (((iniP_c2[31:16]>currP2[31:16])&&(iniP_c2[31:16]-currP2[31:16]>thr5))&&((iniP2[15:0]<currP2[15:0])&&(currP2[15:0]-iniP2[15:0]>thr4))) && (checkConc_sec2_2<=0))
                 result2=1;
              else
                 result2=0;
              end
              4'b0110: // arc-moves up from right
              begin
                  if ((prevOnTrack2==2'b10) && (currP2[15:0]<=prevP2[15:0]) && (currP2[31:16]>=prevP2[31:16]) && (((iniP_c2[31:16]<currP2[31:16])&&(currP2[31:16]-iniP_c2[31:16]>thr5))&&((iniP2[15:0]>currP2[15:0])&&(iniP2[15:0]-currP2[15:0]>thr4))) && (checkConc_sec2_2<=0))
                      result2=1;
                  else
                      result2=0;
              end
              4'b0111: // arc-moves up from right
              begin
                  if ((prevOnTrack2==2'b10) && (currP2[15:0]>=prevP2[15:0]) && (currP2[31:16]>=prevP2[31:16]) && (((iniP_c2[31:16]<currP2[31:16])&&(currP2[31:16]-iniP_c2[31:16]>thr5))&&((iniP2[15:0]<currP2[15:0])&&(currP2[15:0]-iniP2[15:0]>thr4))) && (checkConc_sec2_2>=0))
                      result2=1;
                  else
                      result2=0;
              end
              4'b1000: // arc-moves up from right
              begin
                  if ((prevOnTrack2==2'b10) && (currP2[15:0]>=prevP2[15:0]) && (currP2[31:16]>=prevP2[31:16]) && (((iniP_c2[15:0]<currP2[15:0])&&(currP2[15:0]-iniP_c2[15:0]>thr5))&&((iniP2[31:16]<currP2[31:16])&&(currP2[31:16]-iniP2[31:16]>thr4))) && (checkConc_sec2_2<=0))
                      result2=1;
                  else
                      result2=0;
              end
              4'b1001: // arc-moves up from right
              begin
                  if ((prevOnTrack2==2'b10) && (currP2[15:0]<=prevP2[15:0]) && (currP2[31:16]<=prevP2[31:16]) && (((iniP_c2[15:0]<currP2[15:0])&&(currP2[15:0]-iniP_c2[15:0]>thr5))&&((iniP2[31:16]>currP2[31:16])&&(iniP2[31:16]-currP2[31:16]>thr4))) && (checkConc_sec2_2>=0))
                      result2=1;
                  else
                      result2=0;
              end
              4'b1010: // arc-moves up from right
              begin
                  if ((prevOnTrack2==2'b10) && (currP2[15:0]<=prevP2[15:0]) && (currP2[31:16]>=prevP2[31:16]) && (((iniP_c2[15:0]>currP2[15:0])&&(iniP_c2[15:0]-currP2[15:0]>thr5))&&((iniP2[31:16]<currP2[31:16])&&(currP2[31:16]-iniP2[31:16]>thr4))) && (checkConc_sec2_2>=0))
                      result2=1;
                  else
                      result2=0;
              end
              4'b1011: // arc-moves up from right
              begin
                  if ((prevOnTrack2==2'b10) && (currP2[15:0]<=prevP2[15:0]) && (currP2[31:16]<=prevP2[31:16]) && (((iniP_c2[15:0]>currP2[15:0])&&(iniP_c2[15:0]-currP2[15:0]>thr5))&&((iniP2[31:16]>currP2[31:16])&&(iniP2[31:16]-currP2[31:16]>thr4))) && (checkConc_sec2_2<=0))
                      result2=1;
                  else
                      result2=0;
              end
               default: result2=0;
           endcase   
       end 
    end
      
    
// --------------------------------------------------------------------------------------------------------
    
     always @( posedge S_AXI_ACLK )
       begin
           if ( S_AXI_ARESETN == 1'b0 )
             begin
                 slv_reg1[1]<=0;
                 slv_reg1[2]<=0;
                 /*slv_reg1[3]<=0;
                 slv_reg1[4]<=0;*/
             end 
           else begin
             if (slv_reg_wren && axi_awaddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] == 2'h0 && S_AXI_WDATA[0]) begin   
                 slv_reg1[1]<=0;
                 slv_reg1[2]<=0;
                 /*slv_reg1[3]<=0;
                 slv_reg1[4]<=0;*/
             end 
             else begin
                slv_reg1[1]<=result1;
                slv_reg1[2]<=result2;
                /*slv_reg1[3]<=result3;
                slv_reg1[4]<=result4;*/
             end
           end
       end
       
    /*always @( posedge S_AXI_ACLK )
      begin
        if ( S_AXI_ARESETN == 1'b0 )
          begin
            color_code_n_ctrl[2:1] <= 2'b00;
            color_code_n_ctrl[4:3] <= 2'b00;
            color_code_n_ctrl[6:5] <= 2'b00;
            color_code_n_ctrl[8:7] <= 2'b00;
          end
        else
          begin
            color_code_n_ctrl[2:1] <= 2'b00;
            color_code_n_ctrl[4:3] <= 2'b01;
            color_code_n_ctrl[6:5] <= 2'b10;
            color_code_n_ctrl[8:7] <= 2'b11;          
          end
      end*/
    
    always @( posedge S_AXI_ACLK )
    begin
      if ( S_AXI_ARESETN == 1'b0 )
        begin
          color_code_n_ctrl[0]<= 0;
          color_code_n_ctrl[2:1] <= 0;
          color_code_n_ctrl[4:3] <= 0;
          slv_reg1[0]<= 0;
        end 
      else begin
        if (slv_reg_wren && axi_awaddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] == 2'h0 && S_AXI_WDATA[0]) begin
              color_code_n_ctrl[0]<=1; 
              color_code_n_ctrl[2:1] <= S_AXI_WDATA[2:1];
              color_code_n_ctrl[4:3] <= S_AXI_WDATA[4:3];
              slv_reg1[0]<= 0;
        end
        else begin
            if (counter1 == 10 && counter2 == 10/* && counter3 == 10 && counter4 == 10*/) begin
                color_code_n_ctrl[0]<= 0; 
                slv_reg1[0]<= 1;
            end
        end
      end
    end
    
    assign color_control = color_code_n_ctrl[0];
    assign color_choice1 = color_code_n_ctrl[2:1];
    assign color_choice2 = color_code_n_ctrl[4:3];
    /*assign color_choice3 = color_code_n_ctrl[6:5];
    assign color_choice4 = color_code_n_ctrl[8:7];*/
    
    always @( posedge S_AXI_ACLK)
    begin
      if ( S_AXI_ARESETN == 1'b0 )
        begin
          slv_reg2 <= 0;
          slv_reg3 <= 0;
        end
      else if (ready_read_color1 || ready_read_color2)
        begin
          slv_reg2 <= coord1;
          slv_reg3 <= coord2;
        end
    end
       
	// User logic ends

	endmodule
