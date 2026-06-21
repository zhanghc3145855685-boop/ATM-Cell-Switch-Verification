`ifndef DRIVER__SV
`define DRIVER__SV

class Driver;

   mailbox gen2drv; // 保持通用信箱特性
   event   drv2gen;
   vUtopiaRx Rx;
   int PortID;
   
   Driver_cbs cbsq[$]; 

   extern function new(input mailbox gen2drv, 
                       input event drv2gen, 
                       input vUtopiaRx Rx, 
                       input int PortID);
   extern task run();
   extern task send (input NNI_cell ncell); 

endclass : Driver


function Driver::new(input mailbox gen2drv,
                     input event drv2gen,
                     input vUtopiaRx Rx,
                     input int PortID);
   this.gen2drv = gen2drv;
   this.drv2gen = drv2gen;
   this.Rx      = Rx;
   this.PortID  = PortID;
endfunction : new 


task Driver::run();
   UNI_cell ucell; 
   NNI_cell ncell; 

   Rx.cbr.data  <= 0;
   Rx.cbr.soc   <= 0;
   Rx.cbr.clav  <= 0;
   
   forever begin
      // 从信箱读取前端 Generator 塞进来的 UNI cell
      gen2drv.peek(ucell);
      
      begin: Tx
         ncell = new();
         
         // 利用原版 atm_cell.sv 中已有的 UNI_cell::to_NNI 转换函数，反向升格包装为 NNI_cell
         ncell = ucell.to_NNI($urandom); 
         
         // 将包装好的标准 12位 VPI NNI报文灌入芯片的 RX 接口
         send(ncell);
         
         foreach (cbsq[i]) begin
            cbsq[i].post_tx(this, ncell);
         end
      end: Tx

      gen2drv.get(ucell);      
      ->drv2gen;
   end
endtask : run


task Driver::send(input NNI_cell ncell);
   ATMCellType pkt_gen ;   
   
   pkt_gen.nni.VPI     = ncell.VPI;
   pkt_gen.nni.VCI     = ncell.VCI;
   pkt_gen.nni.CLP     = ncell.CLP;
   pkt_gen.nni.PT      = ncell.PT;
   pkt_gen.nni.HEC     = ncell.HEC;
   pkt_gen.nni.Payload = ncell.Payload;

   $write("Sending cell: ");
   foreach (pkt_gen.Mem[i]) 
       $write("%x ", pkt_gen.Mem[i]); $display;

   @(Rx.cbr);
   Rx.cbr.clav <= 1;
   for (int i=0; i<=52; i++) begin
        while (Rx.cbr.en === 1'b0) 
           @(Rx.cbr);
        Rx.cbr.soc  <= (i == 0);
        Rx.cbr.data <= pkt_gen.Mem[i];
        @(Rx.cbr);
   end
   
   repeat (1) @(negedge clk)  ;
   Rx.cbr.soc  <= 0    ;
   Rx.cbr.data <= 8'b0 ;
   Rx.cbr.clav <= 1    ;
endtask

`endif // DRIVER__SV
