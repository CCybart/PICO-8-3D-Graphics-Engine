--update
--[[local dv={0}
for i=2,#objs do
 local dx,dy,dz=rnd()*2-1,rnd()*2-1,rnd()*2-1
 local s=sqrt(dx^2+dy^2+dz^2)
 dx/=s
 dy/=s
 dz/=s
 add(dv,{dx/2,dy/2,dz/2})
end
for i=2,#objs-1 do
	objs[i].x+=rnd(8)-4
	objs[i].y+=rnd(8)
	objs[i].z+=rnd(8)-4
	objs[i].xr=rnd()
	objs[i].yr=rnd()
	objs[i].zr=rnd()
end]]

function _update() 
 c.yr=(c.yr+mid(-63,stat(38),63)/1440)%1
 c.xr=mid(.25,(c.xr-mid(-63,stat(39),63)/2880)%1,.75)
 ccx,csx,ccy,csy=cos(c.xr),sin(c.xr),cos(c.yr),sin(c.yr)

 if btn(⬆️) then 
  c.x-=csy/4
  c.z-=ccy/4
 end
 if btn(⬇️) then 
  c.x+=csy/4
  c.z+=ccy/4
 end
 if btn(⬅️) then 
  c.x+=sin(c.yr+.25)/4
  c.z+=cos(c.yr+.25)/4
 end
 if btn(➡️) then 
  c.x+=sin(c.yr-.25)/4
  c.z+=cos(c.yr-.25)/4
 end
 if btn(❎) then
 	c.y+=.2
 end
 if btn(🅾️) then
 	c.y-=.2
 end
  
 --[[for i=2,#objs do
  objs[i].xr+=.01*dv[i][1]
  objs[i].yr+=.01*dv[i][2]
  objs[i].zr+=.01*dv[i][3]
  if objs[i].x>9.5 or objs[i].x<-9 then dv[i][1]*=-1 end
  if objs[i].y>18 or objs[i].y<0 then dv[i][2]*=-1 end
  if objs[i].z>9.5 or objs[i].z<-9 then dv[i][3]*=-1 end
  objs[i].x+=dv[i][1]/2
  objs[i].y+=dv[i][2]/2
  objs[i].z+=dv[i][3]/2
 end]]
end
