# water_cpu
## 介绍
该项目是whu计算机科学与技术大二第三学期计算机系统综合设计A项目代码, 项目完成了一个基于verilog语言的RISC-V多周期流水线的玩具CPU, 并部分支持中断。
## 项目树介绍
```
.
├── README.md
├── Makefile                           // 自动化构建工具
├── asm&bin                            // 反汇编平台 & 仿真机器码存放
├── coe2bin                            // 汇编转coe工具
├── dm.v                               // 仿真用data memory
├── im.v                               // 仿真用instr memory
├── sccomp.v                           // 仿真用顶层文件
├── sccomp_tb.v                        // 仿真文件
├── src                                // SCPU源代码
├── 框架文件                            // 为实现按钮中断, 对SCPU连线略有修改

```
## 仿真方式
在项目根文件夹下, 执行make wave即可完成编译并弹出gtkwave可视化仿真界面。
- 修改仿真源程序
修改`sccomp_tb.v`中的`$readmemh`中所用文件即可修改仿真源程序。
## 项目依赖
- 使用`iverlog`完成verilog综合
- 使用`vvp`完成仿真
- 使用`gtkwave`实现仿真文件可视化

