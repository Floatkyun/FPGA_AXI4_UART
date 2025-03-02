module top_axi_bram(
    input wire sys_clk,
    input wire sys_rst_n,
    input wire i_uart_rx,
    output wire o_uart_tx
);
parameter CLK_FREQ = 50000000;
parameter BAUD_RATE = 115200;
parameter PARITY = 0;
parameter BYTE_WIDTH = 4;
parameter A_WIDTH = 32;

wire awready;
wire awvalid;
wire [A_WIDTH-1:0] awaddr;
wire [7:0] awlen;

wire wready;
wire wvalid;
wire wlast;
wire [8*BYTE_WIDTH-1:0] wdata;

wire [1:0] bresp;
wire bready;
wire bvalid;

wire arready;
wire arvalid;
wire [A_WIDTH-1:0] araddr;
wire [7:0] arlen;

wire rready;
wire rvalid;
wire rlast;
wire [8*BYTE_WIDTH-1:0]  rdata;


uart2axi4 # (
    .CLK_FREQ(CLK_FREQ),
    .BAUD_RATE(BAUD_RATE),
    .PARITY(PARITY),
    .BYTE_WIDTH(BYTE_WIDTH),
    .A_WIDTH(A_WIDTH)
  )
  uart2axi4_inst (
    //系统时钟和复位信号
    .rstn(sys_rst_n),
    .clk(sys_clk),
    //AXI4总线
    //写地址通道
    .awready(awready),
    .awvalid(awvalid),
    .awaddr(awaddr),
    .awlen(awlen),
    //写数据通道
    .wready(wready),
    .wvalid(wvalid),
    .wlast(wlast),
    .wdata(wdata),
    //写响应通道
    .bresp(bresp),
    .bready(bready),
    .bvalid(bvalid),
    //读地址通道
    .arready(arready),
    .arvalid(arvalid),
    .araddr(araddr),
    .arlen(arlen),
    //读数据通道
    .rready(rready),
    .rvalid(rvalid),
    .rlast(rlast),
    .rdata(rdata),
    //串口
    .i_uart_rx(i_uart_rx),
    .o_uart_tx(o_uart_tx)
  );

bram u_bram(
    .rsta_busy(),                       // output wire rsta_busy
    .rstb_busy(),                       // output wire rstb_busy
    //系统时钟和复位信号
    .s_aclk(sys_clk),                   // input wire s_aclk
    .s_aresetn(sys_rst_n),              // input wire s_aresetn
    //AXI4总线
    //写地址通道
    .s_axi_awid(0),                     // input wire [3 : 0] s_axi_awid
    .s_axi_awaddr(awaddr),              // input wire [31 : 0] s_axi_awaddr
    .s_axi_awlen(awlen),                // input wire [7 : 0] s_axi_awlen
    .s_axi_awsize(3'b010),              // input wire [2 : 0] s_axi_awsize//字节数 4byte
    .s_axi_awburst(2'b01),              // input wire [1 : 0] s_axi_awburst//突发类型 地址递增
    .s_axi_awvalid(awvalid),            // input wire s_axi_awvalid
    .s_axi_awready(awready),            // output wire s_axi_awready
    //写数据通道
    .s_axi_wdata(wdata),                // input wire [31 : 0] s_axi_wdata
    .s_axi_wstrb(4'b1111),              // input wire [3 : 0] s_axi_wstrb //掩码
    .s_axi_wlast(wlast),                // input wire s_axi_wlast
    .s_axi_wvalid(wvalid),              // input wire s_axi_wvalid
    .s_axi_wready(wready),              // output wire s_axi_wready
    //写响应通道
    .s_axi_bid(0),                       // output wire [3 : 0] s_axi_bid
    .s_axi_bresp(bresp),                     // output wire [1 : 0] s_axi_bresp
    .s_axi_bvalid(bvalid),              // output wire s_axi_bvalid
    .s_axi_bready(bready),              // input wire s_axi_bready
    //读地址通道
    .s_axi_arid(0),                     // input wire [3 : 0] s_axi_arid
    .s_axi_araddr(araddr),              // input wire [31 : 0] s_axi_araddr
    .s_axi_arlen(arlen),                // input wire [7 : 0] s_axi_arlen
    .s_axi_arsize(3'b010),              // input wire [2 : 0] s_axi_arsize
    .s_axi_arburst(2'b01),              // input wire [1 : 0] s_axi_arburst
    .s_axi_arvalid(arvalid),            // input wire s_axi_arvalid
    .s_axi_arready(arready),            // output wire s_axi_arready
    //读数据通道
    .s_axi_rid(0),                       // output wire [3 : 0] s_axi_rid
    .s_axi_rdata(rdata),                // output wire [31 : 0] s_axi_rdata
    .s_axi_rresp(),                     // output wire [1 : 0] s_axi_rresp
    .s_axi_rlast(rlast),                // output wire s_axi_rlast
    .s_axi_rvalid(rvalid),              // output wire s_axi_rvalid
    .s_axi_rready(rready)               // input wire s_axi_rready
  );

endmodule

/*
//全局信号
output wire 				rsta_busy			;
output wire 				rstb_busy			;
input  wire 				s_aclk				;//时钟 
input  wire 				s_aresetn			;//复位 
//写地址通道
input  reg [3:0]			s_axi_awid			;//写地址ID,这个信号是写地址信号组的IDtag      
input  reg [31:0]			s_axi_awaddr		;//写地址    
input  reg [7:0]			s_axi_awlen			;//突发次数
input  reg [2:0]			s_axi_awsize		;//一次传输字节数。一个时钟节拍传输的数据的最大位。s_axi_awsize = 3'b000,传输1byte。s_axi_awsize = 3'b001,传输2byte。s_axi_awsize = 3'b010,传输4byte。s_axi_awsize = 3'b011,传输8byte。s_axi_awsize = 3'b100,传输16byte。s_axi_awsize = 3'b101,传输32byte。s_axi_awsize = 3'b110,传输64byte。s_axi_awsize = 3'b111,传输128byte。
input  reg [1:0]			s_axi_awburst		;//突发类型
input  reg 				s_axi_awvalid		;//握手信号，写地址有效。'1'有效
output wire 				s_axi_awready		;//握手。写地址准备好，'1'设备准备好
//写地址通道
input  reg [31:0]			s_axi_wdata			;//写入数据     
input  reg [3:0]			s_axi_wstrb			;//写阀门，WSTRB[n]表示的区间为WDATA[(8*n) + 7:(8*n)];说明：s_axi_wstrb[0]表示s_axi_wdata[7:0]有效。依次类推。
input  reg 				s_axi_wlast			;//最后一个数据  
input  reg 				s_axi_wvalid		;//写数据有效
output wire 				s_axi_wready		;//写数据准备就绪
//写响应通道
output wire [3:0]			s_axi_bid			;//响应ID，这个数值必须与AWID的数值匹配。
output wire [1:0]			s_axi_bresp			;//写入响应，这个信号指明写事务的状态。可能有的响应：OKAY,EXOKAY,SLVERR,DECERR  
output wire 				s_axi_bvalid		;//写响应有效。'1'有效
input  reg 				s_axi_bready		;//接收响应就绪，该信号表示主机已经能够接受响应信息。'1'主机就绪
//读地址通道
input  reg [3:0]			s_axi_arid			;//读地址ID      
input  reg [31:0]			s_axi_araddr		;//低地址
input  reg [7:0]			s_axi_arlen			;//读地址突发长度
input  reg [2:0]			s_axi_arsize		;//一次传输字节数
input  reg [1:0]			s_axi_arburst		;//突发类型
input  reg 				s_axi_arvalid		;//握手信号，读地址有效。该信号一直保持，直到ARREADY为高。'1'地址和控制信号有效。
output wire 				s_axi_arready		;//握手信号，读地址就绪，指明设备已经准备好接收数据了。'1'设备就绪。
//读数据通道
output wire [3:0]			s_axi_rid			;//读IDtag。RID的数值必须与ARID的数值匹配
output wire [31:0]			s_axi_rdata			;//读数据
output wire [1:0]			s_axi_rresp			;//读响应。这个信号指明读传输状态
output wire 				s_axi_rlast			;//读取最后一个数据
output wire 				s_axi_rvalid		;//读取有效'1'读数据有效
input  reg 				s_axi_rready		;//读数据就绪'1'主机就绪

*/