function getllpdir(name::AbstractString)
	return joinpath(get_scratch!(@__MODULE__,"llp"),name)
end
function install(owner::AbstractString,repo::AbstractString,version::AbstractString="latest")
	io=IOBuffer()
	request("https://api.github.com/repos/$owner/$repo/releases";method="GET",output=io)
	str=String(take!(io))
	if version=="latest"
	else
	end
	install(joinpath(repo,"archive/refs/tags/$version.zip"))
end
function install(tar::AbstractString)
	@info "安装关卡包：$tar"
	dir=get_scratch!(@__MODULE__,"llp")
end
function update(owner::AbstractString,repo::AbstractString)
	install(owner,repo)
end
