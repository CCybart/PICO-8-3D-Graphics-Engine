srand(12345)
poke(0x5f2d,5)
local c={x=0,y=5,z=7,xr=.5,yr=.26}
local ccx,csx,ccy,csy
local cpos={}
local objs={}
local mesh={}
local colst={}
local cpu={}
local counter=0

//cols setup
for i=0,3 do
 for j=0,3 do
 	add(colst,sget(j,i))
 end
end

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

//distance function
--[[function dist(p1,p2)
	return sqrt((p2[1]-p1[1])^2+(p2[2]-p1[2])^2+(p2[3]-p1[3])^2)
end]]

//accurate dist
--[[function dist(p1,p2)
  local nsd=(p1[1]-p2[1])^2/4096+(p1[2]-p2[2])^2/4096+(p1[3]-p2[3])^2/4096
  if(nsd<0) return 32767.99999
  return sqrt(nsd)*64
end]]

//fetches model coordinates from spritesheet
function getmodel(a,b,lp,lt)
 local ps={}
 for tb=b,b+lp-1 do
 	local p={}
 	for i=0,2 do
 		add(p,sget(a+i,tb))
		end
		add(ps,p)
		tb+=1
 end
      
 a+=3
 local tris={}
	for i=1,lt do
		local tri,j,pi={},1,0
		tri.c=sget(a,b)
		while j<5 and pi!=sget(a+j,b)+1 do
			pi=sget(a+j,b)+1
			add(tri,pi)
			j+=1
		end
		b+=1
		add(tris,tri)
	end
	
 tris=splittri(tris)
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
 			local m,n=#tri\2+1,{}
 			for i=2,#tri do
 			 add(n,tri[i])
 		  if i==m or i==#tri then
 		  	add(n,tri[1])
 	    n.c,n.z=tri.c,tri.z
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
function addmdl(m1,m2,t,s,r) 
 local t,s,r=t or {},s or {},r or {}
 local nm=copy(m1)
 local change={}
 local ldup=0
 cp=cent(m2.ps)
 for i=1,#m2.ps do
  m2.ps[i]=trans(m2.ps[i],-cp[1],-cp[2],-cp[3])
  if #s>0 then
  	m2.ps[i]=scale(m2.ps[i],s[1],s[2],s[3])
  end
  if #r>0 then
   m2.ps[i]=rtx(rty(rtz(m2.ps[i],cos(r[3]),sin(r[3])),cos(r[2]),sin(r[2])),cos(r[1]),sin(r[1]))
  end
  if #t>0 then
  	m2.ps[i]=trans(m2.ps[i],t[1],t[2],t[3])
  end
  m2.ps[i]=trans(m2.ps[i],cp[1],cp[2],cp[3])
 	p1=m2.ps[i]
 	
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
 return nm
end

//shading
function cols(c,d)
 if (d==0) return c
 if (d==1) return colst[c+1]
	return cols(colst[c+1],d-1)
end

//finds corners of bounding box around set of points
function mnmx(s)
	if #s==1 then return s[1] end
 local mn=copy(s[1])
 local mx=copy(s[1])
 for i=2,#s do
 	mn[1]=min(mn[1],s[i][1])
 	mn[2]=min(mn[2],s[i][2])
 	mn[3]=min(mn[3],s[i][3])
 	mx[1]=max(mx[1],s[i][1])
 	mx[2]=max(mx[2],s[i][2])
 	mx[3]=max(mx[3],s[i][3])
 end
 return mn,mx
end

//returns center of a set of points
function cent(s)
 local mn,mx=mnmx(s)
 local c={(mx[1]+mn[1])/2,(mx[2]+mn[2])/2,(mx[3]+mn[3])/2}
	return c,mn,mx
end

//returns rough size of bounding box around points
function size(s)
	local c,mn,mx=cent(s)
	return sqrt((mx[1]-c[1])^2+(mx[2]-c[2])^2+(mx[3]-c[3])^2)
end

//returns the center of a triangle
--[[function tcent(t)
 local p1,p2,p3=t[1],t[2],t[3]
	return {(p1[1]+p2[1]+p3[1])/3,(p1[2]+p2[2]+p3[2])/3,(p1[3]+p2[3]+p3[3])/3}
end]]

--[[function q_rsqrt(n)
 g=2/n
 for i=1,2 do
	 g=g*(1.5-(n/2)*g^2)
	end
	return g
end]]

//returns the normal vector
--[[function normal(tri)
 local v1,v2,v3,u,v=tri[1],tri[2],tri[3],{},{}
 for i=1,3 do
  add(u,v2[i]-v1[i])
  add(v,v3[i]-v1[i])
 end
 local nv={
  (u[2]*v[3]-u[3]*v[2]),
  (u[3]*v[1]-u[1]*v[3]),
  (u[1]*v[2]-u[2]*v[1])}
 local m=q_rsqrt(nv[1]^2+nv[2]^2+nv[3]^2)
 for i=1,#nv do
 	nv[i]*=m
 end
 return nv
end]]

//translation
function trans(p,x,y,z)
 if (x==0 and y==0 and z==0) return p
	return {p[1]+x,p[2]+y,p[3]+z}
end

//scale
function scale(p,x,y,z)
 if (x==1 and y==1 and z==1) return p
	return {p[1]*x,p[2]*y,p[3]*z}
end

//x rotation
function rtx(p,ca,sa)
 --[[
 {{1,0,     0,      0},
  {0,cos(a),-sin(a),0},
  {0,sin(a),cos(a), 0},
  {0,0,     0,      1}}]]
 return {p[1],p[2]*ca+p[3]*sa,p[3]*ca-p[2]*sa}
end

//y rotation
function rty(p,ca,sa)
 --[[
 {{cos(a), 0,sin(a),0},
  {0,      1,0,     0},
  {-sin(a),0,cos(a),0},
  {0,      0,0,     1}}]]
 return {p[1]*ca-p[3]*sa,p[2],p[1]*sa+p[3]*ca}
end

//z rotation
function rtz(p,ca,sa)
 --[[
 {{cos(a),-sin(a),0,0},
  {sin(a),cos(a), 0,0},
  {0,     0,      1,0},
  {0,     0,      0,1}}]]
 return {p[1]*ca+p[2]*sa,p[2]*ca-p[1]*sa,p[3]}
end

//transforms object model to match world position,rotation,scale
function trfm(m,o)
 local x,y,z,xs,ys,zs,xr,yr,zr=o.px-o.x,o.py-o.y,o.pz-o.z,o.xs/o.pxs,o.ys/o.pys,o.zs/o.pzs,o.pxr-o.xr,o.pyr-o.yr,o.pzr-o.zr
 if x==0 and y==0 and z==0 and xs==1 and ys==1 and zs==1 and xr==0 and yr==0 and zr==0 then return end
	local cax,sax,cay,say,caz,saz=cos(-xr),sin(-xr),cos(-yr),sin(-yr),cos(-zr),sin(-zr)
	for i,p in ipairs(m.ps) do
		m.ps[i]=trans(rtx(rty(rtz(scale(trans(p,-m.cp[1],-m.cp[2],-m.cp[3]),xs,ys,zs),caz,saz),cay,say),cax,sax),-x+m.cp[1],-y+m.cp[2],-z+m.cp[3])
	end
	m.cp=trans(m.cp,-x,-y,-z)
 if xs!=1 or ys!=1 or zs!=1 then
  o.size=size(m.ps)
 end
 for i=1,#o.cos do
  co=o.cos[i]
 	co[5]=trans(co[5],x,y,z)
 end
end

function imap(x,y,l,w,sx,sy,sz)
 local sx,sy,sz=sx or 1,sy or 1,sz or 1
	for i=0,15,2 do
		for j=0,7 do
		 if sget(x+i,y+j)>0 then
		  local mod=sget(x+i+1,y+j)
		  add(objs,iobj({i/2*l*sx,0,j*w*sz,sx,sy,sz,0,.25*(mod&3),0},sget(x+i,y+j)))
		 end
		end
	end
	mesh={}
end
