struct Level
	help::String
	startx::Int
	starty::Int
	gen::Function
	chk::Function
	limit::Int
end
const levels=[
	Level(
		"调用about()查看基本操作",
		3,3,()->begin
		for i in 1:16
			for j in 1:16
				grids[i,j]=nothing
			end
		end
		grids[3,3]=Info("""
		你可以在 do ... end 间使用函数
		mvw() 向上移动
		mva() 向左移动
		mvs() 向下移动
		mvd() 向右移动
		""")
		grids[14,14]=Flag()
	end,()->begin
		return plyx==14&&plyy==14
	end,40),
]
