function getllpdir(name::AbstractString)
	return joinpath(get_scratch!(@__MODULE__, "llp"), name)
end

function chkcompat(str::AbstractString)
	ver=Pkg.Types.semver_spec(str)
	if !(LL_VERSION in ver)
		error("LightLearn 版本 $LL_VERSION 不符合要求 ($ver)")
	end
end

function chkcompatmsg(str::AbstractString)
	compat=findfirst(r"COMPAT=\".*\"", str)
	if compat===nothing
		error("发布信息中未找到符合格式的 COMPAT 数据")
	end
	return chkcompat(str[compat.start+8:compat.stop-1])
end

function uninstall(name::AbstractString)
	rm(getllpdir(name))
end

function install_localzip(fpath::AbstractString; remove::Bool=false)
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
		error("未找到位于根的Project.toml")
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
	if remove
		rm(fpath)
	end
end

function install_webzip(url::AbstractString)
	fpath=joinpath(tempdir(), tempname())*"_llp.zip"
	fio=open(fpath, "w")
	Downloads.download(url, fio)
	close(fio)
	install_localzip(fpath)
end

function install_githubrepo(owner::AbstractString, repo::AbstractString, version::AbstractString="latest")
	io=IOBuffer()
	quest=request("https://api.github.com/repos/$owner/$repo/releases";method="GET",output=io)
	if quest.status!=200
		error("Github API 请求失败，status=$(quest.status)")
	end
	str=String(take!(io))
	json=JSON.parse(str)
	typeassert(json,Vector)
	if version=="latest"
		for d in json
			@info "尝试：$(d["tag_name"])"
			try
				chkcompatmsg(d["body"])
				install_webzip(d["zipball_url"])
				return
			catch er
				if isa(er, ErrorException)
					@warn er
				else
					throw(er)
				end
			end
		end
	else
		for d in json
			if d["tag_name"]==version
				chkcompatmsg(d["body"])
				install_webzip(d["zipball_url"])
			end
		end
		@error "未找到标记为 $version 的发布"
	end
end
