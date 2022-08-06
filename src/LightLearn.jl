module LightLearn
using Gtk
using Cairo
using ColorTypes:RGB24,RGB
using Markdown
using PNGFiles
using PNGFiles.FixedPointNumbers:N0f8
using TOML
using Scratch
using Downloads
using JSON
using ZipFile

const LL_VERSION = v"3.0.0"
const DContext = Union{CairoContext, GraphicsContext}

export Status

"""
内置的默认状态集类型
"""
mutable struct Status
	# control
	formal::Bool
	levels::Dict
	current::Vector
	# map
	grids::Matrix{Cell}
	x::Int
	y::Int
	private::Dict{Symbol, T} where T
	# display
	window::GtkWindow
	canvas::GtkCanvas
	context::DContext
	interval::Float64
	imgcache::Dict{String, Matrix}
end

include("draw.jl")

export install
include("install.jl")

include("types.jl")

export loadpack,loaddir
include("data.jl")

# 流程接口
export about,menu,level,rewind,submit
# 使用接口
export mvw,mva,mvs,mvd,solid,look,send
# 动画设置
export interval,setinterval
include("control.jl")

# 沙盒
export sandbox,tp,getindex,setindex!
include("sandbox.jl")

export init,vis,quit
"初始化数据，其中`b`控制是否导入标准Package项目"
function init(loadstd::Bool=true) # __init__
	if loadstd
		dir=getllpdir("Standard")
		if !isfile(joinpath(dir, "Project.toml"))
			install("JuliaRoadmap", "Standard.llp", "latest")
		end
		loaddir(dir)
	end
	init_canvas()
	showall(window::GtkWindow)
	nothing
end
"控制窗口可见性"
function vis(b::Bool)
	visible(window::GtkWindow,b)
end

function init_canvas()
	global window=GtkWindow("LightLearn",544,528;resizable=false)
	global canvas=GtkCanvas()
	push!(window,canvas)
	@guarded draw(canvas) do widget # https://docs.gtk.org/gtk4/class.DrawingArea.html
		init_coord()
		_draw()
	end
end
function init_coord()
	ctx=getgc(canvas::GtkCanvas)
	set_source_rgb(ctx,0.75,0.75,0.75) # 背景填充
	rectangle(ctx,0,0,544,528)
	fill(ctx)
	for i in 1:16
		fill_text(ctx,"$i",512,(i-1)<<5,16,16,16)
		fill_text(ctx,"$i",(i-1)<<5,512,16,16,16)
	end
end

"退出"
function quit()
	destroy(window)
end

end
