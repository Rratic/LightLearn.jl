# Any
function plyenter(i::Any)
	if solid(i)
		throw("禁止作弊")
	end
end
solid(::Any)=false
_look(i)=i
_send(::Any,::Val,args...)=nothing

# Nothing
show_grid(::DContext,::Nothing,::Int,::Int)=nothing

# Int
function show_grid(ctx::DContext,num::Int,x::Int,y::Int)
	fill_text(ctx,string(num),x,y)
end

struct Solid end
solid(::Solid)=true
function show_grid(ctx::DContext,::Solid,x::Int,y::Int)
	set_source_rgb(ctx,0.5,0.5,0.5)
	rectangle(ctx,x,y,32,32)
	fill(ctx)
end
