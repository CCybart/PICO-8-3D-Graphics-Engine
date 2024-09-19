--raster

//world to camera space
function wtc(p)
 local cosx,sinx,cosy,siny,x,y,z,cx,cy,cz=ccx,csx,-ccy,-csy,p[1],p[2],p[3],c.x,c.y,c.z
 return { 
  x*cosy-z*siny-cx*cosy+cz*siny,
  x*sinx*siny+y*cosx+z*sinx*cosy-cx*sinx*siny-cy*cosx-cz*sinx*cosy,
  x*siny*cosx-y*sinx+z*cosx*cosy-cx*siny*cosx+cy*sinx-cz*cosy*cosx}
end

//camera to screen space, screen space to raster space
function ctr(p)
 local z=-p[3] or 0.01
 //if -p[3]<=0 then return nil end
 return {(1-p[1]/z)*64,(p[2]/z+1)*64,z}
end

//screen to ndc space
--[[function ndc(p)
 if p==nil then return nil end
 local r,l,t,b=1,-1,1,-1
 local x,y=2*p[1]/(r-l)-(r+l)/(r-l),2*p[2]/(r-l)-(r+l)/(r-l)
 //if x<-1 or x>1 or y<-1 or y>1 then return nil else 
 return {x,y,p[3]} //end
end]]

//ndc to raster space
//function str(p)
 //if p==nil then return "nil" end
// return {(1-p[1])*64,(p[2]+1)*64,p[3]}
//end

--[[//edge function
function edge(p,v0,v1)
	return (p[1]-v0[1])*(v1[2]-v0[2])-(p[2]-v0[2])*(v1[1]-v0[1])
end

//returns if point in triangle
function pintri(p,tri)
	for i=1,#tri do
		if edge(p,tri[i],tri[i%#tri+1])<0 then return false end
	end
	return true
end

//bounding box
function bounds(tri)
	local b={128,128,-1,-1}
	for v in all(tri) do
	 b[1]=min(b[1],v[1])
	 b[2]=min(b[2],v[2])
	 b[3]=max(b[3],v[1])
	 b[4]=max(b[4],v[2])
	end
	return b
end]]

//gets screen pos of point in 3d space
--[[function getspos(p)
	return str(ndc(cts(wtc(p))))
end]]

//returns raster coordinates of tri
--[[function rasterize(tri)
	local rtri={}
	for v in all(tri) do
	 rv=getspos(v)
	 if rv==nil then return nil end
		add(rtri,rv)
	end
	return rtri
end]]

//finds intersection of points and plane
function int(p1,p2)
 local x1,y1,z1=p1[1],p1[2],p1[3]
 local t=-z1/(p2[3]-z1)
	return {x1+t*(p2[1]-x1),y1+t*(p2[2]-y1),-.1}
end

function cliptri(d,t,tt,pt,tclip)
	local i=0
	if d==2 then
		if tt[1][3]<-.05 then i=1
		elseif tt[2][3]<-.05 then i=2
		else i=3 end
		j=i%3+1
		k=(i+1)%3+1
		add(pt,int(tt[i],tt[j]))
	 add(pt,int(tt[i],tt[k]))
	 add(tclip,{t[i],#pt-1,#pt,c=t.c,z=t.z})
	elseif d==1 then
		if tt[1][3]>=-.05 then i=1
		elseif tt[2][3]>=-.05 then i=2
		else i=3 end
		j=i%3+1
		k=(i+1)%3+1
		add(pt,int(tt[j],tt[i]))
	 add(tclip,{t[j],t[k],#pt,c=t.c,z=t.z})
		add(pt,int(tt[k],tt[i]))
	 add(tclip,{t[k],#pt,#pt-1,c=t.c,z=t.z})
	end
end

function spr3d(p,co)
	local sw,sh,w,h=co[3],co[4],co[6] or 1,co[7] or 1
	sspr(co[1],co[2],sw,sh,p[1]-sw*w*16/p[3],p[2]-sh*h*16/p[3],sw*w*32/p[3],sh*h*32/p[3],co[8],co[9])
end

//wireframe
function wframe(t,c)
	local p1,p2,p3=t[1],t[2],t[3]
 line(p1[1],p1[2],p2[1],p2[2],c)
 line(p3[1],p3[2],p2[1],p2[2],c)
 line(p1[1],p1[2],p3[1],p3[2],c)
end

//calcs rough distance from point to tri
function tridist(t) 
 p1,p2,p3=t[1],t[2],t[3]
	return sqrt(((p1[1]+p2[1]+p3[1])/3)^2+((p1[2]+p2[2]+p3[2])/3)^2+((p1[3]+p2[3]+p3[3])/3)^2)
end

function trifill2(p,c)
 if (c!=nil) color(c)
 --find top & bottom of poly
 local miny,maxy,mini=p[1][2],p[1][2],1
 for i=2,#p do
  local y=p[i][2]
  if (y<miny) mini,miny=i,y
  if (y>maxy) maxy=y
 end
 
 --data for left & right edges:
 local li,lj,ri,rj=mini,mini,mini,mini
 local ly,ry=miny-1,miny-1
 local lx,ldx,rx,rdx

 --step through scanlines.
 for y=ceil(miny),ceil(maxy)-1 do
  --maybe update to next vert
  while ly<y do
   li,lj=lj,lj+1
   if (lj>#p) lj=1
   local v0,v1=p[li],p[lj]
   ly=ceil(max(v0[2],v1[2]))-1
   lx=v0[1]
   local dy=v1[2]-v0[2]
   ldx=(v1[1]-v0[1])/dy
   --sub-pixel correction
   local fy=ceil(v0[2])-v0[2]
   lx+=fy*ldx
  end   
  while ry<y do
   ri,rj=rj,rj-1
   if (rj<1) rj=#p
   local v0,v1=p[ri],p[rj]
   ry=ceil(max(v0[2],v1[2]))-1
   rx=v0[1]
   local dy=v1[2]-v0[2]
   rdx=(v1[1]-v0[1])/dy
   --sub-pixel correction
   local fy=ceil(v0[2])-v0[2]
   rx+=fy*rdx
  end
  --draw from left to right
  local x0=ceil(lx)
  local x1=ceil(rx)-1
  if x0<=x1 then
   line(x0,y,x1,y)
  end
  lx+=ldx
  rx+=rdx
 end
end


--trifill
function trifill(t,c)
 local x0,y0,x1,y1,x2,y2=t[1][1],t[1][2],t[2][1],t[2][2],t[3][1],t[3][2]
 color(c)
 if(y1<y0)x0,x1,y0,y1=x1,x0,y1,y0
 if(y2<y0)x0,x2,y0,y2=x2,x0,y2,y0
 if(y2<y1)x1,x2,y1,y2=x2,x1,y2,y1
 if max(x2,max(x1,x0))-min(x2,min(x1,x0)) > y2-y0 then
  colu=x0+(x2-x0)/(y2-y0)*(y1-y0)
  p01_trapeze_h(x0,x0,x1,colu,y0,y1)
  p01_trapeze_h(x1,colu,x2,x2,y1,y2)
 else
  if(x1<x0)x0,x1,y0,y1=x1,x0,y1,y0
  if(x2<x0)x0,x2,y0,y2=x2,x0,y2,y0
  if(x2<x1)x1,x2,y1,y2=x2,x1,y2,y1
  colu=y0+(y2-y0)/(x2-x0)*(x1-x0)
  p01_trapeze_w(y0,y0,y1,colu,x0,x1)
  p01_trapeze_w(y1,colu,y2,y2,x1,x2)
 end
 //wframe(t,1)
end
function p01_trapeze_h(l,r,lt,rt,y0,y1)
 lt,rt=(lt-l)/(y1-y0),(rt-r)/(y1-y0)
 if(y0<0)l,r,y0=l-y0*lt,r-y0*rt,0
 y1=min(y1,128)
 for y0=y0,y1 do
  rectfill(l,y0,r,y0)
  l+=lt
  r+=rt
 end
end
function p01_trapeze_w(t,b,tt,bt,x0,x1)
 tt,bt=(tt-t)/(x1-x0),(bt-b)/(x1-x0)
 if(x0<0)t,b,x0=t-x0*tt,b-x0*bt,0
 x1=min(x1,128)
 for x0=x0,x1 do
  rectfill(x0,t,x0,b)
  t+=tt
  b+=bt
 end
end

//tri w texture
function tritext(t,s)
 local p1,p2,p3,s1,s2,s3=t[1],t[2],t[3],s[1],s[2],s[3]
	if p2[2]<p1[2] then p1,p2,s1,s2=p2,p1,s2,s1 end
	if p3[2]<p1[2] then p1,p3,s1,s3=p3,p1,s3,s1 end
	if p3[2]<p2[2] then p2,p3,s2,s3=p3,p2,s3,s2 end
 local ykb,ykc,xkb,xkc,sykb,sykc,sxkb,sxkc=p2[2]-p1[2],p3[2]-p1[2],p2[1]-p1[1],p3[1]-p1[1],s2[2]-s1[2],s3[2]-s1[2],s2[1]-s1[1],s3[1]-s1[1]
 
 y1,y2,y3=mid(0,p1[2],127),mid(0,p2[2],127),mid(0,p3[2],127)
 for y=y1,y2 do
  local nb,nc=(y-p1[2])/ykb,(y-p1[2])/ykc
  local x1,x2=p1[1]+nb*xkb,p1[1]+nc*xkc
  local d = abs(x2-x1)
  local sx0,sx1,sy0,sy1=s1[1]+nb*sxkb,s1[1]+nc*sxkc,s1[2]+nb*sykb,s1[2]+nc*sykc
  tline(x1,y,x2,y,sx0,sy0,(sx1-sx0)/d,(sy1-sy0)/d)
 end
 
 ykb,xkb,sykb,sxkb = p3[2]-p2[2],p3[1]-p2[1],s3[2]-s2[2],s3[1]-s2[1]
 for y=y2,y3 do
  local nb,nc=(y-p2[2])/ykb,(y-p1[2])/ykc
  local x1,x2=p2[1]+nb*xkb,p1[1]+nc*xkc
  local d = abs(x2-x1)
  local sx0,sx1,sy0,sy1=s2[1]+nb*sxkb,s1[1]+nc*sxkc,s2[2]+nb*sykb,s1[2]+nc*sykc
  tline(x1,y,x2,y,sx0,sy0,(sx1-sx0)/d,(sy1-sy0)/d)
 end
end
