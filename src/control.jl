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

function menu(st)
end

function initlevel(st::Status, lv::Level)
	lv.initializer(st)
	draw(st.canvas)
end

function level(st::Status, id::Integer, desc="#$id")
	st.current=id
	lv=st.levels[id]
	set_gtk_property!(st.window, :title, "LightLearn: $desc")
	initlevel(st, lv)
	ev_enter(st, st.grids[st.x, st.y])
end
function level(st::Status, name::AbstractString)
	for tup in st.chapters
		if tup[2]==name
			st.current=tup[1]
			level(st, tup[1])
			break
		end
	end
end

function rewind(st::Status)
	lv=st.levels[st.current]
	initlevel(st, lv)
	plyenter(grids[lv.startx,lv.starty])
end
#=mvw()=move(0,-1)
mva()=move(-1,0)
mvs()=move(0,1)
mvd()=move(1,0)=#
function move(st::Status, x::Int, y::Int)
	tx=st.x+x
	ty=st.y+y
	grids=st.grids
	if in(grids, tx, ty) || @inbounds _solid(grids[tx, ty])
		return
	end
	if st.x==tx && st.y==ty
		@inbounds ev_stay(st, grids[tx, ty])
	else
		@inbounds ev_leave(st, grids[st.x, st.y])
		st.x=tx
		st.y=ty
		@inbounds ev_enter(st, grids[tx, ty])
	end
	draw(st.canvas)
	if st.formal
		sleep(st.interval)
	end
end

function submit(st::Status, f::Function)
	lv=levels[st.current]
	initlevel(st, lv)
	st.formal=true
	try
		ev_enter(st, grids[st.x, st.y])
		f()
		if !lv.check()
			printstyled("未达成目标"; color=Base.default_color_warn)
			return
		end
		printstyled("通过"; color=Base.default_color_info)
	finally
		st.formal=false
	end
	nothing # block display
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
