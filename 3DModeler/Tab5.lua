--draw
local tris={}
for i=1,60 do
	add(tris,{})
end

local gps={}
for i=1,3 do
	for x=5,15,5 do
		for y=5,15,5 do
		 local np={0,0,0}
			np[i]=x
			np[i%3+1]=y
			add(gps,np)
		end
	end
end

function _draw()
 cls(1)
 //local cview={-1*cos(c.yr)*cos(c.xr),sin(c.xr),-1*sin(c.yr)*cos(c.xr)}
 //local mc=cent(mps)
 
 if tab=="mdl" then
  clip(73,0,127,55)
 else
 	clip(17,0,127,111)
 end
 //3d render
 //axes
 local axes={{min(15,c.x+8)\1,0,0},{0,min(15,c.y+8)\1,0},{0,0,min(15,c.z+8)\1},{0,0,0}}
 for i,p in ipairs(axes) do
 	axes[i]=getspos(p)
 end
 local gps2d={}
 for np in all(gps) do
 	add(gps2d,getspos(np))
 end
 if axes[1][3]<0 then
  for i=1,3 do
 	 if axes[i][3]<0 then
 	 	line(axes[4][1],axes[4][2],axes[i][1],axes[i][2],13)
		 end
		end
 end
 //grid points
 for p in all(gps2d) do
 	if p[3]<0 then
 		pset(p[1],p[2],13)
		end
 end
 
 p2d={}
 local pt={}
 for i,p in ipairs(mps) do
  add(pt,wtc(p)) 
 end
 
 local tclip={}
 local mtssplit={}
 if #mts>0 then
  mtssplit=splittri(copy(mts))
 end
 for t in all(mtssplit) do
  local p1,p2,p3=pt[t[1]],pt[t[2]],pt[t[3]]
  //all points in tri not behind camera
  if p1[3]<0 or p2[3]<0 or p3[3]<0 then
   //back face culling
   nd=bfc({p1,p2,p3})
   if nd<=0 then
    //tri in view dist
    t.z=tridist({p1,p2,p3})
    if t.z<30 then
     local pl,d={0,0,1},tonum(p1[3]>0)+tonum(p2[3]>0)+tonum(p3[3]>0)
     if d>0 then
      //2 points behind camera
	   	 if d==2 then
	   	 	//point 1 in front
	   	 	if p1[3]<=0 then
	   	 	 add(pt,int(pl,p1,p2))
	      	add(pt,int(pl,p1,p3))
	      	add(tclip,{t[1],#pt-1,#pt,c=t.c,h=t.h,z=t.z,tp=t.tp})
       //point 2 in front
       elseif p2[3]<=0 then
        add(pt,int(pl,p2,p1))
 	     	add(pt,int(pl,p2,p3))
 	     	add(tclip,{#pt-1,t[2],#pt,c=t.c,h=t.h,z=t.z,tp=t.tp})
       //point 3 in front
       elseif p3[3]<=0 then
       	add(pt,int(pl,p3,p1))
 	     	add(pt,int(pl,p3,p2))
 	     	add(tclip,{#pt-1,#pt,t[3],c=t.c,h=t.h,z=t.z,tp=t.tp})
       end
      //one point behind camera
 	    elseif d==1 then
       //point 1 behind
 	   	 if p1[3]>0 then
 	   	 	add(pt,int(pl,p2,p1))
 	   	 	add(tclip,{#pt,t[2],t[3],c=t.c,h=t.h,z=t.z,tp=t.tp})
 	   	 	add(pt,int(pl,p3,p1))
 	   	  add(tclip,{#pt,#pt-1,t[3],c=t.c,h=t.h,z=t.z,tp=t.tp})
 	   	 //point 2 behind
 	   	 elseif p2[3]>0 then
 	   	 	add(pt,int(pl,p3,p2))
 	   	 	add(tclip,{t[1],#pt,t[3],c=t.c,h=t.h,z=t.z,tp=t.tp})
 	   	 	add(pt,int(pl,p1,p2))
 	   	 	add(tclip,{t[1],#pt,#pt-1,c=t.c,h=t.h,z=t.z,tp=t.tp})
 	  		 //point 3 behind
 	  		 elseif p3[3]>0 then
 	   	 	add(pt,int(pl,p1,p3))
 	   	 	add(tclip,{t[1],t[2],#pt,c=t.c,h=t.h,z=t.z,tp=t.tp})
 	   	 	add(pt,int(pl,p2,p3))
 	   	 	add(tclip,{#pt-1,t[2],#pt,c=t.c,h=t.h,z=t.z,tp=t.tp})
 	   	 end
 	   	end
 	   //tri not behind camera
 	 		else add(tclip,t) end
    end
   end
  end
 end
 
 //points 2d conversion
 for p in all(pt) do
 	add(p2d,str(cts(p)))
 end
   
 //assemble 2d tris and sort
 for t in all(tclip) do
  local t2d={z=t.z,c=t.c,h=t.h,tp=t.tp}
  for i=1,3 do
  	add(t2d,p2d[t[i]])
  end
  add(tris[t2d.z*2%61\1+1],t2d)
 end
  
 //filled tris 
 for i=60,1,-1 do
  if #tris[i]>0 then
   for t in all(tris[i]) do
    if gstyl>1 then
     trifill(t,cols(t.c,t.h),t.z)
  	 end
  	 if gstyl!=2 then
  	  wframe(t,cols(t.c,t.h+tonum(gstyl==3)))
  	 end
  	end
  end
 end
 
 for i=1,60 do
 	if #tris[i]>0 then
 		tris[i]={}
		end
 end
 
 //points
 if tab=="mdl" then
  for i,sp in ipairs(p2d) do
  	if mps[i]!=nil then pset(sp[1],sp[2],7-mps[i].h*5) circ(sp[1],sp[2],1,0) end
  end
  for i in all(sel) do
   sp=p2d[i]
  	if mps[i]!=nil then pset(sp[1],sp[2],8) end
  end
 elseif curcop>0 then
  local curm=copy(models[curmdl])
  if #curm.ps>0 then
   curm.cp=cent(curm.ps)
   trfm(curm,copies[curmdl][curcop])
 	 local p=str(cts(wtc(curm.cp)))
 	 if p!=nil then
 	 	pset(p[1],p[2],7) circ(p[1],p[2],1,0)
		 end
		end
 end
 
 local bc=13
 if view==4 then bc=6 end
 if tab=="mdl" then
  rect(73,0,127,54,bc)
 else 
 	rect(17,0,127,110,bc)
 end
 clip()
 
 if tab=="mdl" then
  //ui
  //views
  local t=0
  for i=0,56,56 do
  	for j=0,56,56 do
  	 t+=1
  	 if t<4 then
  	  clip(17+i,56-j,55,55)
  	  local scale=50/8/zoom[t]
  	  local vi=vxy(0,t,true)
  	  camera(voffs[vi[1]]*scale,-voffs[vi[2]]*scale)
  		 //axes
  		 for x=0,15 do
  		 	pset(19+i+x*scale,108-j,13)
  		 	pset(19+i,108-j-x*scale,13)
     end
     //tris
     for tri in all(mts) do
      for k=1,#tri do
      	local p=mps[tri[k]]
      	local np=mps[tri[k%#tri+1]]
      	line(19+i+p[vi[1]]*scale,108-j-p[vi[2]]*scale,19+i+np[vi[1]]*scale,108-j-np[vi[2]]*scale,cols(tri.c,tri.h))
      end
     end
     //points
  		 for p in all(mps) do
      circfill(19+i+p[vi[1]]*scale,108-j-p[vi[2]]*scale,1/zoom[t],7-p.h*5)
     end
     //selected
     for k in all(sel) do
     	local p=mps[k]
      circfill(19+i+p[vi[1]]*scale,108-j-p[vi[2]]*scale,1/zoom[t],8)
     end
  		 local bc=13
     if view==t then bc=6 end
     camera()
  		 rect(17+i,56-j,71+i,110-j,bc)
	 	  clip()
	 	 end
	 	end
  end
  
  //axis labels
  if view!=1 then
   print("x",67,104,7)
   print("y",19,58,7)
  end
  if view!=2 then
   print("x",19,2,7)
   print("z",67,48,7)
  end
  if view!=3 then
   print("y",75,58,7)
   print("z",123,104,7)
  end
 end
 
 //buttons 
 rectfill(0,112,127,127,8)
 for b in all(tools) do
		b.draw(b)
	end
	print(tool,16,121,7)
	if tool=="save" then
		print("name: "..mname.."\nenter:save",20,9,1)
		print("name: "..mname.."\nenter:save",18,7,1)
		print("name: "..mname.."\nenter:save",19,8,7)
	end
	
	//left widget
	rectfill(0,0,15,111,8)
	local msps=mps
	local msts=mts
	if tab=="arr" then
	 msps=models[curmdl].ps
	 msts=models[curmdl].ts
	end
	//points
	for i,p in ipairs(msps) do
	 if tab=="mdl" and pinb(m.x,m.y,{0,0+i*2-2,5,1+i*2-2}) then 
	  msps[i].h=1
	  if m.lc then if insel(i) then del(sel,i) else add(sel,i) end
	  elseif m.rc then delp(i) deli(msps,i) sel={} end
	 else msps[i].h=0  end
		for j,v in ipairs(p) do
			rect(j*2-2,i*2-2,j*2-1,i*2-1,v)
		end
	end
	//tris
	for i,t in ipairs(msts) do
	 if tab=="mdl" and pinb(m.x,m.y,{6,i*2-2,#t*2+7,i*2-1}) then 
	  msts[i].h=1 
	  for p in all(t) do 
	   if m.lc then if insel(p) then del(sel,p) else add(sel,p) end end
	  end
	  if m.rc and (tool=="none" or tool=="face") then deli(msts,i) sel={} end 
	 else msts[i].h=0 end
	 rect(6,i*2-2,7,i*2-1,t.c)
		for j,p in ipairs(t) do
			rect(j*2+6,i*2-2,j*2+7,i*2-1,p%16-1)
		end
		if #t==3 then
			rect(14,i*2-2,15,i*2-1,t[3]%16-1)
		end
	end
	clip()
	
	//palette
	for c=0,15 do
	 local b={1+c%4+c%4*2,115+c\4+c\4*2,3+c%4+c%4*2,117+c\4+c\4*2,c}
	 if m.lc and pinb(m.x,m.y,b) then col=c end
		rectfill(unpack(b))
	end
 if tab=="mdl" then pset(43,116,col) end
	
	//model select
	for i,b in ipairs(mdlbtn) do
	 rect(b[1],b[4]+1,b[3],b[4]+1,cols(b[5],1))
	 rectfill(unpack(b))
	 if i==curmdl then
	  b[5]=1
		 rect(unpack(b))
	 end
	end
	
	//copy select
	if tab=="arr" then
	 for i,b in ipairs(cpybtn) do
	  rect(b[1],b[4]+1,b[3],b[4]+1,cols(b[5],1))
	  rectfill(unpack(b))
	  if i==curcop then
	   b[5]=1
	 	 rect(unpack(b))
	  end
	 end
	end
	
	//model/arranger tab
	rectfill(106,112,117,116,2+tonum(tab=="mdl")*6)
	pal(7,7-tonum(tab!="mdl"))
	spr(13,106,112,1.5,1)
	rectfill(117,112,128,116,2+tonum(tab=="arr")*6)
	pal(7,7-tonum(tab!="arr"))
	spr(16,117,112,1.5,1)
	pal()
	if m.lc and tab=="arr" and pinb(m.x,m.y,{106,112,117,117}) then
		tab="mdl"
		mps=models[curmdl].ps
  p2d={}
  mts=models[curmdl].ts
  tool="none"
	end
	if m.lc and tab=="mdl" and pinb(m.x,m.y,{117,112,128,117}) then
		tab="arr"
		models[curmdl].ps=mps
		models[curmdl].ts=mts
		updarrm()
		sel={}
		tool="none"
		for b in all(tools) do b.press=false end
	end
	
	//top layer text
	for t in all(text) do
		print(unpack(t))
	end
	
	//cpu %
	print((stat(1)\.001/10).."%",107,121,7)  
	 
	//dialogue box
	if dial!="" then
	 rectfill(62-#dial*2,56,64+#dial*2,70,8)
		print(dial.."\ny ❎/n 🅾️",64-#dial*2,58,7)
	end
	 
	//mouse
 spr(1,m.x,m.y)
 if tool=="color" then
 	pset(m.x+1,m.y+1,col)
 end
end
