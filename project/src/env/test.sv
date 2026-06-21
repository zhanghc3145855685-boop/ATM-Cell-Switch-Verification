`include "../src/tb/definitions.sv"
`include "../src/tb/atm_cell.sv"

program automatic test
  #(parameter int NumRx = 4, parameter int NumTx = 4)
   (Utopia.TB_Rx Rx[0:NumRx-1],
    Utopia.TB_Tx Tx[0:NumTx-1],
    cpu_ifc.Test mif,
    input logic clk, rst_n);

typedef class Driver;
typedef class Monitor;

virtual class Driver_cbs;
   virtual task post_tx(input Driver drv, input NNI_cell ncell);
   endtask
endclass

virtual class Monitor_cbs;
   virtual task post_rx(input Monitor mon, input UNI_cell ucell);
   endtask
endclass


   `include "../src/env/environment.sv"

   CPU_driver cpu;
   Environment env;

   initial begin
	$fsdbDumpfile("novas.fsdb");
	$fsdbDumpvars(0, top);
      $display("###################################################################");
      $display("##################  Program Start !!!!!! ##########################");
      $display("###################################################################");
    
      // 1. 实例化顶层大盒环境，将物理引脚接口传入
      env = new(Rx, Tx, NumRx, NumTx, mif);

      // 2. 全自动随机化仿真用例配置约束
      env.gen_cfg();

      // 3. 多通道组件级联实例化与多端口 Callback 绑定
      env.build();

      // 4. 将底层的 cpu 句柄拉高赋予全局指针，支持回调函数安全静态索引
      cpu = env.cpu;

      // 5. 驱动硬件复位时序
      env.reset();

      // 6. 全速并行拉起全通路验证，等待多端口覆盖率打满自然结束
      env.run();

      // 7. 仿真退出前，自动核销并打印多端口计分板总结报告
      env.wrap_up();

      $display("###################################################################");
      $display("##################  Program End  !!!!!!! ##########################");
      $display("###################################################################");
   end

endprogram
