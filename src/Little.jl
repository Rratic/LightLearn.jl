module Little
using Gtk
using Cairo
using ColorTypes:RGB24
using FileIO

include("draw.jl")
include("data.jl")

export solid
export Solid,Flag,Info,Dice
include("types.jl")

export grids,about,level,help,submit,mvw,mva,mvs,mvd
include("control.jl")

function __init__()
	global window=GtkWindow("Little",512,512;resizable=false)
	push!(window,canvas)
	Gtk.init_cairo_context(canvas)
	cd(dirname(@__DIR__))
	for s in ["dice","flag","info","ply","vector"]
		load_imgsource(s,"img/$s.png")
	end
	showall(window)
end

end
