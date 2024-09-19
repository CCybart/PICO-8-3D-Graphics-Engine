--update

c.yr=atan2(.1-c.x,.1-c.z)%1
c.xr=atan2(.1/cos(atan2(.1,.1))-c.x/cos(atan2(c.x,c.z)),.1-c.y)%1

function _update() 
 m.px,m.py=m.x,m.y
	m.x,m.y=stat(32),stat(33)
	if stat(34)==0 then if click==1 then m.lc=true else m.lc=false end if click==2 then m.rc=true else m.rc=false end end click=stat(34)
	
	//not paused to confirm smth
	if dial=="" then
	 //3d control
	 if view==4 then
   if btn(⬆️) then 
    c.x+=cos(c.yr)/4
    c.z+=sin(c.yr)/4
   end
   if btn(⬇️) then 
    c.x-=cos(c.yr)/4
    c.z-=sin(c.yr)/4
   end
   if btn(⬅️) then 
    c.x+=cos(c.yr+.25)/4
    c.z+=sin(c.yr+.25)/4
   end
   if btn(➡️) then 
    c.x+=cos(c.yr-.25)/4
    c.z+=sin(c.yr-.25)/4
   end
   if btn(❎) then
   	c.y+=.2
   end
   if btn(🅾️) then
   	c.y-=.2
   end
  end
	
	 //text and tool buttons update
	 text={}
	 for b in all(tools) do
	 	b.up(b)
	 end
	
	 //update model btns
	 for i,b in ipairs(mdlbtn) do
   b[5]=cols(b.c,tonum(i!=curmdl))
 	 if pinb(m.x,m.y,b) then
 	  if m.lc or m.rc then
 	   if tab=="mdl" then
 	    models[curmdl].ps=mps
 	    models[curmdl].ts=mts
 	   end
 	   curcop=1
 	   curmdl=i
 	 	 if tab=="mdl" then
 	 	  mps=models[curmdl].ps
      p2d={}
      mts=models[curmdl].ts
     else
     	updarrm()
     end
    end
    if m.rc and #models>1 then
    	dial="delete model?"
    end
		 end
  end
  
  //update copy btns
	 for i,b in ipairs(cpybtn) do
   b[5]=cols(b.c,tonum(i!=curcop))
 	 if pinb(m.x,m.y,b) then
 	  if m.lc or m.rc then
 	   if curcop==i then
 	   	curcop=-1
     else
     	curcop=i
     end
     updarrm()
    end
    if m.rc and #copies[curmdl]>1 then
    	deli(copies[curmdl],i)
    	curcop=1
    	updarrm()
    end
		 end
  end
	
	 //toggle views
	 pvpos={unpack(vpos)}
	 if pinb(m.x,m.y,{17,56,71,110}) then
	 	view=1 vpos={m.x-19,-m.y+108}
	 elseif pinb(m.x,m.y,{17,0,71,54}) then
	 	view=2 vpos={m.x-19,-m.y+52}
	 elseif pinb(m.x,m.y,{73,56,127,110}) then
	 	view=3 vpos={m.x-75,-m.y+108}
	 else
	 	view=0 vpos={0,0} vposo={0,0}
	 end
	 if view>0 then
	  local vi=vxy(0,view,true)
	  local scale=50/8/zoom[view]
	  for i=1,2 do
	  	vpos[i]=mid(0,vpos[i]+scale/2,50)
	  	vpos[i]\=scale
	  	vposo[i]=mid(0,vpos[i]+voffs[vi[i]],15)
	  end
	 end
 	
 	//3d view
 	if (tab=="mdl" and pinb(m.x,m.y,{73,0,127,54})) or (tab=="arr" and pinb(m.x,m.y,{17,0,127,110})) then
 		view=4 vpos={0,0}
 		--[[if stat(36)!=0 then
 		 local d=dist({c.x,c.y,c.z},cent(mps))
 		 if (d>4 or stat(36)<0) and (d<36 or stat(36)>0) then
 		  c.x+=cos(c.yr)*sgn(stat(36))
 		  c.y+=sin(c.xr)*sgn(stat(36))
     c.z+=sin(c.yr)*sgn(stat(36))
    end
   end]]
   local ax,ay=0,0
   if stat(34)==1 then
   	c.yr+=(m.px-m.x)/270
    //c.y=mid(-32,c.y-(m.py-m.y)/4,32)
   	//mview.xr=mid(-.125,mview.xr+(m.py-m.y)/180,.125)
    c.xr=mid(c.xr+(m.py-m.y)/270,.25,.75)
   end
   if tab=="mdl" then
    for i,sp in ipairs(p2d) do
    	if sp!="nil" and m.x==sp[1]\1 and m.y==sp[2]\1 then
    		mps[i].h=1
    		if m.lc then
    		 if not insel(i) then
    			 add(sel,i)
    			else
    			 del(sel,i)
    			end
    			break
 		 		end
 		 	end
    end
   end
   if tool=="face" and m.rc then
   	sel.c=col
 	 	sel.h=0
 	 	if #sel>=3 then add(mts,sel) end
 			sel={}
   end
  end
 	
 	if tool=="color" or tool=="flip" or tool=="extrude" then
 		if m.rc then
 			if #sel>2 then
 				for t in all(mts) do
 				 if #sel==#t then
 				  local e=0
 					 for s in all(sel) do
 					 	local i=1
 					 	while i<=#t and e<=#t and s!=t[i] do
 					 		i+=1
 							end
 							if s==t[i] then e+=1 end
 					 end
 					 if e==#t then 
 					  if tool=="color" then
 					   t.c=col
 					  elseif tool=="flip" then
 					   local temp={unpack(t)}
 						  for i=1,#t do
 						  	t[i]=temp[#t-i+1]
         end
        else
         local n=normal({mps[t[1]],mps[t[2]],mps[t[3]]})
        	local nps={}
        	for i in all(sel) do
        		local p=mps[i]
        		local np={p[1]+n[1]\.5,p[2]+n[2]\.5,p[3]-n[3]\.5,c=7,h=0}
        		if np[1]>=0 and np[1]<=14 and np[2]>=0 and np[2]<=14 and np[3]>=0 and np[3]<=14 then
        		 add(nps,np)
        		end
 								end
 								if #nps==#t then
 								 local ttl=#mps+#t
 								 local nt={c=t.c,h=t.h}
 									for i,p in ipairs(nps) do 
 									 add(mps,p) 
 									 add(mts,{ttl-#t+i,ttl-#t+i%#t+1,t[i%#t+1],t[i],c=i%2+5,h=0})
 									 add(nt,ttl-#t+i)
 									end
 									add(mts,nt)
 									del(mts,t)
 								end
        end
 					 end
 	    end
 				end
 			end
 			sel={}
 		end
 	end
 	
 	if tool=="save" then
 	 local k=stat(31)
 		if k!="\b" and k!="\r" then mname..=k
 		elseif k=="\b" then mname=sub(mname,1,#mname-1)
 	 elseif k=="\r" then 
 	  models[curmdl].ps=mps
		  models[curmdl].ts=mts
 	  for i,m in ipairs(models) do
 	   for y,p in ipairs(m.ps) do
 		   for x,v in ipairs(p) do
 		   	sset(i*8+x-9,63+y,v)
 		   end
 		  end
 		  for y,t in ipairs(m.ts) do
 	    sset(i*8-5,63+y,t.c)
 		   for x,p in ipairs(t) do
 		   	sset(i*8+x-5,y+63,p%16-1)
 		   end
      if #t==3 then
			    sset(i*8-1,y+63,t[3]%16-1)
		    end
 	   end
 	   for j,c in pairs(copies[i]) do
 	   	for k,v in pairs(c) do
 	   		sset(i*8-8+(k-1)%3*2,93+(k-1)/3+j*3,(v*4)\16)
						 sset(i*8-7+(k-1)%3*2,93+(k-1)/3+j*3,(v*4)%16)
						end
     end
 	  end
 	  cstore(0x1000,0x1000,4095,"arr_"..mname..".p8") 
 	 end
 	end
 	
 	local keybuffer=stat(31)
 	
 	if view>0 and view<4 then
 		local vi=vxy(0,view,true)
 	 local ch={pvpos[1]-vpos[1],pvpos[2]-vpos[2]}
 	 zoom[view]=mid(.5,zoom[view]-stat(36)/16,1.875)
 	 if tool=="none" then
 	  if m.lc then sel={} end
 	  if stat(34)==1 then
 	 	 for i=1,2 do voffs[vi[i]]+=ch[i] end
  	 end
  	end
 	 for i=1,2 do
 	 	voffs[vi[i]]=mid(0,voffs[vi[i]],14-8*zoom[view])
  	end
  	
 	 if tool=="point" then
 	  sel={}
 	  local p={0,0,0}
 	  p[vi[1]]=vposo[1]
    p[vi[2]]=vposo[2]
    if m.lc then
     p.h=0
     if #mps<16 then
 	  	 add(mps,p)
 	  	end
    end
    if m.rc then
 	 		local i=findp()
 	 		if i!=nil then 
 	 		 delp(i)
 	 		end
    end
    add(text,{p[1]..","..p[2]..","..p[3],m.x,m.y-6,7}) 

	  elseif tool=="select" then
	   if m.lc then
	    local i=findp(true)
	  		if i!=nil then add(sel,i) mps[i].c=8 else sel={} end
    end
    if stat(34)==1 then
     local edge=false
     for i in all(sel) do
     	local p=vxy(i,view)
     	p[1]-=ch[1]
     	p[2]-=ch[2]
     	if p[1]<0 or p[1]>15 or p[2]<0 or p[2]>15 then edge=true end
     end
     if not edge then
     	for i in all(sel) do
     	 mps[i][vi[1]]-=ch[1]
     	 mps[i][vi[2]]-=ch[2]
     	end
     end
    end
    if m.rc then
     local temp={}
	 			for i in all(sel) do
	 				add(temp,mps[i])
	 				delp(i)
	 			end
	 			for p in all(temp) do
	 				del(mps,p)
	 			end
	 			sel={}
	   end
  	
	  elseif tool=="face" then
	 	 if m.lc then
	    local i=findp(true)
    	if i!=nil then add(sel,i) end
	  	elseif m.rc then
	  	 sel.c=col
	  	 sel.h=0
	  		if #sel>=3 and #sel<5 then add(mts,sel) end
	 			sel={}
	 		end 

	  elseif tool=="color" or tool=="flip" or tool=="extrude" then
	  	if m.lc then 
	  		local i=findp(true)
	  		if i!=nil then add(sel,i) end
		 	end
		 end
	 end
	 
	 //arranger controls
	 if tab=="arr" and curcop>0 and view!=4 then
	  local x,y,z=1,2,3
	  local sc=.25
	  local mn=0
	  local mx=63.75
	  local move=false
	  local m=copies[curmdl][curcop]
	  if tool=="reset" then
	  	tool="none"
	  	for b in all(tools) do b.press=false end
	  	m[1]=0 m[2]=0 m[3]=0
	  	m[4]=1 m[5]=1 m[6]=1
	  	m[7]=0 m[8]=0 m[9]=0
	  	move=true
   end
   if tool=="scale" then
				x=4
				y=5
				z=6
				sc=.25
				mn=.25
				mx=63.75
			elseif tool=="rotate" then
				x=7
				y=8
				z=9
				m[7]%=40 m[8]%=40 m[9]%=40
				sc=1
				mx=41
				mn=-1
			end
			if tool!="save" then
				add(text,{"x:"..m[x].."\ny:"..m[y].."\nz:"..m[z],19,2,7})
				if btnp(⬅️) and m[x]-sc>=mn then
					m[x]-=sc 
					move=true
				end
				if btnp(➡️) and m[x]+sc<=mx then
					m[x]+=sc
					move=true
				end
				if btnp(⬆️) and m[z]+sc<=mx then
					m[z]+=sc
					move=true
				end
				if btnp(⬇️) and m[z]-sc>=mn then
					m[z]-=sc
					move=true
				end
				if btnp(❎) and m[y]+sc<=mx then
					m[y]+=sc
					move=true
				end
				if btnp(🅾️) and m[y]-sc>=mn then
					m[y]-=sc
					move=true
				end
			end
			if move then updarrm() end
  end
	end
	
	//delete model confirmation
 if dial=="delete model?" then
  if btnp(❎) then
   deli(models,curmdl)
   deli(copies,curmdl)
   curmdl=1
 		mps=models[1].ps
   p2d={}
   mts=models[1].ts
   dial=""
   if tab=="arr" then updarrm() end
  elseif btnp(🅾️) then
  	dial=""
  end
 end
	
	//model buttons
 while #models>#mdlbtn do
 	add(mdlbtn,{c=#mdlbtn%7+8,1+#mdlbtn%2*7,105-#mdlbtn\2*8,6+#mdlbtn%2*7,110-#mdlbtn\2*8,0})
 end
 while #models<#mdlbtn do
 	deli(mdlbtn,#mdlbtn)
 end
 //copy buttons
 if #copies[curmdl]>#cpybtn then
 	add(cpybtn,{c=#cpybtn%7+8,34+(#cpybtn+1)*6,121,38+(#cpybtn+1)*6,125,0})
 end
 if #copies[curmdl]<#cpybtn then
 	deli(cpybtn,#cpybtn)
 end
end


//updates tris if points are deleted
function delp(i)
 del(sel,i)
 local ttemp={}
	for t in all(mts) do
	 local nt={}
	 nt.c=t.c
	 nt.h=t.h
	 for p in all(t) do
	  if p!=i then add(nt,mps[p]) end
  end
  if #nt>=3 then add(ttemp,nt) end
	end
	local ptemp=copy(mps)
	deli(ptemp,i)
	for t in all(ttemp) do
  for j,p in ipairs(t) do
  	for k,mp in ipairs(ptemp) do
  		if p[1]==mp[1] and p[2]==mp[2] and p[3]==mp[3] then t[j]=k end
			end
  end
	end
	mps=ptemp
	mts=ttemp
end
