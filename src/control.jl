function _draw()
    ctx=getgc(canvas)
	for i in 1:16
		for j in 1:16
			show_grid(ctx,grids[i,j],(i-1)<<5,(j-1)<<5)
		end
	end
	fill_image(ctx,"ply",plyx<<5-30,plyy<<5-30)
end
function about()
	print("""
	使用init()初始化资源
	使用level(num)打开关卡num
	在那之后你可以进行一些尝试，然后使用
	submit() do
		你的代码
	end
	来提交
	建议在编辑器上编辑好再复制黏贴
	你可以使用help()获取当前关卡提示（若有）
	""")
end
function initlevel(lv::Level)
	global plyx=lv.startx
	global plyy=lv.starty
	lv.gen()
	plyenter(grids[lv.startx,lv.starty])
	_draw()
end
function level(num::Int)
	global levelid=num
	lv=levels[num]
	initlevel(lv)
end
function help()
	println(levels[levelid].help)
end
struct LiError
	name::Symbol
end
mvw()=move(0,-1)
mva()=move(-1,0)
mvs()=move(0,1)
mvd()=move(1,0)
function move(x::Int,y::Int)
	tx=plyx+x
	ty=plyy+y
	if tx<1||tx>16||ty<1||ty>16||solid(@inbounds(grids[tx,ty]))
		return
	end
	global plyx=tx
	global plyy=ty
	plyenter(grids[tx,ty])
	_draw()
	sleep(formal ? interval : interval/2)
end
function submit(f::Function)
	count=0
	lv=levels[levelid]
	initlevel(lv)
	global formal=true
	try
		f()
		if !lv.chk()
			println("未达成目标")
		end
		if count>lv.limit
			throw(LiError(:tle))
		end
		println("通过")
	catch er
		if isa(er,LiError)
			print("Error: ")
			sy=er.name
			println(
				sy==:cheat ? "禁止作弊" :
				sy==:tle ? "超过规定步数限制（$(lv.limit)）" :
				sy==:invisible_far ? "太远了，无法调用look()" :
				"[未知]"
			)
		else
			throw(er)
		end
	finally
		formal=false
	end
end

function chknear(x::Int,y::Int)
	if abs(x-plyx)+abs(y-plyy)>1
		throw(LiError(:invisible_far))
	end
end
function look(x::Int,y::Int)
	chknear(x,y)
	v=grids[x,y]
	return _look(v)
end
function guess(x::Int,y::Int,v)
	chknear(x,y)
	return _guess(grids[x,y],v)
end
