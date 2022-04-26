# Any
function plyenter(i::Any)
	if solid(i)
		throw(LiError(:cheat))
	end
end
solid(::Any)=false
_look(i)=i

# Nothing
function show_grid(::DContext,::Nothing,::Int,::Int)
end

# Int
function show_grid(ctx::DContext,num::Int,x::Int,y::Int)
	fill_text(ctx,string(num),x,y)
end

# Vector
show_grid(ctx::DContext,::Vector,x::Int,y::Int)=fill_image(ctx,"vector",x+3,y+3)

struct Solid end
solid(::Solid)=true
function show_grid(ctx::DContext,::Solid,x::Int,y::Int)
	set_source_rgb(ctx,0.5,0.5,0.5)
	rectangle(ctx,x,y,32,32)
	fill(ctx)
end

struct Flag end
show_grid(ctx::DContext,::Flag,x::Int,y::Int)=fill_image(ctx,"flag",x+9,y+2)

struct Info s::String end
function plyenter(i::Info)
	if !formal
		println(i.s)
	end
end
show_grid(ctx::DContext,::Info,x::Int,y::Int)=fill_image(ctx,"info",x+11,y+2)

struct Dice end
function plyenter(::Dice)
	grids[plyx,plyy]=rand(1:6)
end
show_grid(ctx::DContext,::Dice,x::Int,y::Int)=fill_image(ctx,"dice",x+4,y+4)

struct GuessLock
	value
	onguess::Function
end
solid(::GuessLock)=false
show_grid(ctx::DContext,::GuessLock,x::Int,y::Int)=fill_image(ctx,"guesslock",x+3,y+3)
_look(::GuessLock)="[access denied]"
function _guess(i::GuessLock,v)
	i.onguess(i,v)
end