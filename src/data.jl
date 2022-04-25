struct Level
	description::String
	help::String
	startx::Int
	starty::Int
	gen::Function
	chk::Function
	limit::Int
end
const levels=[
	Level(
		"简介","调用about()查看基本操作",
		3,3,()->begin
		fill!(grids,nothing)
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
	Level(
		"条件的使用","当你处在(x,y)或它的4个相邻格时，可以用look(x,y)获取(x,y)处值",
		7,7,()->begin
		fill!(grids,nothing)
		grids[7,7]=Info("""
		没错，这里有2个旗帜。
		去哪一个呢？
		看到那个骰子了吗？你走过去，就会产生一个整数（通过look(7,8)获取）
		若掷到1、3、5，就去右边的旗帜
		否则，就去下面的旗帜
		""")
		grids[7,8]=Dice()
		grids[7,10]=Flag()
		grids[10,8]=Flag()
	end,()->begin
		v=grids[7,8]
		if !isa(v,Int)
			println("先掷骰子！")
			return false
		else
			return v&2==1 ? (plyx==10&&plyy==8) : (plyx==7&&plyy==10)
		end
	end,40),
	Level(
		"循环的使用","",
		1,1,()->begin
		fill!(grids,nothing)
		for i in 2:15
			for j in 2:2:14
				grids[i,j]=Solid()
			end
		end
		grids[1,2]=grids[1,6]=grids[1,10]=grids[1,14]=grids[16,4]=grids[16,8]=grids[16,12]=Solid()
		grids[1,1]=Info("""
		你可以看到，这里的有许多深色方格，它们是墙
		这里的地形似乎有些类似？
		为了省力，你可以用什么呢？
		""")
		grids[1,16]=Flag()
	end,()->begin
		return plyx==1&&plyy==16
	end,100),
	Level(
		"异常处理","当你处在(x,y)或它的4个相邻格时，可以用guess(x,y,v)提交你的猜测",
		1,1,()->begin
		fill!(grids,nothing)
		grids[1,1]=Info("""
		你的面前有一个密码锁
		它的密码是1~10之间的一个整数
		你可以使用guess(1,2,猜测的数n)进行猜测
		如果你猜对了，请在锁位置向下走n步
		如果猜错了，锁会抛出异常，你必须进行处理
		""")
		v=rand(1:10)
		grids[1,2]=GuessLock(
			v,
			(i::GuessLock,v)->begin
				if v==i.value
					grids[1,2]=nothing
					grids[1,2+v]=Flag()
					return nothing
				else
					throw(false)
				end
			end
		)
	end,()->begin
		return isa(grids[plyx,plyy],Flag)
	end,100),
]

#= [template]
Level(
		"",
		1,1,()->begin
	end,()->begin
	end,100),
=#
