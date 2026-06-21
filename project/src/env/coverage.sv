`ifndef COVERAGE__SV
`define COVERAGE__SV

class Coverage;

   bit [1:0] src;
   bit [NumTx-1:0] fwd;
   event cov_done;
   real coverage_result = 0.0;

   // 建立功能覆盖率交叉收集仓库
   covergroup CG_Forward;
      coverpoint src
         { bins src[] = {[0:3]}; option.weight = 0; }
      coverpoint fwd
         { bins fwd[] = {[0:15]}; option.weight = 0; } //将 0 (Drop 丢弃) 作为一个独立的合法状态进行观测
      cross src, fwd; // 交叉覆盖 4路输入端 x 15种有效路由走向 组合
   endgroup : CG_Forward

   function new;
      CG_Forward = new;
   endfunction : new

   // 采样接口函数
   function void sample(input bit [1:0] src, input bit [NumTx-1:0] fwd);
      $display("@%0t: Coverage: src=%d. FWD=%b", $time, src, fwd);
      this.src = src;
      this.fwd = fwd;
      CG_Forward.sample(); // 强制打卡采样
      coverage_result = $get_coverage();
      $display("###################################################################################");
      $display("@%0t: Coverage: src=%d. FWD=%b. Total_Coverage_Result = %3.2f %%", $time, src, fwd, coverage_result);
      $display("###################################################################################");

      // 当总功能覆盖率指标达到课设要求的 80% 以上时，触发 cov_done 事件
      if(coverage_result >= 80.0) begin
         -> this.cov_done ;
         $display("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! FUNCTIONAL COVERAGE DONE !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
      end
   endfunction : sample

endclass : Coverage

`endif // COVERAGE__SV
