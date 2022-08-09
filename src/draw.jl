function load_imgsource(st::Status, name::String, path::String)
	mat=PNGFiles.load(path)
	tup=size(mat)
	h=tup[1]
	w=tup[2]
	m2=Matrix{RGB24}(undef, w, h) # 列优先与行优先
	for i in 1:h
		for j in 1:w
			m2[j, i]=RGB24(mat[i, j])
		end
	end
	st.imgcache[name]=m2
end

function load_imgsources(st::Status)
	vec=readdir(;sort=false)
	for str in vec
		name, _ = splitext(str)
		load_imgsource(st, name, str)
	end
end

function fill_image(st::Status, s::String, x::Integer, y::Integer)
	ctx=st.context
	if !haskey(st.imgcache, s)
		@warn "未找到图像资源：$s"
		set_source_rgb(ctx, 0.7, 0, 0)
		rectangle(ctx, x, y, 16, 16)
		return
	end
	img=st.imgcache[s]
	sur=CairoImageSurface(img)
	set_source_surface(ctx, sur, x, y)
	paint(ctx)
end
function fill_text(st::Status,
	text::String,
	x::Int,
	y::Int,
	w::Int=32,
	h::Int=32,
	sz=div(w, textwidth(text)))
	ctx=st.context
	set_font_size(ctx, sz)
	set_source_rgb(ctx, 0, 0, 0)
	move_to(ctx, x, y+h) # show_text 从左下角开始
	show_text(ctx, text)
end
