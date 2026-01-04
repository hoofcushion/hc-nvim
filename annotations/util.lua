---@diagnostic disable

Lua={
 unknown      =_, ---@class unknown
 any          =_, ---@class any
 _nil         =_, ---@class nil
 boolean      =_, ---@class boolean
 _true        =_, ---@class true: boolean
 _false       =_, ---@class false: boolean
 number       =_, ---@class number
 integer      =_, ---@class integer: number
 thread       =_, ---@class thread
 table        =_, ---@class table<K, V>: { [K]: V }
 string       =_, ---@class string: stringlib
 userdata     =_, ---@class userdata
 lightuserdata=_, ---@class lightuserdata
 _function    =_, ---@class function

}
---@return unknown
function Lua.unkown() return _ end
---@generic A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z
---@param a A?
---@param b B?
---@param c C?
---@param d D?
---@param e E?
---@param f F?
---@param g G?
---@param h H?
---@param i I?
---@param j J?
---@param k K?
---@param l L?
---@param m M?
---@param n N?
---@param o O?
---@param p P?
---@param q Q?
---@param r R?
---@param s S?
---@param t T?
---@param u U?
---@param v V?
---@param w W?
---@param x X?
---@param y Y?
---@param z Z?
---@return A|B|C|D|E|F|G|H|I|J|K|L|M|N|O|P|Q|R|S|T|U|V|W|X|Y|Z
function Lua.union(a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z)
 return Lua.unkown()
end
---@generic V
---@param v V
---@return V[]
function Lua.list(v)
 return Lua.unkown()
end
---@generic K,V
---@param k K
---@param v V
---@return table<K,V>
function Lua.dict(k,v)
 return Lua.unkown()
end
---@generic V
---@param v V
---@return V?
function Lua.optional(v)
 return v
end
if false then
 user={
  name=Lua.string,
  age=Lua.integer,
 }
 users=Lua.dict(Lua.string,user)
 --users.foo.
 --          ^will show completions: name,age
end
---@generic T
---@param t T
---@return T
function Lua.as(v,t)
 return v
end
