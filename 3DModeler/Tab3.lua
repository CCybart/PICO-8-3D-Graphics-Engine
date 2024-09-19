--ui
local tools={}
local text={}

//find x,y of point in view
function vxy(i,v,io)
 local io=io or false
 if io then return {tonum(v>1)*2+1,v%2+1} end
 if i>0 and i<=#mps then return {mps[i][tonum(v>1)*2+1],mps[i][v%2+1]} end
 return nil
end

//checks if already selected
function insel(i,s)
 s=s or true
 if s then
  local np=mps[i]
 	for k in all(sel) do
 	 local p=mps[k]
 		if p[1]==np[1] and p[2]==np[2] and p[3]==np[3] then
 			return true
			end
		end
 end
 return false
end

//finds first point in view at cursor
function findp(s)
 local s=s or false
	local i=1
	local vp=vxy(i,view)
	local vi=vxy(0,view,true)
	while i<=#mps and (vp[1]!=vposo[1] or vp[2]!=vposo[2] or insel(i,s)) do
	 i+=1
	 vp=vxy(i,view)
	end
	if i<=#mps then return i end
	return nil
end

//buttons
function binit(name,sp,x1,y1,t)
	local b={}
	b.name=name
	b.ic=sp
	b.b={x1,y1,x1+6,y1+6}
	b.h=false
	b.press=false
	b.t=t or 1
	
	//update
	function b.up(this)
	 if (this.t==1 and tab=="mdl") or (this.t==2 and tab=="arr") or this.t==3 then
	  //hover
		 if pinb(m.x,m.y,this.b) then
		 	this.h=true
		 	//pressed
		 	if m.lc then
		 	 if this.name!="style" and this.name!="addmdl" and this.name!="copy" then
		 	  for b in all(tools) do	if b!=this then b.press=false end end
		 	  tool=this.name
		 	  this.press=not this.press
		 	  if not this.press then tool="none" end
		 	 elseif this.name=="style" then
		 	 	gstyl=gstyl%3+1
		 	 	this.ic=gstyl+5
     elseif this.name=="addmdl" and #models<12 then
     	add(models,{ps={},cent={.1,.1,.1},ts={}})
      add(copies,{{0,0,0,1,1,1,0,0,0}})
     elseif this.name=="copy" and #copies[curmdl]<10 then
     	if curcop!=-1 then add(copies[curmdl],copy(copies[curmdl][curcop]))
      else add(copies[curmdl],{0,0,0,1,1,1,0,0,0}) end
      curcop=#copies[curmdl]
      updarrm()
     end
		 	end
		 else
		 	this.h=false
		 end
		end
	end
	
	//icon
	function b.draw(this)
		if (this.t==1 and tab=="mdl") or (this.t==2 and tab=="arr") or this.t==3 then
		 if this.press then rectfill(this.b[1],this.b[2],this.b[3],this.b[4],2) end
	  spr(this.ic,this.b[1],this.b[2])
	  if this.h then add(text,{this.name,m.x,m.y-6,7}) end
	 end
	end
	
	return b
end

add(tools,binit("point",2,16,113))
add(tools,binit("select",3,24,113))
add(tools,binit("face",4,32,113))
add(tools,binit("color",5,40,113))
add(tools,binit("style",gstyl+5,82,113,3))
add(tools,binit("flip",9,48,113))
//add(tools,binit("extrude",10,64,113))
add(tools,binit("save",11,98,113,3))
add(tools,binit("addmdl",12,90,113,3))
add(tools,binit("trans",18,16,113,2))
add(tools,binit("scale",19,24,113,2))
add(tools,binit("rotate",20,32,113,2))
add(tools,binit("reset",21,40,113,2))
add(tools,binit("copy",22,48,113,2))
