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
			m2[i,j]=RGB24(mat[i,j])
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
function fill_text(ctx::DContext,text::String,x::Int,y::Int,w::Int)
	tw=textwidth(text)
	sz=div(w,tw)
	set_font_size(ctx,sz)
	set_source_rgb(ctx,0,0,0)
	move_to(ctx,x,y)
	show_text(ctx,text)
end
