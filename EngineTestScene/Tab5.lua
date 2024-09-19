--draw
local tris={}
for i=1,60 do
	add(tris,{})
end

function _draw()
 cls(12)
 //rectfill(0,64,128,128,4)
 local tn=0
 local tntot=0
 
 for o in all(objs) do
 	o.draw(o)
 	local mps,mts,mcos,size,p2d,pt,pls,bhnd,cp=o.model.ps,o.model.ts,o.cos,o.size,{},{},{{0.7071,0,0.7071},{-0.7071,0,0.7071},{0,0.7071,0.7071},{0,-0.7071,0.7071}},false,wtc(o.model.cp)
  tntot+=#mts
  //not behind camera
  if cp[3]<size then
   for pl in all(pls) do
    if dp(pl,cp)>=size then bhnd=true break end
   end
   //not behind clipping planes
   if not bhnd then
    //not out of view dist
    if -cp[3]<30 then
     for p in all(mps) do
      add(pt,wtc(p))
     end
     
     local tclip={}
     //clip points behind camera
     for t in all(mts) do
      local p1,p2,p3=pt[t[1]],pt[t[2]],pt[t[3]]
      //all points in tri not behind camera
      if p1[3]<0 or p2[3]<0 or p3[3]<0 then
       //back face culling
       if bfc({p1,p2,p3})<0 then
        //tri in view dist
        t.z=tridist({p1,p2,p3})
        if t.z<30 then
     	   local d=tonum(p1[3]>=-.05)+tonum(p2[3]>=-.05)+tonum(p3[3]>=-.05)
         if d>0 then
          cliptri(d,t,{p1,p2,p3},pt,tclip)
	  	 	   //tri not behind camera
	  	 	 		else add(tclip,t) end
        end
       end
      end
     end
       
     //points 2d conversion
     for p in all(pt) do
     	add(p2d,ctr(p))
     end
          
     //assemble 2d tris and sort
     for t in all(tclip) do
      add(tris[t.z\.5+1],{typ="t",c=t.c,p2d[t[1]],p2d[t[2]],p2d[t[3]]})
     end
     tn+=#tclip
     
     for i=1,#mcos do
      co=mcos[i]
      copos=ctr(wtc(co[5]))
      add(tris[copos[3]\.5+1],{typ="co",copos,co})
     end
    end
   end
  end
 end
  
 local fp=false 
 //draw tris
 for i=60,1,-1 do
  if i==32 or i==60 then fp=true fillp(0b1000001010000010) end
  if i==22 or i==46 then fp=false fillp() end
  if #tris[i]>0 then
   for t in all(tris[i]) do
    if t.typ=="t" then
     s=cols(t.c,i\32)
   	 if fp then s=tonum(tostr(cols(t.c,i\24)*16+s,0x1)) end
     //tritext(t,{{0,0},{2,0},{0,2}})
 	   trifill(t,s)
 	   //wframe(t,s)
 	  else
 	  	spr3d(unpack(t))
    end
 	 end
 	 tris[i]={}
 	end
 end
  
 //add(cpu,stat(1))
 //if #cpu>120 then deli(cpu,1) end
 //local cpuav=0
 //for i in all(cpu) do
 // cpuav+=i
 //end
 //cpuav/=#cpu
 //cpuav=cpuav\.0001/100
 //print(cpuav.."% cpu average",7)
 print(stat(1)\.0001/(100).."% cpu",7)
 print(tn.."/"..tntot.." ⬆️")
 print(counter)
 counter=0
end
