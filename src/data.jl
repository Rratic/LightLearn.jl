struct Level
	description::String
	startx::Int
	starty::Int
	gen::Function
	chk::Function
end
private=Dict{Symbol,Any}()
chapters=Dict{String,Vector{String}}()
levels=Dict{String,Level}()
function loadpack(s::AbstractString)
	loaddir(getllpdir(s))
end
function loaddir(s::AbstractString)
	@info "导入关卡包：$s"
	mod=include(joinpath(s,"main.jl"))
	typeassert(mod,Module)
	mod.build()
	for p in mod.llpdata
		if haskey(levels,p.first)
			printstyled("关卡名冲突：$(p.first)";color=:red)
		end
		levels[p.first]=p.second
	end
	setting=TOML.parsefile(joinpath(s,"setting.toml"))
	chas=setting["chapters"]
	for p::Pair{String,Vector} in chas
		if haskey(chapters,p.first)
			append!(@inbounds(chapters[p.first]),p.second)
		else
			chapters[p.first]=p.second
		end
	end
end
