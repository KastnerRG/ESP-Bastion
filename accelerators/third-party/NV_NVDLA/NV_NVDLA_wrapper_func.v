// File Name: NV_NVDLA_wrapper.v
`timescale 1ns/1ps

module NV_NVDLA_wrapper
  (
   dla_core_clk,
   dla_csb_clk,
   dla_reset_rstn,
   direct_reset,
   paddr,
   penable,
   psel,
   pwdata,
   pwrite,
   prdata,
   pready,
   pslverr,
   nvdla_core2dbb_awvalid,
   nvdla_core2dbb_awready,
   nvdla_core2dbb_awid,
   nvdla_core2dbb_awlen,
   nvdla_core2dbb_awaddr,
   nvdla_core2dbb_wvalid,
   nvdla_core2dbb_wready,
   nvdla_core2dbb_wdata,
   nvdla_core2dbb_wstrb,
   nvdla_core2dbb_wlast,
   nvdla_core2dbb_arvalid,  //
   nvdla_core2dbb_arready,  
   nvdla_core2dbb_arid,     //
   nvdla_core2dbb_arlen,    //
   nvdla_core2dbb_araddr,   //
   nvdla_core2dbb_bresp,
   nvdla_core2dbb_bvalid,
   nvdla_core2dbb_bready,
   nvdla_core2dbb_bid,
   nvdla_core2dbb_rvalid,
   nvdla_core2dbb_rready,   //
   nvdla_core2dbb_rid,
   nvdla_core2dbb_rlast,
   nvdla_core2dbb_rdata,
   nvdla_core2dbb_rresp,
   nvdla_core2dbb_awsize, // 3'b011
   nvdla_core2dbb_arsize, // 3'b011
   nvdla_core2dbb_awburst,// 2'b01
   nvdla_core2dbb_arburst,// 2'b01
   nvdla_core2dbb_awlock, // 0
   nvdla_core2dbb_arlock, // 0
   nvdla_core2dbb_awcache,
   nvdla_core2dbb_arcache,
   nvdla_core2dbb_awprot, // 3'b010
   nvdla_core2dbb_arprot, // 3'b010
   nvdla_core2dbb_awqos,  // 4'b0000
   nvdla_core2dbb_awatop, // 6'b000000
   nvdla_core2dbb_awregion,//6'b000000
   nvdla_core2dbb_arqos,  // 4'b0000
   nvdla_core2dbb_arregion,//6'b000000
   dla_intr
   );

   ////////////////////////////////////////////////////////////////////////////////
   input dla_core_clk;
   input dla_csb_clk;
   input dla_reset_rstn;
   input direct_reset;
   //apb
   input psel;
   input penable;
   input pwrite;
   input [31:0] paddr;
   input [31:0] pwdata;
   output [31:0] prdata;
   output pready;
   output pslverr;
   ///////////////
   output reg 		 nvdla_core2dbb_awvalid;
   wire hij_awvalid;

   input wire 		 nvdla_core2dbb_awready;

   output reg [7:0] 	        nvdla_core2dbb_awid;
   wire [7:0] hij_awid;

   output reg [7:0] 	        nvdla_core2dbb_awlen;
   wire [7:0] hij_awlen;

   output reg [32 -1:0]      nvdla_core2dbb_awaddr;
   wire [32-1:0] hij_awaddr;

   output reg 		 nvdla_core2dbb_wvalid;
   wire hij_wvalid;
    
   input wire 		 nvdla_core2dbb_wready;

   output reg [64 -1:0] nvdla_core2dbb_wdata;
   wire [64-1:0] hij_wdata;

   output reg [64/8-1:0] nvdla_core2dbb_wstrb;
   wire [64/8-1:0] hij_wstrb; // FF

   output reg 		  nvdla_core2dbb_wlast;
   wire hij_wlast;

   output reg 		  nvdla_core2dbb_arvalid;//
   wire hij_arvalid;      

   input wire 		  nvdla_core2dbb_arready;

   output reg [7:0] 	  nvdla_core2dbb_arid;//
   wire [7:0]   hij_arid;

   output reg [7:0] 	  nvdla_core2dbb_arlen;//
   wire [7:0]   hij_arlen;

   output reg [32 -1:0]  nvdla_core2dbb_araddr;//
   wire  [32-1:0]   hij_araddr;

   input wire  [1:0]	  nvdla_core2dbb_bresp;
   input wire 		  nvdla_core2dbb_bvalid;
   output reg 		  nvdla_core2dbb_bready;
   wire                hij_bready;
   input wire [7:0] 	  nvdla_core2dbb_bid;
   input wire 		  nvdla_core2dbb_rvalid;

   output reg 		  nvdla_core2dbb_rready;//
   wire   hij_rready;

   // pre-set ports
   input wire [7:0] 	  nvdla_core2dbb_rid;
   input wire 		  nvdla_core2dbb_rlast;
   input wire [64 -1:0]   nvdla_core2dbb_rdata;
   input wire [1:0] 	  nvdla_core2dbb_rresp;
   output wire [2:0] 	  nvdla_core2dbb_awsize;
   output wire [2:0] 	  nvdla_core2dbb_arsize;
   output wire [1:0] 	  nvdla_core2dbb_awburst;
   output wire [1:0] 	  nvdla_core2dbb_arburst;
   output wire 		  nvdla_core2dbb_awlock;
   output wire 		  nvdla_core2dbb_arlock;
   output wire [3:0] 	  nvdla_core2dbb_awcache;
   output wire [3:0] 	  nvdla_core2dbb_arcache;
   output wire [2:0] 	  nvdla_core2dbb_awprot;
   output wire [2:0] 	  nvdla_core2dbb_arprot;
   output wire [3:0] 	  nvdla_core2dbb_awqos;
   output wire [5:0] 	  nvdla_core2dbb_awatop;
   output wire [3:0] 	  nvdla_core2dbb_awregion;
   output wire [3:0] 	  nvdla_core2dbb_arqos;
   output wire [3:0] 	  nvdla_core2dbb_arregion;
   ///////////////
   output 		  dla_intr;
   ////////////////////////////////////////////////////////////////////////////////

   // CSB connections
   wire 		  csb2nvdla_valid;
   wire 		  csb2nvdla_ready;
   wire [15:0] 		  csb2nvdla_addr;
   wire [31:0] 		  csb2nvdla_wdat;
   wire 		  csb2nvdla_write;
   wire 		  csb2nvdla_nposted;
   wire 		  nvdla2csb_valid;
   wire [31:0] 		  nvdla2csb_data;
   // NVDLA ports not used
   wire 		  global_clk_ovr_on;
   wire 		  tmc2slcg_disable_clock_gating;
   wire 		  test_mode;
   wire 		  nvdla2csb_wr_complete;
   wire [31:0] 		  nvdla_pwrbus_ram_c_pd;
   wire [31:0] 		  nvdla_pwrbus_ram_ma_pd;
   wire [31:0] 		  nvdla_pwrbus_ram_mb_pd;
   wire [31:0] 		  nvdla_pwrbus_ram_p_pd;
   wire [31:0] 		  nvdla_pwrbus_ram_o_pd;
   wire [31:0] 		  nvdla_pwrbus_ram_a_pd;
   ///////////////

   // set NVDLA ports not used
   assign global_clk_ovr_on = 1'b0;
   assign tmc2slcg_disable_clock_gating = 1'b0;
   assign test_mode = 1'b0;
   assign nvdla_pwrbus_ram_c_pd = 32'b0;
   assign nvdla_pwrbus_ram_ma_pd = 32'b0;
   assign nvdla_pwrbus_ram_mb_pd = 32'b0;
   assign nvdla_pwrbus_ram_p_pd = 32'b0;
   assign nvdla_pwrbus_ram_o_pd = 32'b0;
   assign nvdla_pwrbus_ram_a_pd = 32'b0;
   assign pslverr = 1'b0;
   
   // map NVDLA dbb channel to an AXI channel
   // set AXI channel ports not present on the NVDLA interface
   assign nvdla_core2dbb_awsize = 3'b011;
   assign nvdla_core2dbb_arsize = 3'b011;
   assign nvdla_core2dbb_awburst = 2'b01;
   assign nvdla_core2dbb_arburst = 2'b01;
   assign nvdla_core2dbb_awlock = 1'b0;
   assign nvdla_core2dbb_arlock = 1'b0;
   assign nvdla_core2dbb_awcache = 4'b0011;
   assign nvdla_core2dbb_arcache = 4'b0011;
   assign nvdla_core2dbb_awprot = 3'b010;
   assign nvdla_core2dbb_arprot = 3'b010;
   assign nvdla_core2dbb_awqos = 4'b0000;
   assign nvdla_core2dbb_arqos = 4'b0000;
   assign nvdla_core2dbb_awatop = 6'b000000;
   assign nvdla_core2dbb_awregion = 4'b0000;
   assign nvdla_core2dbb_arregion = 4'b0000;

   assign nvdla_core2dbb_awlen[7:4] = 4'b0000;
   assign nvdla_core2dbb_arlen[7:4] = 4'b0000;

   // Hijack axi read and write channels to perform arbitrary operations.
   // rename the signals to dma style
   // keep signals to original dma to avoid trouble
       
   initial begin
            nvdla_core2dbb_arlen[3:0] = 4'b0000;
            nvdla_core2dbb_arvalid = 0;
            nvdla_core2dbb_arid = 0;
            nvdla_core2dbb_araddr = 0;
            nvdla_core2dbb_rready = 0;

            nvdla_core2dbb_awlen[3:0] = 4'b0000;
            nvdla_core2dbb_awvalid = 0;
            nvdla_core2dbb_awid = 0;
            nvdla_core2dbb_awaddr = 0;
            nvdla_core2dbb_wvalid = 0;
            nvdla_core2dbb_wdata = 0;
            nvdla_core2dbb_wlast = 0;
            nvdla_core2dbb_wstrb = 8'hFF;
    // legal read
    #100000 nvdla_core2dbb_rready = 1;
            nvdla_core2dbb_bready = 1;
    #20    nvdla_core2dbb_arvalid = 1;
           nvdla_core2dbb_araddr = 32'hA1200000;
           nvdla_core2dbb_arlen[3:0] = 4'b0000;
    #20    nvdla_core2dbb_arvalid = 0;
           nvdla_core2dbb_araddr = 32'h00000000;
    // ILLEGAL read
    #600    nvdla_core2dbb_arvalid = 1;
           nvdla_core2dbb_araddr = 32'h0C000000;
           nvdla_core2dbb_arlen[3:0] = 4'b0000;
    #20    nvdla_core2dbb_arvalid = 0;
           nvdla_core2dbb_araddr = 32'h00000000;
    // legal write
    #600    nvdla_core2dbb_awvalid = 1;
           nvdla_core2dbb_awaddr = 32'hA1400000;
           nvdla_core2dbb_awlen[3:0] = 4'b0001;
    #20    nvdla_core2dbb_awvalid = 0;
           nvdla_core2dbb_awaddr = 0;
    #40    nvdla_core2dbb_wvalid = 1;
           nvdla_core2dbb_wdata = 64'h0123456789ABCDEF;
           nvdla_core2dbb_wlast = 0;
    #20    nvdla_core2dbb_wvalid = 1;
           nvdla_core2dbb_wdata = 64'hFEDCBA9876543210;
           nvdla_core2dbb_wlast = 1;
    #20    nvdla_core2dbb_wvalid = 0;
           nvdla_core2dbb_wdata = 0;
           nvdla_core2dbb_wlast = 0;
    // legal read from the addr just written
    #600    nvdla_core2dbb_arvalid = 1;
           nvdla_core2dbb_araddr = 32'hA1400000;
           nvdla_core2dbb_arlen[3:0] = 4'b0010;
    #20    nvdla_core2dbb_arvalid = 0;
           nvdla_core2dbb_araddr = 32'h00000000;
    // ILLEGAL write
    #600    nvdla_core2dbb_awvalid = 1;
           nvdla_core2dbb_awaddr = 32'h0B000000;
           nvdla_core2dbb_awlen[3:0] = 4'b0001;
    #20    nvdla_core2dbb_awvalid = 0;
           nvdla_core2dbb_awaddr = 0;
    #40    nvdla_core2dbb_wvalid = 1;
           nvdla_core2dbb_wdata = 64'h0123456789ABCDEF;
           nvdla_core2dbb_wlast = 0;
    #20    nvdla_core2dbb_wvalid = 1;
           nvdla_core2dbb_wdata = 64'hFEDCBA9876543210;
           nvdla_core2dbb_wlast = 1;
    #20    nvdla_core2dbb_wvalid = 0;
           nvdla_core2dbb_wdata = 0;
           nvdla_core2dbb_wlast = 0;
   end

   NV_nvdla NV_nvdla_0
     (
      .dla_core_clk(dla_core_clk) //|< i
      ,.dla_csb_clk(dla_csb_clk) //|< i
      ,.global_clk_ovr_on(global_clk_ovr_on) //|< i
      ,.tmc2slcg_disable_clock_gating(tmc2slcg_disable_clock_gating) //|< i
      ,.dla_reset_rstn(dla_reset_rstn) //|< i
      ,.direct_reset_(direct_reset) //|< i
      ,.test_mode(test_mode) //|< i
      ,.csb2nvdla_valid(csb2nvdla_valid) //|< i
      ,.csb2nvdla_ready(csb2nvdla_ready) //|> o
      ,.csb2nvdla_addr(csb2nvdla_addr) //|< i
      ,.csb2nvdla_wdat(csb2nvdla_wdat) //|< i
      ,.csb2nvdla_write(csb2nvdla_write) //|< i
      ,.csb2nvdla_nposted(csb2nvdla_nposted) //|< i
      ,.nvdla2csb_valid(nvdla2csb_valid) //|> o
      ,.nvdla2csb_data(nvdla2csb_data) //|> o
      ,.nvdla2csb_wr_complete() //|> o
      ,.nvdla_core2dbb_aw_awvalid(hij_awvalid) //|> o
      ,.nvdla_core2dbb_aw_awready(nvdla_core2dbb_awready) //|< i
      ,.nvdla_core2dbb_aw_awid(hij_awid) //|> o
      ,.nvdla_core2dbb_aw_awlen(hij_awlen[3:0]) //|> o
      ,.nvdla_core2dbb_aw_awaddr(hij_awaddr) //|> o
      ,.nvdla_core2dbb_w_wvalid(hij_wvalid) //|> o
      ,.nvdla_core2dbb_w_wready(nvdla_core2dbb_wready) //|< i
      ,.nvdla_core2dbb_w_wdata(hij_wdata) //|> o
      ,.nvdla_core2dbb_w_wstrb(hij_wstrb) //|> o
      ,.nvdla_core2dbb_w_wlast(hij_wlast) //|> o
      ,.nvdla_core2dbb_b_bvalid(nvdla_core2dbb_bvalid) //|< i
      ,.nvdla_core2dbb_b_bready(hij_bready) //|> o
      ,.nvdla_core2dbb_b_bid(nvdla_core2dbb_bid) //|< i
      ,.nvdla_core2dbb_ar_arvalid(hij_arvalid) //|> o
      ,.nvdla_core2dbb_ar_arready(nvdla_core2dbb_arready) //|< i
      ,.nvdla_core2dbb_ar_arid(hij_arid) //|> o
      ,.nvdla_core2dbb_ar_arlen(hij_arlen[3:0]) //|> o
      ,.nvdla_core2dbb_ar_araddr(hij_araddr) //|> o
      ,.nvdla_core2dbb_r_rvalid(nvdla_core2dbb_rvalid) //|< i
      ,.nvdla_core2dbb_r_rready(hij_rready) //|> o
      ,.nvdla_core2dbb_r_rid(nvdla_core2dbb_rid) //|< i
      ,.nvdla_core2dbb_r_rlast(nvdla_core2dbb_rlast) //|< i
      ,.nvdla_core2dbb_r_rdata(nvdla_core2dbb_rdata) //|< i
      ,.dla_intr(dla_intr) //|> o
      ,.nvdla_pwrbus_ram_c_pd(nvdla_pwrbus_ram_c_pd) //|< i
      ,.nvdla_pwrbus_ram_ma_pd(nvdla_pwrbus_ram_ma_pd) //|< i *
      ,.nvdla_pwrbus_ram_mb_pd(nvdla_pwrbus_ram_mb_pd) //|< i *
      ,.nvdla_pwrbus_ram_p_pd(nvdla_pwrbus_ram_p_pd) //|< i
      ,.nvdla_pwrbus_ram_o_pd(nvdla_pwrbus_ram_o_pd) //|< i
      ,.nvdla_pwrbus_ram_a_pd(nvdla_pwrbus_ram_a_pd) //|< i
      );

   NV_NVDLA_apb2csb apb2csb_0
     (
      .pclk(dla_csb_clk)
      ,.prstn(dla_reset_rstn)
      ,.csb2nvdla_ready(csb2nvdla_ready)
      ,.nvdla2csb_data(nvdla2csb_data)
      ,.nvdla2csb_valid(nvdla2csb_valid)
      ,.paddr(paddr)
      ,.penable(penable)
      ,.psel(psel)
      ,.pwdata(pwdata)
      ,.pwrite(pwrite)
      ,.csb2nvdla_addr(csb2nvdla_addr)
      ,.csb2nvdla_nposted(csb2nvdla_nposted)
      ,.csb2nvdla_valid(csb2nvdla_valid)
      ,.csb2nvdla_wdat(csb2nvdla_wdat)
      ,.csb2nvdla_write(csb2nvdla_write)
      ,.prdata(prdata)
      ,.pready(pready)
      );

   
endmodule
