# Verilog Lab

提供对于基础 verilog 模块的波形测试的 vscode 工作区。

## 环境要求

- iverilog 编译器
- GTKWave 波形查看器

## 使用方法

1. 在modules文件夹中添加模块同名文件夹。
2. 在模块文件夹中添加verilog文件和testbench文件，testbench文件命名格式为`<module_name>_tb.v`。
3. `Ctrl+Shift+B`选择运行task即可。 