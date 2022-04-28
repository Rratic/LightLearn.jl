# 使用方式
导入后使用`about()`，你就会看到

## 流程
```jl
init()		初始化资源
level(name)	打开关卡name
此时可以进行一些测试
submit() do
	你的代码
end
来提交（建议在编辑器上编辑好再复制黏贴）
quit()		退出并保存存档
```

## 辅助工具
```jl
menu()		列出当前所有关卡和描述
help()		获取当前关卡提示（若有）
vis(false)	关闭窗口
vis(true)	打开窗口
interval	提交时的动画间隔
```
