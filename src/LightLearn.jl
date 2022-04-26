module LightLearn
using Gtk
using Cairo
using ColorTypes:RGB24
using FileIO

include("draw.jl")

grids=Matrix{Any}(nothing,16,16)
levelid=0
plyx=0
plyy=0
formal=false
interval=0.0
canvas=GtkCanvas()

export solid # 通用接口
include("types.jl")

include("data.jl")

export about,level,help,submit,mvw,mva,mvs,mvd,look # 通用接口
export guess # 特殊接口
export interval # 可调变量
include("control.jl")

export init,vis
function init() # __init__
	init_source()
	init_canvas()
	init_coord()
	showall(window)
	nothing
end
function vis(b::Bool)
	visible(window,b)
end

function init_source()
	cd(dirname(@__DIR__))
	for s in readdir("img";sort=false)
		load_imgsource(s[1:end-4],"img/$s")
	end
end
function init_canvas()
	global window=GtkWindow("LightLearn",544,528;resizable=false)
	push!(window,canvas)
	Gtk.init_cairo_context(canvas)
end
function init_coord()
	ctx=getgc(canvas)
	set_source_rgb(ctx,0.75,0.75,0.75) # 背景填充
	rectangle(ctx,0,0,544,528)
	fill(ctx)
	for i in 1:16
		fill_text(ctx,"$i",512,(i-1)<<5,16,16,16)
		fill_text(ctx,"$i",(i-1)<<5,512,16,16,16)
	end
end

@guarded draw(canvas) do widget
	init_coord()
	_draw()
end

end
