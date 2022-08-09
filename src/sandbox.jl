struct Sandbox
	ref::Status
end

function sandbox(st::Status)
	set_gtk_property!(st.window, :title, "Sandbox")
	st.x=1
	st.y=1
	draw(st.canvas)
	return Sandbox(st)
end
function tp(sand::Sandbox, x::Integer, y::Integer)
	st=sand.ref
	chkin(st, x, y)
	st.x=x
	st.y=y
	draw(st.canvas)
end
function Base.getindex(sand::Sandbox, x::Integer, y::Integer)
	st=sand.ref
	chkin(st, x, y)
	@inbounds return st.grids[x, y]
end
function Base.setindex!(sand::Sandbox, v, x::Integer, y::Integer)
	st=sand.ref
	chkin(st, x, y)
	@inbounds st.grids[x, y]=v
	draw(st.canvas)
end
