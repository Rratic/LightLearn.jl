module LightLearn
using Gtk
using Cairo
using ColorTypes:RGB24, RGB
using CommonMark
using Pkg
using PNGFiles
using PNGFiles.FixedPointNumbers:N0f8
using TOML
using Scratch
using Downloads
using JSON
using ZipFile

const LL_VERSION = v"3.0.0"
const DContext = Union{CairoContext, GraphicsContext}

export Cell, Space, Wall, NumCell
include("types.jl")

export Grid, Level, LevelSlot, Status

mutable struct Grid
	data::Matrix{Cell}
end

Grid()=Grid(fill(Space(), 16, 16))
Base.getindex(g::Grid, x, y)=g.data[x, y]
function Base.setindex!(g::Grid, v::Cell, x, y)
	g.data[x, y]=v
end
function clear!(g::Grid#=, x=16, y=16=#)
	# if size(g, 1)<x
	fill!(g.data, Space())
end
function Base.in(::Grid, x::Integer, y::Integer)
	return 1<=x<=16 && 1<=y<=16
end

struct Level
	initializer::Function
	check::Function
end

struct LevelSlot
	linkid::Int
	title::String
end

function default_parser()
	p=CommonMark.Parser()
	enable!(p, AdmonitionRule())
	return p
end
Base.@kwdef mutable struct Status
	# control
	formal::Bool = false
	levels::Vector{Level} = Level[]
	current::Int = 1
	chapters::Vector{LevelSlot} = LevelSlot[]
	# map
	grids::Grid = Grid()
	x::Int = 1
	y::Int = 1
	private::Dict = Dict{Symbol, Any}(:mdparser => default_parser())
	# display
	window::GtkWindow
	canvas::GtkCanvas
	context::Union{DContext, Nothing} = nothing
	interval::Float64 = 0.5
	imgcache::Dict{String, Matrix} = Dict{String, Matrix}()
end
function Base.show(io::IO, st::Status)
	if st.formal
		print(io, "<formal> ")
	end
	println(io, get_gtk_property(st.window, :title, String))
end

include("draw.jl")

export install_localzip, install_webzip, install_githubrepo, uninstall
include("install.jl")

export load_package, load_dir
include("data.jl")

export look, send
include("utils.jl")

export menu, level, rewind, submit
export north!, west!, east!, south!
include("control.jl")

# 沙盒
export sandbox, tp, getindex, setindex!
include("sandbox.jl")

export init, vis, quit

function init(loadstd::Bool=true) # __init__
	st=Status(;
		window=GtkWindow("LightLearn", 544, 528; resizable=false, visible=false),
		canvas=GtkCanvas()
	)
	try
		push!(st.window, st.canvas)
		if loadstd
			dir=getllpdir("Standard")
			if !isfile(joinpath(dir, "Project.toml"))
				install_githubrepo("JuliaRoadmap", "Standard.llp", "latest")
			end
			load_dir(st, dir)
		end
		init_canvas(st)
		visible(st.window)
		showall(st.window)
	catch er
		destroy(st.window)
		throw(er)
	end
	return st
end

vis(st::Status, b::Bool)=visible(st.window::GtkWindow, b)

function init_canvas(st::Status)
	# https://docs.gtk.org/gtk4/class.DrawingArea.html
	@guarded draw(st.canvas) do _
		st.context=getgc(st.canvas)
		init_coord(st)
		_draw(st)
	end
end

function init_coord(st::Status)
	ctx=st.context
	set_source_rgb(ctx,0.75,0.75,0.75) # 背景填充
	rectangle(ctx,0,0,544,528)
	fill(ctx)
	for i in 1:16
		fill_text(st, "$i", 512, (i-1)<<5, 16, 16, 16)
		fill_text(st, "$i", (i-1)<<5, 512, 16, 16, 16)
	end
end

quit(st::Status)=destroy(st.window)

end
