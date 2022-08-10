## 用户手册
!!! note
	如果您是使用者，请注意：调用本手册以外函数、修改源代码或关卡数据、在提交函数中包含错误的函数等行为均应视作作弊，但不被强制保证。

### 流程
使用 `st = init()` 创建一个游戏句柄，其中 `init` 接收一个参数，为 `false` 时不会导入 [`Standard.llp`](https://github.com/JuliaRoadmap/Standard.llp)。
在结束时，需注意调用 `quit(st)` 注销句柄。

使用 `menu`，你可以阅读已导入的关卡列表（包括整数 id 与 名称），可以通过 `level` 导入指定的关卡。可以进行手动尝试，但是正式提交需要调用 `submit()`，它接受一个函数作为参数，这个函数接受唯一参数是 `st::Status`。在此模式下，你可以调用：（以下函数第一个参数均为 `st::Status`）
* `north!`
* `west!`
* `east!`
* `south!`
* `look(st::Status, x::Int, y::Int)` 在「四相邻格」或本格时进行「观察」
* `send(st::Status, method::Symbol, x::Int, y::Int, args...)` 在「四相邻格」或本格时「发送数据」

### 沙盒模式
使用 `sand = sandbox(st)`，你可以创建一个沙盒。
在此模式下，可以调用 `tp(sand, x, y)`，`sand[x, y]`，`sand[x, y]=v`

### 导入
LightLearn 提供了两个导入函数：
* `load_package(st::Status, s::AbstractString)` 导入已安装的包，使用其名称
* `load_dir(st::Status, s::AbstractString)` 从本地指定目录导入

### 安装
LightLearn 提供了三个安装函数：
* `install_localzip(fpath::AbstractString; remove::Bool=false)` 从本地指定路径安装 zip
* `install_webzip(url::AbstractString)` 从网络指定 url 安装 zip
* `install_githubrepo(owner::AbstractString, repo::AbstractString, version::AbstractString="latest")` 从指定 github 仓库安装指定发布

同时，可以使用 `uninstall(name::AbstractString)` 去除安装

### 杂项
* 可以使用 `vis(st::Status, b::Bool)` 设置窗口可见性

## 开发者手册
[标准 Package 项目地址](https://github.com/JuliaRoadmap/Standard.llp)

目录下应包含以下文件

**Project.toml**
* `name` 当前关卡包名
* `uuid` 一个UUID
* `version` 当前版本
* `description` 介绍
* `[compat]` 其中 `"LightLearn"` 项表示接受的版本

**src/包名.jl**
* 应有一个模块，名称为 `LL_包名`

若要支持 `install_githubrepo` 方法，应在对应的 github 仓库发布 release，标注恰当的 tag（带`v`），在信息中必须含有字段`COMPAT="版本"`，与 `toml["compat"]["LightLearn"]` 统一
