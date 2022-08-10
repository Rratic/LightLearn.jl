function load_package(st::Status, s::AbstractString)
	load_dir(st, getllpdir(s))
end

function load_dir(st::Status, s::AbstractString)
	@info "$s"
	setting=TOML.parsefile(joinpath(s, "Project.toml"))::Dict
	chkcompat(setting["compat"]["LightLearn"])
	mod=include(joinpath(s, "src/$(setting["name"]).jl"))
	Base.invokelatest(mod.init, st)
	applen=length(mod.levels)
	orilen=length(st.levels)
	fullen=applen+orilen
	sizehint!(st.levels, fullen)
	sizehint!(st.chapters, fullen)
	for pair in mod.levels
		orilen+=1
		push!(st.levels, pair.second)
		push!(st.chapters, LevelSlot(orilen, pair.first))
	end
end
