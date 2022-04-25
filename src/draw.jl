const DContext=Union{CairoContext,GraphicsContext}
global imgsources=Dict{String,Matrix}()
function load_imgsource(name::String,path::String)
	mat=FileIO.load(path)
	tup=size(mat)
	h=tup[1]
	w=tup[2]
	m2=Matrix{RGB24}(undef,h,w)
	for i in 1:h
		for j in 1:w
			m2[i,j]=RGB24(mat[j,i]) # specific
		end
	end
	imgsources[name]=m2
end
function fill_image(ctx::DContext,s::String,x::Int,y::Int)
	img=imgsources[s]
	sur=CairoImageSurface(img)
	set_source_surface(ctx,sur,x,y)
	paint(ctx)
end
function fill_text(ctx::DContext,text::String,x::Int,y::Int,w::Int=32,h::Int=32)
	tw=textwidth(text)
	sz=div(w,tw)
	set_font_size(ctx,sz)
	set_source_rgb(ctx,0,0,0)
	move_to(ctx,x+h,y) # show_text 从左下角开始
	show_text(ctx,text)
end
