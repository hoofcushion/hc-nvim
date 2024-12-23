Lua 是一门动态类型语言，但通过 Lua 提供的 `type` 函数，以及元表，高阶函数等技巧，可以实现运行时的类型检查，以及强类型函数。
通过构造一个合适的类型系统，我们应该能够写出这样的代码：
原子类型

```lua
local t=Type.def("integer")
t:check(1) -- true
t:assert(nil) -- error: type mismatch, expect integer, got nil
-- 等价于：
local t=Type.def({attr="atom","integer"})
```

数值类型，等价于只有一个值枚举类型：

```lua
local t=Type.def(1,"number")
t:check(1) -- true
t:check("string") -- error: type mismatch, expect 1, got nil
-- 等价于：
local t=Type.def({attr="enum",data={number=1}})
```

枚举类型：

```lua
-- 使用字典定义枚举类型。
local t=Type.def({
    attr="enum",
    data={blue=1,while=2,black=3},
})
t:annotation() -- enum<1:blue,2:while,3:black>
-- 使用列表定义枚举类型。
local t=Type.def({
    attr="enum",
    data={1,2,3},
})
t:annotation() -- enum<1,2,3>
```

联合类型：

```lua
local t=Type.def({attr="union",data={"string","integer"}})
t:check(1) -- true
t:check("string") -- true
t:assert(nil) -- error: type mismatch, expect string|integer, got nil
```

数组类型：

```lua
local t=Type.def({attr="list",data="integer"})
t:check({}) -- true
t:check({1,2,3}) -- true
t:assert(nil) -- error: type mismatch, expect list<integer>, got nil
```

哈希表类型：

```lua
local t=Type.def({attr="dict",data={k="string",v="string"}})
t:check({}) -- true
t:check({k="v"}) -- true
t:assert(nil) -- error: type mismatch, expect dict<string,string>, got nil
```

函数类型：

```lua
local t=Type.def({
    attr="function",
    data={
        args={"integer","integer"},
        rets={"integer"}
    },
})
local f=t:wrap(function(a,b)
    if a == 3 then
        return
    end
    return a+b
end)
f(1,2) -- safe
f(nil,2) -- error: type mismatch, expect args<integer,integer>, got args<nil,integer>
f(3,2) -- error: type mismatch, expect result<integer>, got nil
local t=Type.def({
    attr="function",
    data={
        args={"integer","varargs"}, -- varargs 不占用位置，直接扩展上一个类型
        rets={"integer","varargs","string","string"} -- 允许倒序检查返回值类型
    },
})
local f=t:wrap(function(...)
    local args={...}
    table.insert(args,"string")
    table.insert(args,"string")
    return args
end)
f(1,2,3) -- true
```

依赖类型，等价于一个函数，接受一个参数 x，返回类型是否匹配：

```lua
local len=math.random(10)
local t=Type.def({
    attr="dynamic",
    data={
        test=function(x) if #x< end,
        desc="any", -- 自定义类型描述符
    },
})
t:check(x) -- 总是返回 true
```

在 Lua 中使用类型系统的好处不必多言，通过运行时类型检查，及时发现错误，提高代码的健壮性，让代码更易读，更容易维护。
而且类型表只需要定义一次，通过缓存类型表能够提升性能，同时具有良好的可读性，同时可以在内部实现中将类型表优化成效率更高的数据结构。
