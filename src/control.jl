function _draw(st)
    # ctx=getgc(canvas)
	ctx=st.context
	for i in 1:16
		for j in 1:16
			_show(st,
				@inbounds(grids[i, j]),
				(i-1)<<5,
				(j-1)<<5
			)
		end
	end
	fill_image(st, "ply", st.x<<5-30, st.y<<5-30)
	set_source_rgb(ctx,0.625,0.625,0.625)
	for k in 1:16
		rectangle(ctx,k<<5-1,0,1,512)
		rectangle(ctx,0,k<<5-1,512,1)
	end
	fill(ctx)
end

"列出当前导入数据中的章节和关卡描述"
function menu()
	for pa::Pair in chapters
		println("[ $(pa.first) ]")
		for name in pa.second
			println("$name\t$(levels[name].description)")
		end
	end
end
function initlevel(lv::Level)
	global plyx=lv.startx
	global plyy=lv.starty
	lv.gen()
	draw(canvas)
end
level(num::Int)=level(string(num))
"导入关卡名为name的关卡，数字会自动转化为字符串"
function level(name::String)
	if formal
		throw("不能在提交时调用level")
	end
	global levelid=name
	lv=levels[name]
	set_gtk_property!(window,:title,"LightLearn: $(lv.description)")
	initlevel(lv)
	plyenter(grids[lv.startx,lv.starty])
end
"重启当前关卡"
function rewind()
	if formal
		throw("不能在提交时调用rewind")
	end
	lv=levels[levelid]
	initlevel(lv)
	plyenter(grids[lv.startx,lv.starty])
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
	draw(canvas)
	if formal
		sleep(interval)
	end
end
"提交当前关卡的尝试f"
function submit(f::Function)
	if formal
		throw("不能在提交时调用submit")
	end
	lv=levels[levelid]
	initlevel(lv)
	global formal=true
	try
		plyenter(grids[lv.startx,lv.starty])
		f()
		if !lv.chk()
			printstyled("未达成目标";color=:yellow)
			return
		end
		printstyled("通过";color=:green)
	catch er
		if isa(er,String)
			printstyled(er;color=:red)
		else
			throw(er)
		end
	finally
		formal=false
	end
	nothing
end

function chknear(x::Int,y::Int)
	if abs(x-plyx)+abs(y-plyy)>1
		throw("太远了")
	end
end
"查看(x,y)处的东西，必须在相邻4格或当前格"
function look(x::Int,y::Int)
	chknear(x,y)
	if x<1||y<1||x>16||y>16
		throw("越界")
	end
	v=@inbounds grids[x,y]
	return _look(v)
end
function send(method::Symbol,x::Int,y::Int,args...)
	chknear(x,y)
	return _send(grids[x,y],Val(method),args...)
end
function setinterval(to::Float64)
	global interval=to
end
