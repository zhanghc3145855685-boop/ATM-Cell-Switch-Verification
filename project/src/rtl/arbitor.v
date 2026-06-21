module arbitor ( 
            clk                ,
            rst_n              ,
                               
            fwd_rden           ,
            fwd_addr           ,
            fwd_data           ,
                               
            rx0_rxreq          ,
            rx0_rxack          ,
            rx0_nni_VPI        , 
            rx0_nni_VCI        ,
            rx0_nni_CLP        , 
            rx0_nni_PT         , 
            rx0_nni_HEC        ,
            rx0_nni_Payload    ,
                   
            rx1_rxreq          ,
            rx1_rxack          ,
            rx1_nni_VPI        ,
            rx1_nni_VCI        ,
            rx1_nni_CLP        , 
            rx1_nni_PT         ,
            rx1_nni_HEC        ,
            rx1_nni_Payload    ,
                   
            rx2_rxreq          ,
            rx2_rxack          ,
            rx2_nni_VPI        ,
            rx2_nni_VCI        ,
            rx2_nni_CLP        , 
            rx2_nni_PT         ,
            rx2_nni_HEC        ,
            rx2_nni_Payload    ,
                   
            rx3_rxreq          ,
            rx3_rxack          ,
            rx3_nni_VPI        ,
            rx3_nni_VCI        ,
            rx3_nni_CLP        , 
            rx3_nni_PT         ,
            rx3_nni_HEC        ,
            rx3_nni_Payload    ,
            
            tx0_txreq          ,
            tx0_txack          ,
            tx0_uni_VPI        , 
            tx0_uni_VCI        ,
            tx0_uni_CLP        ,
            tx0_uni_PT         ,
            tx0_uni_HEC        ,
            tx0_uni_Payload    ,
            
            tx1_txreq          ,
            tx1_txack          ,
            tx1_uni_VPI        ,
            tx1_uni_VCI        ,
            tx1_uni_CLP        ,
            tx1_uni_PT         ,
            tx1_uni_HEC        ,
            tx1_uni_Payload    ,
            
            tx2_txreq          ,
            tx2_txack          ,
            tx2_uni_VPI        ,
            tx2_uni_VCI        ,
            tx2_uni_CLP        ,
            tx2_uni_PT         ,
            tx2_uni_HEC        ,
            tx2_uni_Payload    ,
            
            tx3_txreq          ,
            tx3_txack          ,
            tx3_uni_VPI        ,
            tx3_uni_VCI        ,
            tx3_uni_CLP        ,
            tx3_uni_PT         ,
            tx3_uni_HEC        ,
            tx3_uni_Payload    
           );

input                  clk                ;
input                  rst_n              ;
                               
output                 fwd_rden           ;
output [7:0]           fwd_addr           ;
input  [15:0]          fwd_data           ;
                               
input                  rx0_rxreq          ;
output                 rx0_rxack          ;
input  [11:0]          rx0_nni_VPI        ;
input  [15:0]          rx0_nni_VCI        ;
input                  rx0_nni_CLP        ;
input  [2:0]           rx0_nni_PT         ;
input  [7:0]           rx0_nni_HEC        ;
input  [8*48-1:0]      rx0_nni_Payload    ;

input                  rx1_rxreq          ;
output                 rx1_rxack          ;
input  [11:0]          rx1_nni_VPI        ;
input  [15:0]          rx1_nni_VCI        ;
input                  rx1_nni_CLP        ;
input  [2:0]           rx1_nni_PT         ;
input  [7:0]           rx1_nni_HEC        ;
input  [8*48-1:0]      rx1_nni_Payload    ;

input                  rx2_rxreq          ;
output                 rx2_rxack          ;
input  [11:0]          rx2_nni_VPI        ;
input  [15:0]          rx2_nni_VCI        ;
input                  rx2_nni_CLP        ;
input  [2:0]           rx2_nni_PT         ;
input  [7:0]           rx2_nni_HEC        ;
input  [8*48-1:0]      rx2_nni_Payload    ;

input                  rx3_rxreq          ;
output                 rx3_rxack          ;
input  [11:0]          rx3_nni_VPI        ;
input  [15:0]          rx3_nni_VCI        ;
input                  rx3_nni_CLP        ;
input  [2:0]           rx3_nni_PT         ;
input  [7:0]           rx3_nni_HEC        ;
input  [8*48-1:0]      rx3_nni_Payload    ;

output                 tx0_txreq          ;
input                  tx0_txack          ;
output [7:0]           tx0_uni_VPI        ;
output [15:0]          tx0_uni_VCI        ;
output                 tx0_uni_CLP        ;
output [2:0]           tx0_uni_PT         ;
output [7:0]           tx0_uni_HEC        ;
output [8*48-1:0]      tx0_uni_Payload    ;

output                 tx1_txreq          ;
input                  tx1_txack          ;
output [7:0]           tx1_uni_VPI        ;
output [15:0]          tx1_uni_VCI        ;
output                 tx1_uni_CLP        ;
output [2:0]           tx1_uni_PT         ;
output [7:0]           tx1_uni_HEC        ;
output [8*48-1:0]      tx1_uni_Payload    ;

output                 tx2_txreq          ;
input                  tx2_txack          ;
output [7:0]           tx2_uni_VPI        ;
output [15:0]          tx2_uni_VCI        ;
output                 tx2_uni_CLP        ;
output [2:0]           tx2_uni_PT         ;
output [7:0]           tx2_uni_HEC        ;
output [8*48-1:0]      tx2_uni_Payload    ;

output                 tx3_txreq          ;
input                  tx3_txack          ;
output [7:0]           tx3_uni_VPI        ;
output [15:0]          tx3_uni_VCI        ;
output                 tx3_uni_CLP        ;
output [2:0]           tx3_uni_PT         ;
output [7:0]           tx3_uni_HEC        ;
output [8*48-1:0]      tx3_uni_Payload    ;

////////////////////////////////////////////////////////////////////

parameter      wait_rx_valid = 3'h0  ,
               wait_fwdlkp   = 3'h1  ,
               tx_checksum   = 3'h2  ,
               wait_tx_ready = 3'h3  ,
               wait_tx_fwd   = 3'h4  ;
            
reg    [2:0]   SquatState     ;
wire           nni_hec_err    ;
wire           tx_fwd_done    ;
wire   [3:0]   rxreq_arb      ;
wire   [3:0]   forward        ;

  always @(posedge clk or negedge rst_n)
     if(~rst_n)  
       SquatState <= wait_rx_valid;
  else begin
    case (SquatState)
       wait_rx_valid  :   begin
                            if(|rxreq_arb) begin
                               SquatState <= wait_fwdlkp ;
                            end
                         end    
        wait_fwdlkp  :   begin
                            if (nni_hec_err)  
                               SquatState   <= wait_rx_valid;
                            else  
                               SquatState <= tx_checksum;
                         end
        tx_checksum   :  begin
                            SquatState <= wait_tx_ready;
                         end
        wait_tx_ready :  begin
                            if (|forward) // 核心丢弃处理
                               SquatState    <= wait_tx_fwd ;
                            else
                               SquatState    <= wait_rx_valid  ;
                         end    
        wait_tx_fwd   :  begin 
                            if(tx_fwd_done)
                               SquatState <= wait_rx_valid ;
                         end 
        default       :  SquatState <= wait_rx_valid ;
     endcase        
  end 

////////////////////////////////////////////////////////////////////////////////////

wire                  s_state_rxvld  = SquatState == wait_rx_valid  ;
wire                  s_state_fwdlkp = SquatState == wait_fwdlkp    ;
wire                  s_state_chksum = SquatState == tx_checksum    ;
wire                  s_state_txrdy  = SquatState == wait_tx_ready  ;
wire                  s_state_txfwd  = SquatState == wait_tx_fwd    ;

////////////////////////////////////////////////////////////////////////////////////
reg      [3:0]        rxreq_sel ;
always@(posedge clk or negedge rst_n)
      if(~rst_n)
         rxreq_sel <= 4'h1 ;
      else if(s_state_rxvld)
         rxreq_sel <= {rxreq_sel[2:0],rxreq_sel[3]} ;

assign                  rxreq_arb = rxreq_sel & {rx3_rxreq,rx2_rxreq,rx1_rxreq,rx0_rxreq} ;

////////////////////////////////////////////////////////////////////////////////////

wire       [3:0]        rxreq_sel_vld = rxreq_arb & {4{s_state_rxvld}} ;

////////////////////////////////////////////////////////////////////////////////////
// 中央暂存器暂存输入的 NNI 格式数据
reg        [11:0]      arb_nni_VPI     ;
reg        [15:0]      arb_nni_VCI     ;
reg                    arb_nni_CLP     ;
reg        [2:0]       arb_nni_PT      ;
reg        [7:0]       arb_nni_HEC     ;
reg        [8*48-1:0]  arb_nni_Payload ;


wire       [11:0]      nxt_arb_nni_VPI     = rxreq_sel_vld == 4'h1 ? rx0_nni_VPI     : rxreq_sel_vld == 4'h2 ? rx1_nni_VPI     : rxreq_sel_vld == 4'h4 ? rx2_nni_VPI     : rxreq_sel_vld == 4'h8 ? rx3_nni_VPI     :  arb_nni_VPI     ;
wire       [15:0]      nxt_arb_nni_VCI     = rxreq_sel_vld == 4'h1 ? rx0_nni_VCI     : rxreq_sel_vld == 4'h2 ? rx1_nni_VCI     : rxreq_sel_vld == 4'h4 ? rx2_nni_VCI     : rxreq_sel_vld == 4'h8 ? rx3_nni_VCI     :  arb_nni_VCI     ;
wire                   nxt_arb_nni_CLP     = rxreq_sel_vld == 4'h1 ? rx0_nni_CLP     : rxreq_sel_vld == 4'h2 ? rx1_nni_CLP     : rxreq_sel_vld == 4'h4 ? rx2_nni_CLP     : rxreq_sel_vld == 4'h8 ? rx3_nni_CLP     :  arb_nni_CLP     ;
wire       [2:0]       nxt_arb_nni_PT      = rxreq_sel_vld == 4'h1 ? rx0_nni_PT      : rxreq_sel_vld == 4'h2 ? rx1_nni_PT      : rxreq_sel_vld == 4'h4 ? rx2_nni_PT      : rxreq_sel_vld == 4'h8 ? rx3_nni_PT      :  arb_nni_PT      ;
wire       [7:0]       nxt_arb_nni_HEC     = rxreq_sel_vld == 4'h1 ? rx0_nni_HEC     : rxreq_sel_vld == 4'h2 ? rx1_nni_HEC     : rxreq_sel_vld == 4'h4 ? rx2_nni_HEC     : rxreq_sel_vld == 4'h8 ? rx3_nni_HEC     :  arb_nni_HEC     ;
wire       [8*48-1:0]  nxt_arb_nni_Payload = rxreq_sel_vld == 4'h1 ? rx0_nni_Payload : rxreq_sel_vld == 4'h2 ? rx1_nni_Payload : rxreq_sel_vld == 4'h4 ? rx2_nni_Payload : rxreq_sel_vld == 4'h8 ? rx3_nni_Payload :  arb_nni_Payload ; 


always@(posedge clk or negedge rst_n)
      if(~rst_n) begin
         arb_nni_VPI     <= 0 ;
         arb_nni_VCI     <= 0 ;
         arb_nni_CLP     <= 0 ;
         arb_nni_PT      <= 0 ;
         arb_nni_HEC     <= 0 ;
         arb_nni_Payload <= 0 ;
      end
      else begin
         arb_nni_VPI     <= nxt_arb_nni_VPI     ;
         arb_nni_VCI     <= nxt_arb_nni_VCI     ;
         arb_nni_CLP     <= nxt_arb_nni_CLP     ;
         arb_nni_PT      <= nxt_arb_nni_PT      ;
         arb_nni_HEC     <= nxt_arb_nni_HEC     ;
         arb_nni_Payload <= nxt_arb_nni_Payload ;
      end

////////////////////////////////////////////////////////////////////////////////////
assign   fwd_addr = nxt_arb_nni_VPI[7:0] ; // 截取低8位去查256深度的表
assign   fwd_rden = |rxreq_sel_vld  ;
reg      [15:0] fwd_data_reg ;
wire     [15:0] nxt_fwd_data = fwd_rden ? fwd_data : fwd_data_reg ;
always@(posedge clk or negedge rst_n)
      if(~rst_n)
         fwd_data_reg <= 16'h0 ;
      else 
         fwd_data_reg <= nxt_fwd_data ;

////////////////////////////////////////////////////////////////////////////////////
reg        [7:0]       hec_uni ;
// 映射为输出的符合 UNI 格式的 8 位 VPI
wire       [7:0]       arb_uni_VPI      = fwd_data_reg[7:0]   ;
wire       [15:0]      arb_uni_VCI      = arb_nni_VCI         ;
wire                   arb_uni_CLP      = arb_nni_CLP         ;
wire       [2:0]       arb_uni_PT       = arb_nni_PT          ;
wire       [7:0]       arb_uni_HEC      = hec_uni             ;
wire       [8*48-1:0]  arb_uni_Payload  = arb_nni_Payload     ;
assign                 forward          = fwd_data_reg[15:12] ;

//////////////////////////////////////////////////////////////////////////////////////////////////
// HEC校验输入端（NNI，32位无GFC），计算输出端（UNI，前4位硬件补0满32位）
//////////////////////////////////////////////////////////////////////////////////////////////////

wire       [31:0]      hec_nni_hdr     = {arb_nni_VPI, arb_nni_VCI, arb_nni_CLP, arb_nni_PT} ;
wire       [31:0]      hec_uni_hdr     = {4'b0000, arb_uni_VPI, arb_uni_VCI, arb_uni_CLP, arb_uni_PT} ;
wire       [31:0]      hec_cal_in      = s_state_fwdlkp ? hec_nni_hdr :
                                         s_state_chksum ? hec_uni_hdr : 32'h0 ;
                                         
wire       [7:0]       hec_cal_out     ;
hec_cal hec_cal_inst(
               .hec_in  ( hec_cal_in  ),
               .hec_out ( hec_cal_out )
               );
assign                 nni_hec_err = (arb_nni_HEC != hec_cal_out) & s_state_fwdlkp ;
always@(posedge clk or negedge rst_n)
      if(~rst_n)
         hec_uni <= 8'h0 ;
      else if(s_state_chksum)
         hec_uni <= hec_cal_out ;

////////////////////////////////////////////////////////////////////////////////////
// 输出给发送端（TX）接口
////////////////////////////////////////////////////////////////////////////////////

assign                 tx0_uni_VPI      = forward[0] ? arb_uni_VPI      : 'h0    ;
assign                 tx0_uni_VCI      = forward[0] ? arb_uni_VCI      : 'h0    ;
assign                 tx0_uni_CLP      = forward[0] ? arb_uni_CLP      : 'h0    ;
assign                 tx0_uni_PT       = forward[0] ? arb_uni_PT       : 'h0    ;
assign                 tx0_uni_HEC      = forward[0] ? arb_uni_HEC      : 'h0    ;
assign                 tx0_uni_Payload  = forward[0] ? arb_uni_Payload  : 'h0    ;


assign                 tx1_uni_VPI      = forward[1] ? arb_uni_VPI      : 'h0    ;
assign                 tx1_uni_VCI      = forward[1] ? arb_uni_VCI      : 'h0    ;
assign                 tx1_uni_CLP      = forward[1] ? arb_uni_CLP      : 'h0    ;
assign                 tx1_uni_PT       = forward[1] ? arb_uni_PT       : 'h0    ;
assign                 tx1_uni_HEC      = forward[1] ? arb_uni_HEC      : 'h0    ;
assign                 tx1_uni_Payload  = forward[1] ? arb_uni_Payload  : 'h0    ;

assign                 tx2_uni_VPI      = forward[2] ? arb_uni_VPI      : 'h0    ;
assign                 tx2_uni_VCI      = forward[2] ? arb_uni_VCI      : 'h0    ;
assign                 tx2_uni_CLP      = forward[2] ? arb_uni_CLP      : 'h0    ;
assign                 tx2_uni_PT       = forward[2] ? arb_uni_PT       : 'h0    ;
assign                 tx2_uni_HEC      = forward[2] ? arb_uni_HEC      : 'h0    ;
assign                 tx2_uni_Payload  = forward[2] ? arb_uni_Payload  : 'h0    ;

assign                 tx3_uni_VPI      = forward[3] ? arb_uni_VPI      : 'h0    ;
assign                 tx3_uni_VCI      = forward[3] ? arb_uni_VCI      : 'h0    ;
assign                 tx3_uni_CLP      = forward[3] ? arb_uni_CLP      : 'h0    ;
assign                 tx3_uni_PT       = forward[3] ? arb_uni_PT       : 'h0    ;
assign                 tx3_uni_HEC      = forward[3] ? arb_uni_HEC      : 'h0    ;
assign                 tx3_uni_Payload  = forward[3] ? arb_uni_Payload  : 'h0    ;

////////////////////////////////////////////////////////////////////////////////////
reg                    rx0_rxack ;
reg                    rx1_rxack ;
reg                    rx2_rxack ;
reg                    rx3_rxack ;
always@(posedge clk or negedge rst_n)
      if(~rst_n) 
         rx0_rxack <= 1'b0 ;
      else 
         rx0_rxack <= rxreq_sel_vld[0] ;
always@(posedge clk or negedge rst_n)
      if(~rst_n) 
         rx1_rxack <= 1'b0 ;
      else 
         rx1_rxack <= rxreq_sel_vld[1] ;
always@(posedge clk or negedge rst_n)
      if(~rst_n) 
         rx2_rxack <= 1'b0 ;
      else 
         rx2_rxack <= rxreq_sel_vld[2] ;
always@(posedge clk or negedge rst_n)
      if(~rst_n) 
         rx3_rxack <= 1'b0 ;
      else 
         rx3_rxack <= rxreq_sel_vld[3] ;

//////////////////////////////////////////////////////////////// ////////////////////
         
wire                    tx0_fwd_req = s_state_txrdy & forward[0] ;
wire                    tx1_fwd_req = s_state_txrdy & forward[1] ;
wire                    tx2_fwd_req = s_state_txrdy & forward[2] ;
wire                    tx3_fwd_req = s_state_txrdy & forward[3] ;
reg                    tx0_txreq ;
reg                    tx1_txreq ;
reg                    tx2_txreq ;
reg                    tx3_txreq ;
always@(posedge clk or negedge rst_n)
      if(~rst_n)
         tx0_txreq <= 1'b0 ;
      else if(tx0_txack)
         tx0_txreq <= 1'b0 ;
      else if(tx0_fwd_req)
         tx0_txreq <= 1'b1 ;
always@(posedge clk or negedge rst_n)
      if(~rst_n)
         tx1_txreq <= 1'b0 ;
      else if(tx1_txack)
         tx1_txreq <= 1'b0 ;
      else if(tx1_fwd_req)
         tx1_txreq <= 1'b1 ;
always@(posedge clk or negedge rst_n)
      if(~rst_n)
         tx2_txreq <= 1'b0 ;
      else if(tx2_txack)
         tx2_txreq <= 1'b0 ;
      else if(tx2_fwd_req)
         tx2_txreq <= 1'b1 ;
always@(posedge clk or negedge rst_n)
      if(~rst_n)
         tx3_txreq <= 1'b0 ;
      else if(tx3_txack)
         tx3_txreq <= 1'b0 ;
      else if(tx3_fwd_req)
         tx3_txreq <= 1'b1 ;

////////////////////////////////////////////////////////
wire      tx0_trig = ((forward[0] & tx0_txack) | (forward[0] == 1'b0)) & s_state_txfwd;
wire      tx1_trig = ((forward[1] & tx1_txack) | (forward[1] == 1'b0)) & s_state_txfwd;
wire      tx2_trig = ((forward[2] & tx2_txack) | (forward[2] == 1'b0)) & s_state_txfwd;
wire      tx3_trig = ((forward[3] & tx3_txack) | (forward[3] == 1'b0)) & s_state_txfwd;

reg      tx0_done ;
reg      tx1_done ;
reg      tx2_done ;
reg      tx3_done ;

always@(posedge clk or negedge rst_n)
      if(~rst_n)
         tx0_done <= 1'b0 ;
      else if(s_state_txfwd == 1'b0)
         tx0_done <= 1'b0 ;
      else if(tx0_trig)
         tx0_done <= 1'b1 ;

always@(posedge clk or negedge rst_n)
      if(~rst_n)
         tx1_done <= 1'b0 ;
      else if(s_state_txfwd == 1'b0)
         tx1_done <= 1'b0 ;
      else if(tx1_trig)
         tx1_done <= 1'b1 ;

always@(posedge clk or negedge rst_n)
      if(~rst_n)
         tx2_done <= 1'b0 ;
      else if(s_state_txfwd == 1'b0)
         tx2_done <= 1'b0 ;
      else if(tx2_trig)
         tx2_done <= 1'b1 ;
         
always@(posedge clk or negedge rst_n)
      if(~rst_n)
         tx3_done <= 1'b0 ;
      else if(s_state_txfwd == 1'b0)
         tx3_done <= 1'b0 ;
      else if(tx3_trig)
         tx3_done <= 1'b1 ;
         
////////////////////////////////////////////////

assign   tx_fwd_done = tx0_done & tx1_done & tx2_done & tx3_done;

////////////////////////////////////////////////
         
endmodule
