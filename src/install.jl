function getllpdir(name::AbstractString)
	return joinpath(get_scratch!(@__MODULE__,"llp"),name)
end
function chkcompat(str::AbstractString)
	compat=findfirst(r"COMPAT=\"v[0-9]*\.[0-9]*(\.[0-9]*)?\"",str)
	if compat===nothing
		throw("发布信息中未找到符合格式的COMPAT数据")
	end
	key=str[compat.start+9:compat.stop-1]
	ver=VersionNumber(key)
	if ver>v"2.0.0"
		throw("LightLearn版本过低，至少需要$ver")
	end
end
function installzip(url::AbstractString)
	fpath=joinpath(tempdir(),tempname())*".zip"
	fio=open(fpath)
	Downloads.download(url,fio)
	close(fio)
	re=ZipFile.Reader(fpath)
	fs=re.files
	close(re)
end
function install(owner::AbstractString,repo::AbstractString,version::AbstractString="latest")
	io=IOBuffer()
	quest=request("https://api.github.com/repos/$owner/$repo/releases";method="GET",output=io)
	if quest.status!=200
		throw("Github API 请求失败，status=$(quest.status)")
	end
	str=String(take!(io))
	json=JSON.parse(str)
	typeassert(json,Vector{Dict})
	if version=="latest"
		chkcompat(dict[1]["body"])
		installzip(dict[1]["zipball_url"])
	else
		for d in json
			if d["tag_name"]==version
				chkcompat(d["body"])
				installzip(d["zipball_url"])
			end
		end
		println("未找到标记为$version 的发布")
	end
end
