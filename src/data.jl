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
	@info "正在导入关卡包：$s"
	setting=TOML.parsefile(joinpath(s,"Project.toml"))
	typeassert(setting,Dict)
	tup=include(joinpath(s,"src/$(setting["name"]).jl"))
	typeassert(tup,Tuple)
	Base.invokelatest(tup[2]) # !: The applicable method may be too new
	for p in tup[1]
		if haskey(levels,p.first)
			printstyled("关卡名冲突：$(p.first)";color=:red)
		end
		levels[p.first]=p.second
	end
	chas=setting["chapters"]
	for p::Pair{String,Vector} in chas
		if haskey(chapters,p.first)
			append!(@inbounds(chapters[p.first]),p.second)
		else
			chapters[p.first]=p.second
		end
	end
end
