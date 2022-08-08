"""
表示网格元素的抽象类型
"""
abstract type Cell end

# properties
_solid(::Cell)=false
_look(i::Cell)=i
_send(_, ::Cell, ::Val, args...)=nothing

# events
ev_enter(_, ::Cell)=nothing
ev_leave(_, ::Cell)=nothing
ev_stay(_, ::Cell)=nothing
ev_spawn(_, ::Cell)=nothing
ev_destroy(_, ::Cell)=nothing

### built-in cell types ###

struct Empty<:Cell end
_show(_, ::Empty, x, y)=nothing

struct Wall<:Cell end
_solid(::Wall)=true
function _show(st, ::Wall, x, y)
	ctx=st.context
	set_source_rgb(ctx, 0.5, 0.5, 0.5)
	rectangle(ctx, x, y, 32, 32)
	fill(ctx)
end

struct NumCell<:Cell
	num::Number
end
_show(st, c::NumCell, x, y)=fill_text(st, string(c.num), x, y)
