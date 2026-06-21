`ifndef SCOREBOARD__SV
`define SCOREBOARD__SV

class Expect_cells;
   UNI_cell q[$];
   int iexpect, iactual;
endclass : Expect_cells

class Scoreboard;

   Expect_cells expect_cells[];
   int iexpect, iactual;

   extern function new(Config cfg = null);
   extern virtual function void wrap_up();
   extern function void save_expected(NNI_cell ncell); 
   extern function void check_actual(input UNI_cell ucell, input int portn); 
   extern function void display(string prefix="");
   
endclass : Scoreboard


//---------------------------------------------------------------------------
function Scoreboard::new(Config cfg = null);
   expect_cells = new[NumTx];
   foreach (expect_cells[i])
      expect_cells[i] = new();
endfunction // Scoreboard

function void Scoreboard::save_expected(NNI_cell ncell);
   bit [7:0] idx = ncell.VPI[7:0];            
   CellCfgType CellFwd = test.cpu.lookup[idx]; 
   UNI_cell n2ucell;                          

   if (CellFwd.FWD == 4'b0000) begin
      $display("@%0t: [SCOREBOARD] [DROP INTERCEPT] NNI_IN_VPI=0x%03x is configured as a DROP cell (FWD==0). System successfully filter it.", $time, ncell.VPI);
      return; 
   end

   $display("@%0t: [Scoreboard Save] NNI_IN_VPI=0x%03x --> Target_UNI_VPI=0x%02x, FWD_Vector=4'b%4b", 
            $time, ncell.VPI, CellFwd.VPI, CellFwd.FWD);

   // 遍历 4 个物理通道，根据路由向量 FWD 的 bit 映射
   for (int i=0; i<NumTx; i++) begin
      if (CellFwd.FWD[i]) begin
         // 防止多通道共享同一个句柄造成的并发冲突
         n2ucell = new();
         n2ucell = ncell.to_UNI(CellFwd.VPI); 
         
         expect_cells[i].q.push_back(n2ucell); // 存入该物理出口独立的期待池
         expect_cells[i].iexpect++;
         iexpect++;
      end
   end
   
endfunction : save_expected

function void Scoreboard::check_actual(input UNI_cell ucell, input int portn);
   int match_idx = -1;
         
   if (expect_cells[portn].q.size() == 0) begin
      $display("@%0t: ERROR: %m cell not found because scoreboard for TX%0d empty", $time, portn);
      ucell.display("Not Found: ");
      $finish; 
      return;
   end
   
   expect_cells[portn].iactual++;
   iactual++;

   foreach (expect_cells[portn].q[i]) begin
      if (expect_cells[portn].q[i].VPI     == ucell.VPI &&
          expect_cells[portn].q[i].VCI     == ucell.VCI &&
          expect_cells[portn].q[i].CLP     == ucell.CLP &&
          expect_cells[portn].q[i].PT      == ucell.PT  &&
          expect_cells[portn].q[i].HEC     == ucell.HEC &&
          expect_cells[portn].q[i].Payload == ucell.Payload) begin
         match_idx = i;
         break; // 抓到了就立刻跳出循环，保护普通索引
      end
   end

   if (match_idx != -1) begin
       $display("@%0t: [SUCCESS] Packet Checked on TX[%0d] Successfully Compared !!!!", $time, portn);
       expect_cells[portn].q.delete(match_idx); // 安全地从池子里销毁
       return;
   end

   // 如果遍历完整个队列都没有匹配上，说明是错包
   $display("@%0t: [FAIL] Packet Compare Fail on TX[%0d] !!!", $time, portn);
   ucell.display("Not Found: ");
   $finish; 
               
endfunction : check_actual


//---------------------------------------------------------------------------
function void Scoreboard::wrap_up();
   $display("@%0t: %m %0d expected cells, %0d actual cells received", $time, iexpect, iactual);

   foreach (expect_cells[i]) begin
      if (expect_cells[i].q.size()) begin
         $display("@%0t: %m cells remaining in Tx[%0d] scoreboard at end of test", $time, i);
         this.display("Unclaimed: ");
         $finish;
      end
   end
   $display("###################################################################");
   $display("##### SUCCESS: Lab8 Environment OOP Multi-Port Verification Pass! #");
   $display("###################################################################");
endfunction : wrap_up


//---------------------------------------------------------------------------
function void Scoreboard::display(string prefix);
   $display("@%0t: %m so far %0d expected cells, %0d actual cells received", $time, iexpect, iactual);
   foreach (expect_cells[i]) begin
      $display("Tx[%0d]: exp=%0d, act=%0d", i, expect_cells[i].iexpect, expect_cells[i].iactual);
      foreach (expect_cells[i].q[j])
         expect_cells[i].q[j].display($psprintf("%sScoreboard: Tx%0d: ", prefix, i));
   end
endfunction : display

`endif
