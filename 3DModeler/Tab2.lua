--raster

//world to camera space
function wtc(p)
 local yr=-c.yr-.25
 local cosx,sinx,cosy,siny,x,y,z,cx,cy,cz=cos(c.xr),sin(c.xr),cos(yr),sin(yr),p[1],p[2],p[3],c.x,c.y,c.z
 return { 
  x*cosy-z*siny-cx*cosy+cz*siny,
  x*sinx*siny+y*cosx+z*sinx*cosy-cx*sinx*siny-cy*cosx-cz*sinx*cosy,
  x*siny*cosx-y*sinx+z*cosx*cosy-cx*siny*cosx+cy*sinx-cz*cosy*cosx}
end

//camera to screen space
function cts(p)
 //if p[3]>=0 then return nil else
 return {p[1]/(-p[3]),p[2]/(-p[3]),p[3]} //end
end

//screen to ndc space
--[[function ndc(p)
 if p==nil then return nil else
 local r,l,t,b=1,-1,1,-1
 local x,y=2*p[1]/(r-l)-(r+l)/(r-l),2*p[2]/(r-l)-(r+l)/(r-l)
 if x<-1 or x>1 or y<-1 or y>1 then return nil
 else return {x,y,p[3]} end end
end]]

//ndc to raster space
function str(p)
 //if p==nil then return "nil" else
 x,y=0,72
 if tab=="arr" then x,y,l=28,45,200 end
 return {(1-p[1])/2*200-x,(p[2]+1)/2*200-y,p[3]} //end
end

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
function getspos(p)
	return str(cts(wtc(p)))
end

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
function int(pl,p1,p2)
 local t=-p1[3]/dp(pl,{p2[1]-p1[1],p2[2]-p1[2],p2[3]-p1[3]})
	return {p1[1]+t*(p2[1]-p1[1]),p1[2]+t*(p2[2]-p1[2]),-.1}
end

//wireframe
function wframe(t,c)
	for i=1,#t do
 	p1,p2=t[i],t[i%#t+1]
 	line(p1[1],p1[2],p2[1],p2[2],c)
 end
end

//calcs rough distance from point to tri
function tridist(t) 
 p1,p2,p3,p4=t[1],t[2],t[3],tcent(t)
	return sqrt(((p1[1]+p2[1]+p3[1]+p4[1])/4)^2+((p1[2]+p2[2]+p3[2]+p4[2])/4)^2+((p1[3]+p2[3]+p3[3]+p4[3])/4)^2)
end

--trifill
function trifill(t,c,z)
 local x0,y0,x1,y1,x2,y2,s=t[1][1],t[1][2],t[2][1],t[2][2],t[3][1],t[3][2],c
 if t.tp then wframe(t,c) return else fillp(0b1000001010000010) s=tonum(tostr(cols(c,z\24)*16+cols(c,z\32),0x1)) end 
 color(s)
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
 if stat(1)<.75 then wframe(t,s) end
 fillp()
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
