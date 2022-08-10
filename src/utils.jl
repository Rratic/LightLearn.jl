function chknear(st::Status, x::Int, y::Int)
	if abs(x-st.x)+abs(y-st.y)>1
		error("太远了")
	end
end

function chkin(st::Status, x::Int, y::Int)
	if !in(st.grids, x, y)
		error("越界")
	end
end

function look(st::Status, x::Int, y::Int)
	chknear(st, x, y)
	chkin(st, x, y)
	@inbounds v=st.grids[x,y]
	return _look(v)
end

function send(st::Status, method::Symbol, x::Int, y::Int, args...)
	chknear(st, x, y)
	chkin(st, x, y)
	@inbounds return _send(st.grids[x, y], Val(method), args...)
end
