`ifndef MONITOR__SV
`define MONITOR__SV

typedef class Monitor;

class Monitor;

   vUtopiaTx Tx;
   int PortID;
   
   Monitor_cbs cbsq[$]; 

   extern function new(input vUtopiaTx Tx, input int PortID);
   extern task run();
   extern task receive (output UNI_cell uni_cell); 
endclass : Monitor


function Monitor::new(input vUtopiaTx Tx, input int PortID);
   this.Tx     = Tx;
   this.PortID = PortID;
endfunction : new


task Monitor::run();
   UNI_cell uni_cell;
   forever begin
      receive(uni_cell);
      foreach (cbsq[i]) begin
         cbsq[i].post_rx(this, uni_cell);
      end
   end
endtask : run


task Monitor::receive(output UNI_cell uni_cell);
   ATMCellType pkt_cmp;
   int j = 0 ;
   Tx.cbt.clav <= 1;
   
   wait(Tx.cbt.en);
   wait(Tx.cbt.soc);
   while (j<=52) begin
      if (Tx.cbt.en == 1'b1)begin
         pkt_cmp.Mem[j] = Tx.cbt.data ;
         @(Tx.cbt);
         j = j + 1 ;
      end
      else begin 
         @(Tx.cbt);
      end
   end
   j = 0 ;
   
   uni_cell = new();
   uni_cell.GFC     = pkt_cmp.uni.GFC;
   uni_cell.VPI     = pkt_cmp.uni.VPI;
   uni_cell.VCI     = pkt_cmp.uni.VCI;
   uni_cell.CLP     = pkt_cmp.uni.CLP;
   uni_cell.PT      = pkt_cmp.uni.PT;
   uni_cell.HEC     = pkt_cmp.uni.HEC;
   uni_cell.Payload = pkt_cmp.uni.Payload;
endtask : receive

`endif // MONITOR__SV
