Lua 是一门动态类型语言，但通过 Lua 提供的 `type` 函数，以及元表，高阶函数等技巧，可以实现运行时的类型检查，以及强类型函数。
通过构造一个合适的类型系统，我们应该能够写出这样的代码

原子类型，等价于只有一个元素的联合类型

```lua
local t = Type.def("union", "integer")
t:check(1) -- true
t:assert(nil) -- error: type mismatch, expect integer, got nil
-- 等价于
local t = Type.def({
	attr = "union",
	data = { "integer" },
})
```

数值类型，等价于只有一个元素的枚举类型

```lua
local t = Type.def("enum", 1)
t:check(1) -- true
t:check("string") -- error: type mismatch, expect 1, got nil
-- 等价于
local t = Type.def({
	attr = "enum",
	data = { number = 1 },
})
```

标准枚举类型
如果枚举类型只有一个元素，将视为数值类型。

```lua
-- 使用字典定义枚举类型。
local t = Type.def({
	attr = "enum",
	data = { a = 1, b = 2, c = 3 },
})
t:annotation() -- enum<1:a,2:b,3:c>
-- 使用列表定义枚举类型。
local t = Type.def({
	attr = "enum",
	data = { 1, 2, 3 },
})
t:annotation() -- enum<1,2,3>
-- 缩写
Type.def("enum", 1, 2, 3)
Type.def("enum", { 1, 2, 3 })
Type.def("enum", { a = 1, b = 2, c = 3 })
```

标准联合类型
如果联合类型只有一个元素，将视为原子类型。

```lua
local t = Type.def({
	attr = "union",
	data = { "string", "integer" },
})
t:check(1) -- true
t:check("string") -- true
t:assert(nil) -- error: type mismatch, expect string|integer, got nil
-- 缩写
Type.def("union", "string", "integer")
Type.def("union", { "string", "integer" })
```

动态类型，用闭包检查类型，接受一个参数 x，返回类型是否匹配

```lua
local len = math.random(10)
local t = Type.def({
	attr = "dynamic",
	data = {
		test = function(x)
			if #x < len then
				return true
			end
		end,
		-- 自定义类型描述符
		desc = "table lt " .. len,
	},
})
-- 根据 len 返回值
t:check({ 1, 2, 3 })
-- 缩写
Type.def(function(x)
	return #x < len
end, "table lt " .. len)
```

标准元组类型

```lua
local t = Type.def({
	attr = "tulple",
	data = { "integer", "integer", "integer" },
})
t:check(1, 2, 3) -- true
t:check(1, 2) -- error: type mismatch, expect tuple<integer,integer,integer>, got tuple<integer,integer>
-- 可变参数／返回值支持
local t = Type.def({
	attr = "tulple",
	data = { "integer", "varargs" }, -- varargs 不占用位置，直接扩展上一个类型
})
t:assert(1, 2, "string") -- error: type mismatch, expect integer..., got string at #3
-- varargs 允许指定末尾参数类型
local t = Type.def({
	attr = "tulple",
	data = { "integer", "varargs", "string" },
})
t:check(1, 2, "string") -- true
-- 缩写
Type.def("tuple", { "integer", "varargs", "string" })
```

标准函数类型

```lua
local t = Type.def({
	attr = "function",
	data = {
		-- args 和 rets 会直接用于构建元组类型
		args = { "integer", "integer" },
		rets = { "integer" },
	},
})
local f = t:wrap(function(a, b)
	if a == 3 then
		return
	end
	return a + b
end)
f(1, 2) -- safe
f(nil, 2) -- error: type mismatch, expect args<integer,integer>, got args<nil,integer>
f(3, 2) -- error: type mismatch, expect result<integer>, got nil
--- varargs 示例
local t = Type.def({
	attr = "function",
	data = {
		args = { "integer", "varargs" },
		rets = { "integer", "varargs", "string", "string" },
	},
})
local f = t:wrap(function(...)
	local args = { ... }
	table.insert(args, "string")
	table.insert(args, "string")
	return args
end)
f(1, 2, 3) -- true
```

标准数组类型

```lua
local t = Type.def({
    attr = "list",
    data = "integer",
})
t:check({}) -- true
t:check({ 1, 2, 3 }) -- true
t:assert(nil) -- error: type mismatch, expect list<integer>, got nil
-- 缩写
Type.def("list", "integer")
```

标准哈希表类型

```lua
local t = Type.def({
    attr = "dict",
    data = { k = "string", v = "string" },
})
t:check({}) -- true
t:check({ k = "v" }) -- true
t:assert(nil) -- error: type mismatch, expect dict<string,string>, got nil
-- 缩写
Type.def("dict", "string", "string")
Type.def("dict", { k = "string", v = "string" })
```

递归表类型

```lua
local t = Type.def({
	attr = "recur",
	data = {
		a = "integer",
		b = {
			attr = "dict",
			data = { k = "string", v = "string" },
		},
	},
})
-- 缩写
Type.def({
	{
		a = "integer",
		b = {
			attr = "dict",
			data = { k = "string", v = "string" },
		},
	},
})
```

在 Lua 中使用类型系统的好处不必多言，通过运行时类型检查，及时发现错误，提高代码的健壮性，让代码更易读，更容易维护。
这种类型检查方式，只需要定义一次类型表格，允许内部实现中将类型表优化成效率更高的数据结构，同时具有良好的可读性。
