struct Sandbox end
function sandbox()
	if formal
		throw("不能在提交时调用sandbox")
	end
	display(md"""
	欢迎使用沙盒模式！
	请保留此函数的返回值，假设为sand
	```jl
	tp(x,y)		移动到(x,y)处
	sand[x,y]	获取(x,y)处的数据
	sand[x,y]=v	覆盖(x,y)处的数据
	```
	""")
end
function tp(x::Int,y::Int)
	if formal
		throw("不能在提交时调用tp")
	end
	if x<1||y<1||x>16||y>16
		throw("越界")
	end
	global plyx=x
	global plyy=y
end
function Base.getindex(::Sandbox,x::Int,y::Int)
	if formal
		throw("禁止作弊")
	end
	if x<1||y<1||x>16||y>16
		throw("越界")
	end
	return grids[x,y] # @inbounds
end
function Base.setindex!(::Sandbox,x::Int,y::Int,v)
	if formal
		throw("禁止作弊")
	end
	if x<1||y<1||x>16||y>16
		throw("越界")
	end
	grids[x,y]=v
end
