module LightLearn
using Gtk
using Cairo
using ColorTypes:RGB24, RGB
using CommonMark
using PNGFiles
using PNGFiles.FixedPointNumbers:N0f8
using TOML
using Scratch
using Downloads
using JSON
using ZipFile

const LL_VERSION = v"3.0.0"
const DContext = Union{CairoContext, GraphicsContext}

export Cell, Empty, Wall, NumCell
include("types.jl")

export Grid, Status

"""
内置的默认网格类型
"""
mutable struct Grid
	data::Matrix{Cell}
end
Grid()=Grid(fill(Empty(), 16, 16))
Base.getindex(g::Grid, x, y)=g.data[x, y]
function Base.setindex!(g::Grid, v::Cell, x, y)
	g.data[x, y]=v
end
function clear!(g::Grid#=, x=16, y=16=#)
	# if size(g, 1)<x
	fill!(g.data, Empty())
end
function Base.in(::Grid, x::Integer, y::Integer)
	return 1<=x<=16 && 1<=y<=16
end

"""
内置的默认状态集类型
"""
mutable struct Status
	# control
	formal::Bool
	levels::Dict
	current::Vector
	# map
	grids::Grid
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

export install_localzip, install_webzip, install_repo
include("install.jl")

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
export sandbox, tp, getindex, setindex!
include("sandbox.jl")

export init,vis,quit
"初始化数据，其中`b`控制是否导入标准Package项目"
function init(loadstd::Bool=true, st::Status) # __init__
	if loadstd
		dir=getllpdir("Standard")
		if !isfile(joinpath(dir, "Project.toml"))
			install("JuliaRoadmap", "Standard.llp", "latest")
		end
		loaddir(st, dir)
	end
	init_canvas(st)
	showall(st.window)
	nothing
end
"控制窗口可见性"
function vis(b::Bool)
	visible(window::GtkWindow,b)
end

function init_canvas(st::Status)
	st.window=GtkWindow("LightLearn",544,528;resizable=false)
	st.canvas=GtkCanvas()
	push!(st.window, st.canvas)
	@guarded draw(st.canvas) do _ # https://docs.gtk.org/gtk4/class.DrawingArea.html
		init_coord(st)
		_draw(st)
	end
end
function init_coord(st)
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
