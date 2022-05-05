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
function loaddir(s::String)
	dict=include(joinpath(s,"main.jl"))
	for p in dict
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
