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

export solid # 通用接口
include("types.jl")

include("data.jl")

export about,level,help,submit,mvw,mva,mvs,mvd,look # 通用接口
export guess # 特殊接口
export interval # 可调变量
include("control.jl")

export init
function init() # __init__
	global window=GtkWindow("LightLearn",512,512;resizable=false)
	global canvas=GtkCanvas()
	push!(window,canvas)
	Gtk.init_cairo_context(canvas)
	cd(dirname(@__DIR__))
	for s in readdir("img";sort=false)
		load_imgsource(s[1:end-4],"img/$s")
	end
	showall(window)
end

end
