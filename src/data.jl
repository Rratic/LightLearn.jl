struct Level
	description::String
	help::String
	startx::Int
	starty::Int
	gen::Function
	chk::Function
	limit::Int
end
global private=Dict{Symbol,Any}()
const chapters=[
	"语法基础"=>["1","2","3","4","5","6"],
]
const levels=Dict{String,Level}(
	"1"=>Level(
		"简介","调用about()查看基本操作",
		7,7,()->begin
		fill!(grids::Matrix,nothing)
		grids[7,7]=Info(md"""
# 信息
你可以在 do ... end 间使用函数
```jl
mvw() 向上移动
mva() 向左移动
mvs() 向下移动
mvd() 向右移动
```
# 目标
移动到旗帜处
# 示例
```jl
submit() do
	mvs()
	mvs()
	mvs()
	mvd()
	mvd()
	mvd()
end
```
		""")
		grids[10,10]=Flag()
	end,()->begin
		return plyx==10&&plyy==10
	end,40),
	"2"=>Level(
		"条件的使用","当你处在(x,y)或它的4个相邻格时，可以用look(x,y)获取(x,y)处值",
		7,7,()->begin
		fill!(grids::Matrix,nothing)
		grids[7,7]=Info(md"""
# 信息
没错，这里有2个旗帜。\
去哪一个呢？
# 目标
看到那个骰子了吗？你走过去，在它的原位置就会产生一个整数（通过`look(7,8)`获取）\
若掷到1、3、5，就去右边的旗帜\
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
	"3"=>Level(
		"循环的使用","",
		1,1,()->begin
		fill!(grids::Matrix,nothing)
		@inbounds for i in 2:15
			for j in 2:2:14
				grids[i,j]=Solid()
			end
		end
		grids[1,2]=grids[1,6]=grids[1,10]=grids[1,14]=grids[16,4]=grids[16,8]=grids[16,12]=Solid()
		grids[1,1]=Info(md"""
# 信息
你可以看到，这里的有许多深色方格，它们是墙\
这里的地形似乎有些类似？\
为了省力，你可以用什么呢？
# 目标
移动到旗帜处
		""")
		grids[1,16]=Flag()
	end,()->begin
		return plyx==1&&plyy==16
	end,200),
	"4"=>Level(
		"异常处理","当你处在(x,y)或它的4个相邻格时，可以用guess(x,y,v)提交你的猜测",
		1,1,()->begin
		fill!(grids::Matrix,nothing)
		grids[1,1]=Info(md"""
# 信息
你的面前有一个密码锁\
它的密码是1~10之间的一个整数\
你可以使用`guess(1,2,猜测的数n)`进行猜测
# 目标
如果你猜对了，请在锁位置向下走n步
如果猜错了，锁会抛出异常，你必须进行处理
!!! warning
	除特殊注明外，禁止使用异常处理

!!! note
	你不能移动到锁上
		""")
		val=rand(1:10)
		grids[1,2]=Lock(
			(i::Lock,v)->begin
				if v==val
					grids[1,2]=nothing
					grids[1,2+v]=Flag()
					_draw()
					return nothing
				else
					throw(false)
				end
			end
		)
	end,()->begin
		return isa(grids[plyx,plyy],Flag)
	end,40),
	"5"=>Level(
		"函数定义","",
		2,2,()->begin
		fill!(grids::Matrix,nothing)
		grids[2,2]=Info(md"""
# 信息
你是否厌倦了不断地调用`mvs()`或写半天的循环代码？\
你可以把一些功能包装在函数中
# 目标
解锁，锁的密码是各骰子掷得的值之和
# 示例
```jl
function mvs(n::Int) # 向下移动n步
	for i in 1:n
		mvs()
	end
end
```
		""")
		grids[7,2]=grids[5,6]=grids[6,9]=Dice()
		grids[15,15]=Lock(
			(i::Lock,v)->begin
				if isa(grids[7,2],Int)&&isa(grids[5,6],Int)&&isa(grids[6,9],Int)&&v==grids[7,2]+grids[5,6]+grids[6,9]
					grids[15,15]=nothing
					_draw()
					return nothing
				else
					throw("提交失败，你只有一次机会")
				end
			end
		)
	end,()->begin
		return grids[15,15]===nothing
	end,100),
	"6"=>Level(
		"数组使用","",
		2,2,()->begin
		fill!(grids::Matrix,nothing)
		grids[2,2]=Info(md"""
# 信息
这里有一些箱子，它们支持与一维数组（`Vector`）相同的操作
# 目标
对于以下三组箱子，分别完成
1. 取出左箱末尾数据，并塞入右箱末尾
2. 读出左箱开头数据，并替换右箱开头为该数据
3. 读取左出数据，将数据的和、最大值、最小值依次从末尾推入右箱
# 示例
```jl
function task1()
	v=pop!(look(4,2))
	mvd(6)
	push!(look(10,2),v)
end
```

!!! note
	你不能移动到箱子上\
	请严格按照要求执行
		""")
		function R8(r::Int,g::Int,b::Int)
			return RGB{N0f8}(reinterpret(N0f8,UInt8(r)),reinterpret(N0f8,UInt8(g)),reinterpret(N0f8,UInt8(b)))
		end
		v1=Vector(undef,2)
		v1[2]=private[:v1]=rand(0:255)
		grids[4,2]=Box(v1,R8(157,213,234),R8(0,162,232))
		grids[10,2]=Box(Vector(undef,1),R8(0,162,232),R8(157,213,234))
		v2=Vector(undef,2)
		v2[1]=private[:v2]=rand(0:255)
		grids[4,4]=Box(v2,R8(181,230,29),R8(34,177,76))
		grids[10,4]=Box([1],R8(34,177,76),R8(181,230,29))
		v3=rand(-127:128,rand(5:7))
		private[:len]=length(v3)
		private[:sum]=sum(v3)
		private[:max]=maximum(v3)
		private[:min]=minimum(v3)
		grids[4,6]=Box(v3,R8(185,122,87),R8(136,0,21))
		grids[10,6]=Box([],R8(136,0,21),R8(185,122,87))
	end,()->begin
		if length(grids[4,2].data)!=1 display(md"你应该**取出**第一组左箱末尾数据")
		elseif grids[10,2].data[2]!=private[:v1] println("第一组不符合要求")
		elseif length(grids[4,4].data)!=2 display(md"你应该**读出**第二组左箱开头数据")
		elseif grids[10,4].data!=[private[:v2]] println("第二组数据不符合要求")
		elseif length(grids[4,6].data)!=private[:len] display(md"你应该**读出**第三组左箱数据")
		elseif grids[10,6].data!=[private[:sum],private[:max],private[:min]] println("第三组数据不符合要求")
		else return true end
		return false
	end,200)
)
