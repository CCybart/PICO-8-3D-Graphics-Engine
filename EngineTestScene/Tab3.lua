--objs

function iobj(op,m,co)
	local obj={}
	if m!=0 then
	 obj.x,obj.y,obj.z,obj.xs,obj.ys,obj.zs,obj.xr,obj.yr,obj.zr=op[1],op[2],op[3],op[4],op[5],op[6],op[7],op[8],op[9]
	 obj.px,obj.py,obj.pz,obj.pxs,obj.pys,obj.pzs,obj.pxr,obj.pyr,obj.pzr=0,0,0,1,1,1,0,0,0
	 obj.size=size(mesh[m].ps)
	elseif co[7]!=nil then
		obj.size=sqrt(co[6]^2+co[7]^2)
	else
		obj.size=1
	end
	
	obj.cos={}
 if co!=nil then
 	add(obj.cos,co)
 end
	obj.model=m!=0 and copy(mesh[m]) or {ps={},ts={},cp=co[5]}
 
 //draw
 function obj.draw(this)
  if #this.model.ps!=0 then
   trfm(this.model,this)
  end
  add(objbuff,this)
  this.px,this.py,this.pz,this.pxs,this.pys,this.pzs,this.pxr,this.pyr,this.pzr=this.x,this.y,this.z,this.xs,this.ys,this.zs,this.xr,this.yr,this.zr
 end
 
 return obj
end

add(mesh,getmodel(104,16,15,8))
add(mesh,getmodel(112,16,15,9))
add(mesh,getmodel(120,16,15,9))
imap(104,8,13,13)

add(mesh,getmodel(8,8,11,13))
--[[add(mesh,getmodel(16,8,8,6))
add(mesh,getmodel(24,8,8,6))

add(objs,iobj({0,9,0,25,25,25,0,0,0},2))
for i=0,38 do
 add(objs,iobj({0,0,0,1,1,1,0,0,0},3))
end
]]

//add(objs,iobj({0,0,0,1,1,1,0,0,0},1))
