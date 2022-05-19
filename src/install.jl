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
	fio=open(fpath,"w")
	Downloads.download(url,fio)
	close(fio)
	re=ZipFile.Reader(fpath)
	fs=re.files
	maindir=fs[1].name # 实践得出
	len=length(maindir)
	fnum=length(fs)
	tomls=""
	# 除去github自动生成的第一层目录包裹
	for f in 2:fnum
		fs[f].name=chop(fs[f].name;head=len,tail=0)
		if fs[f].name=="Project.toml"
			tomls=read(fs[f],String)
		end
	end
	if tomls==""
		throw("未找到位于根的Project.toml")
	end
	toml=TOML.parse(tomls)
	pname=toml["name"]
	dir=getllpdir(pname)
	mkpath(dir)
	cd(dir)
	@info "关卡包数据" toml["version"] toml["description"]
	for f in 2:fnum
		if iszero(fs[f].method)
			mkpath(fs[f].name)
		else
			buf=readavailable(fs[f])
			io=open(fs[f].name,"w")
			write(io,ltoh(buf))
			close(io)
		end
	end
	io=open("Project.toml","w")
	write(io,tomls)
	close(io)
	close(re)
	rm(fpath)
end
function install(owner::AbstractString,repo::AbstractString,version::AbstractString="latest")
	io=IOBuffer()
	quest=request("https://api.github.com/repos/$owner/$repo/releases";method="GET",output=io)
	if quest.status!=200
		throw("Github API 请求失败，status=$(quest.status)")
	end
	str=String(take!(io))
	json=JSON.parse(str)
	typeassert(json,Vector)
	if version=="latest"
		for d in json
			@info "尝试：$(d["tag_name"])"
			try
				chkcompat(d["body"])
				installzip(d["zipball_url"])
			catch er
				if isa(er,String)
					@error er
				else
					throw(er)
				end
			end
		end
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
