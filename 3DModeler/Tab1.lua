poke(0x5f2d,1)
local c={x=10,y=10,z=10,xr=.5,yr=0}
local tab="mdl"
local curmdl=1
local curcop=1
local models={}
local copies={}
local mdlbtn={}
local cpybtn={}
local tool="none"
local gstyl=2
local mname="untitled"
local sel={}
local col=6
local click=0
local dial=""
local m={
 x=0,
 y=0,
 lc=0,
 rc=0,
 mc=0,
 b=0
}

local view=0
local mview={
 xr=0,
 yr=0
}
local voffs={0,0,0}
local vpos={0,0}
local vposo={0,0}
local pvpos={0,0}
local zoom={1,1,1}

local colst={}

//cols setup
for i=0,3 do
 for j=0,3 do
 	add(colst,sget(j,i))
 end
end

--multiple model support
//save multiple models
//live saving just in case? (printh)

//undo/redo
//fix extrude
//make model loadable
//import prebuilt shapes
//error messages,tips 

//counterclockwise

//table copy
function copy(t)
 local nt={}
 for k,v in pairs(t) do
  nt[k] = type(v)=="table" and copy(v) or v
 end
 return nt
end

//back face culling
function bfc(t)
 local p1,p2,p3=t[1],t[2],t[3]
 local x,y,z=p1[1],p1[2],p1[3]
 local a1,a2,a3=p2[1]-x,p2[2]-y,p2[3]-z
 local b1,b2,b3=p3[1]-x,p3[2]-y,p3[3]-z
 return x*(a2*b3-a3*b2)+y*(a3*b1-a1*b3)+z*(a1*b2-a2*b1)
end

//dot product
function dp(v1,v2) 
 return v1[1]*v2[1]+v1[2]*v2[2]+v1[3]*v2[3]
end


//point in box
function pinb(px,py,b)
	return (px-b[1])\(b[3]-b[1]+1)==0 and (py-b[2])\(b[4]-b[2]+1)==0
end

//box collision
function binb(b1,b2)
 return b1[3]>b2[1] and b1[1]<b2[3] and b1[4]>b2[2] and b1[2]<=b2[4]
end

//distance function
function dist(p1,p2)
	return sqrt((p1[1]-p2[1])^2+(p1[2]-p2[2])^2+(p1[3]-p2[3])^2)
end

//fetches model coordinates from spritesheet
function getmodel(a,b,lp,lt)
 local ps={}
 for tb=b,b+lp-1 do
 	local p={}
 	for i=0,2 do
 		add(p,sget(a+i,tb))
		end
		p.h=0
		add(ps,p)
 end
      
 a+=3
 local tris={}
	for i=1,lt do
		local tri,j,pi={},1,0
		tri.c=sget(a,b)
		tri.h=0
		while j<5 and pi!=sget(a+j,b)+1 do
			pi=sget(a+j,b)+1
			add(tri,pi)
			j+=1
		end
		b+=1
		add(tris,tri)
	end
	
 local model={
  cp=cent(ps),
  ps=ps,
  ts=tris,
 }
 return model
end

function splittri(ts)
 local function alltri(ts)
  for tri in all(ts) do if #tri>3 then return false end end
	 return true
 end
	while not alltri(ts) do
 	for tri in all(ts) do
 		if #tri>3 then
 			local m=#tri\2+1
 			local n={}
 			for i=2,#tri do
 			 add(n,tri[i])
 		  if i==m or i==#tri then
 		  	add(n,tri[1])
 	    n.c=tri.c
 	    n.h=tri.h
 	    n.z=tri.z
 		  	add(ts,n)
 		  	n={tri[m]}
     end
				end
 			del(ts,tri)
			end
		end
 end
 return ts
end

--combines model tables
function addmdl(m1,m2)
 local nm=copy(m1)
 local change={}
 local ldup=0
 for i,p1 in ipairs(m2.ps) do
 	local np={p1[1],p1[2],p1[3]}
 	local dup=false
 	for j,p2 in ipairs(m1.ps) do
 		if np[1]==p2[1] and np[2]==p2[2] and np[3]==p2[3] then
 			change[i]=j
 			dup=true
 			ldup+=1
 			break
			end
		end
		if not dup then
			add(nm.ps,np)
			change[i]=#nm.ps
		end
 end
 
 for t1 in all(m2.ts) do
  local nt=copy(t1)
  for i=1,3 do
 	 nt[i]=change[t1[i]]
 	end
 	local dup=false
 	for t2 in all(m1.ts) do
 		if nt[1]==t2[1] and nt[2]==t2[2] and nt[3]==t2[3] then
 			dup=true
 			break
			end
		end
		if not dup then
 	 add(nm.ts,nt)
 	end
 end
 nm.cp=cent(nm.ps)
 return nm
end

//updates mps mts for arr tab
function updarrm()
	local m1=copy(models[1])
	m1.ts=splittri(m1.ts)
	trfm(m1,copies[1][1])
	local tp=curcop!=-1 and (1!=curmdl or 1!=curcop)
	for t in all(m1.ts) do
	 t.tp=tp
 end
	for i,m in ipairs(copies) do
	 local j=1
		if i==1 then j=2 end
		for j=j,#m do
		 local m2=copy(models[i])
	  m2.ts=splittri(m2.ts)
	  trfm(m2,copies[i][j])
	  tp=curcop!=-1 and (i!=curmdl or j!=curcop)
	  for t in all(m2.ts) do
	  	t.tp=tp
   end
	  m1=addmdl(m1,m2)
	 end
	end
	mps=copy(m1.ps)
 p2d={}
 mts=copy(m1.ts)
end

//shading
function cols(c,d)
 if d==0 or d==nil then return c end
 if d==1 then return colst[c+1] end
	return cols(colst[c+1],d-1)
end

//returns center of a set of points
function cent(s)
 if #s==0 then return {0,0,0} elseif #s==1 then return s[1] else
  local n={0,0,0}
	 for i=1,#s do
	  local p=s[i]
	 	n[1]+=p[1]
	 	n[2]+=p[2]
	 	n[3]+=p[3]
	 end
	 n[1]/=#s
	 n[2]/=#s
	 n[3]/=#s
	 return n
	end
end

//returns the center of a triangle
function tcent(t)
 local p1,p2,p3=t[1],t[2],t[3]
	return {(p1[1]+p2[1]+p3[1])/3,(p1[2]+p2[2]+p3[2])/3,(p1[3]+p2[3]+p3[3])/3}
end

//returns the normal vector
function normal(tri)
 local v1,v2,v3=tri[1],tri[2],tri[3]
 local u,v={},{}
 for i=1,3 do
  add(u,v2[i]-v1[i])
  add(v,v3[i]-v1[i])
 end
 local nv={
  (u[2]*v[3]-u[3]*v[2]),
  (u[3]*v[1]-u[1]*v[3]),
  (u[1]*v[2]-u[2]*v[1])}
 local m=sqrt(nv[1]^2+nv[2]^2+nv[3]^2)
 for i=1,#nv do
 	nv[i]/=m
 end
 return nv
end

//translation
function trans(p,x,y,z)
 if x==0 and y==0 and z==0 then return p end
	return {(p[1]+x)\.125/8,(p[2]+y)\.125/8,(p[3]+z)\.125/8}
end

//scale
function scale(p,x,y,z)
 if x==0 and y==0 and z==0 then return p end
	return {p[1]*x,p[2]*y,p[3]*z}
end

//x rotation
function rtx(p,a)
 if a==0 then return p end
 local ca,sa=cos(a),sin(a)
 --[[
 {{1,0,     0,      0},
  {0,cos(a),-sin(a),0},
  {0,sin(a),cos(a), 0},
  {0,0,     0,      1}}]]
 return {p[1],p[2]*ca+p[3]*sa,p[3]*ca-p[2]*sa}
end

//y rotation
function rty(p,a)
 if a==0 then return p end
 local ca,sa=cos(a),sin(a)
 --[[
 {{cos(a), 0,sin(a),0},
  {0,      1,0,     0},
  {-sin(a),0,cos(a),0},
  {0,      0,0,     1}}]]
 return {p[1]*ca-p[3]*sa,p[2],p[1]*sa+p[3]*ca}
end

//z rotation
function rtz(p,a)
 if a==0 then return p end
 local ca,sa=cos(a),sin(a)
 --[[
 {{cos(a),-sin(a),0,0},
  {sin(a),cos(a), 0,0},
  {0,     0,      1,0},
  {0,     0,      0,1}}]]
 return {p[1]*ca+p[2]*sa,p[2]*ca-p[1]*sa,p[3]}
end

//transforms object model to match world position,rotation,scale
function trfm(m,c)
 m.cp=cent(m.ps)
 if #m.ps==0 then return end
 if c[1]==0 and c[2]==0 and c[3]==0 and c[4]==1 and c[5]==1 and c[6]==1 and c[7]==0 and c[8]==0 and c[9]==0 then return end
	local xr,yr,zr=c[7]/40,c[8]/40,c[9]/40
	for i,p in ipairs(m.ps) do
		m.ps[i]=trans(rtx(rty(rtz(scale(trans(p,-m.cp[1],-m.cp[2],-m.cp[3]),c[4],c[5],c[6]),zr),yr),xr),c[1]+m.cp[1],c[2]+m.cp[2],c[3]+m.cp[3])
	end
	m.cp=trans(m.cp,c[1],c[2],c[3])
end

//add(models,getmodel(96,8,16,9))
//add(models,getmodel(104,8,15,9))
//add(models,getmodel(112,8,15,9))

add(models,getmodel(56,8,8,6))
add(models,getmodel(64,8,11,13))
add(models,getmodel(72,8,11,10))
add(models,getmodel(80,8,16,19))
add(models,getmodel(88,8,15,22))

--[[add(models,getmodel(0,32,12,12))
add(models,getmodel(8,32,16,11))
add(models,getmodel(16,32,16,8))
add(models,getmodel(24,32,16,6))
add(models,getmodel(32,32,12,4))
add(models,getmodel(40,32,16,9))
add(models,getmodel(48,32,15,9))
add(models,getmodel(56,32,15,9))
add(models,getmodel(64,32,16,6))
add(models,getmodel(72,32,14,10))
add(models,getmodel(80,32,10,5))
]]
for i=1,#models do
	add(copies,{{0,0,0,1,1,1,0,0,0}})
end
mps=models[curmdl].ps
p2d={}
mts=models[curmdl].ts
