struct Sandbox
	ref::Status
end
function sandbox(st)
	if st.formal
		error("不能在提交时调用sandbox")
	end
	set_gtk_property!(st.window, :title, "Sandbox")
	st.x=1
	st.y=1
	draw(st.canvas)
	return Sandbox(st)
end
function tp(sand::Sandbox, x::Integer, y::Integer)
	st=sand.ref
	if !in(st.grids, x, y)
		error("越界")
	end
	st.x=x
	st.y=y
	draw(st.canvas)
end
function Base.getindex(sand::Sandbox, x::Integer, y::Integer)
	st=sand.ref
	if !in(st.grids, x, y)
		error("越界")
	end
	return st.grids[x,y] # @inbounds
end
function Base.setindex!(sand::Sandbox, v, x::Integer, y::Integer)
	st=sand.ref
	chkin(st, x, y)
	st.grids[x, y]=v
	draw(canvas)
end
