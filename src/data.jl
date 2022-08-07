struct Level
	initializer::Function
	check::Function
end

function loadpack(st, s::AbstractString)
	loaddir(st, getllpdir(s))
end
function loaddir(st, s::AbstractString)
	@info "正在导入关卡包：$s"
	#= setting=TOML.parsefile(joinpath(s, "Project.toml"))::Dict
	if haskey(setting, "description")
		@info setting["description"]
	end =#
	mod=include(joinpath(s, "src/$(setting["name"]).jl"))::Module
	mod.init()
	for lvs in mod.levels
		if haskey(levels,p.first)
			printstyled("关卡名冲突：$(p.first)";color=:red)
		end
		levels[p.first]=p.second
	end
end
