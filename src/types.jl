function plyenter(i::Any)
	if solid(i)
		throw(LiError(:cheat))
	end
end
solid(::Any)=false

# Nothing
function show_grid(ctx::DContext,::Nothing,x::Int,y::Int)
	set_source_rgb(ctx,0.75,0.75,0.75)
	rectangle(ctx,x,y,32,32)
	fill(ctx)
end

# Int
function show_grid(ctx::DContext,num::Int,x::Int,y::Int)
	set_source_rgb(ctx,0.75,0.75,0.75)
	rectangle(ctx,x,y,32,32)
	fill(ctx)
	fill_text(ctx,string(num),x,y,32)
end

# Vector
show_grid(ctx::DContext,::Vector,x::Int,y::Int)=fill_image(ctx,"vector",x,y)

struct Solid end
solid(::Solid)=true
function show_grid(ctx::DContext,::Solid,x::Int,y::Int)
	set_source_rgb(ctx,0.5,0.5,0.5)
	rectangle(ctx,x,y,32,32)
	fill(ctx)
end

struct Flag end
show_grid(ctx::DContext,::Flag,x::Int,y::Int)=fill_image(ctx,"flag",x,y)

struct Info s::String end
function plyenter(i::Info)
	if !formal
		println(i.s)
	end
end
show_grid(ctx::DContext,::Info,x::Int,y::Int)=fill_image(ctx,"info",x,y)

struct Dice end
function plyenter(::Dice)
	grids[plyx,plyy]=rand(1:6)
end
show_grid(ctx::DContext,::Dict,x::Int,y::Int)=fill_image(ctx,"dice",x,y)
