`ifndef CPU_DRIVER__SV
`define CPU_DRIVER__SV

//`include "atm_cell.sv"
//`include "cpu_ifc.sv"

class CPU_driver;
   vCPU_T mif;
   CellCfgType lookup [255:0]; // copy of look-up table
   bit [NumTx-1:0] fwd;

   extern function new(vCPU_T mif);
   extern task Initialize_Host ();
   extern task HostWrite (int a, CellCfgType d); // configure
   extern task HostRead (int a, output CellCfgType d);
   extern task run();
   
endclass : CPU_driver


function CPU_driver::new(vCPU_T mif);
   this.mif = mif;
endfunction : new


task CPU_driver::Initialize_Host ();
   mif.BusMode  <= 1;
   mif.Addr     <= 0;
   mif.DataIn   <= 0;
   mif.Sel      <= 1;
   mif.Rd_DS    <= 1;
   mif.Wr_RW    <= 1;
endtask : Initialize_Host


task CPU_driver::HostWrite (int a, CellCfgType d); // configure
   #10 mif.Addr     <= a; 
       mif.DataIn   <= d; 
       mif.Sel      <= 0;
   #10 mif.Wr_RW    <= 0;
   while (mif.Rdy_Dtack!==0) #10;
   #10 mif.Wr_RW    <= 1; 
       mif.Sel      <= 1;
   while (mif.Rdy_Dtack==0) #10;
endtask : HostWrite


task CPU_driver::HostRead (int a, output CellCfgType d);
   #10 mif.Addr     <= a; 
       mif.Sel      <= 0;
   #10 mif.Rd_DS    <= 0;
   while (mif.Rdy_Dtack!==0) #10;
   #10 d = mif.DataOut; 
       mif.Rd_DS <= 1 ; 
       mif.Sel   <= 1;
   while (mif.Rdy_Dtack==0) #10;
endtask : HostRead


task CPU_driver::run();

   CellCfgType CellFwd;
   Initialize_Host();

   // Configure through Host interface
   repeat (10) @(negedge clk);
   $write("Memory: Loading Lookup Table with Random Routes and Drops ... \n");
   
   for (int i=0; i<=255; i++) begin
       CellFwd.FWD = $urandom_range(0, 15); 
       CellFwd.VPI = i;
       
       $display("[CPU_DRIVER] Writing LUT Address %0d: FWD=%b (Dec:%0d)", i, CellFwd.FWD, CellFwd.FWD);
       
       HostWrite(i, CellFwd);
       lookup[i] = CellFwd; // 同步保存进软件镜像副本，供记分板拦截丢弃包使用
   end

   $display("Memory Loading Completed.");

   // Verify memory
   $write("Verifying Lookup Table Register Integrity ...");
   for (int i=0; i<=255; i++) begin
      HostRead(i, CellFwd);
      if (lookup[i] != CellFwd) begin
         $display("FATAL, Mem Location 0x%x contains 0x%x, expected 0x%x",
                  i, CellFwd, lookup[i]);
         $finish;
      end
   end
   $display(" Verified Successfully.");

endtask : run

`endif // CPU_DRIVER__SV
