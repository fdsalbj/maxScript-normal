-- Created by lbj
-- Based on : 
--NoorsNormalThief By JB "Noors" Sarrazin 2014-08-21
--Normal Thief 1.0 By Mauricio B. G. (mbg@southlogic.com)
--SlideNormalThief By Slide Ltd 2010-06-26 (contact@slidelondon.com)

macroScript NormalsAdjust
category:"lbj"
buttontext:"NormalsAdjust"
toolTip:"NormalsAdjust"
(
	---------------------------------------------------------------projectNormal
	fn projectNormal sObj t1Obj range =
	(	
		max modify mode
			
		--set source	
		select sObj	
		
		----set normal modifier on source object	
		msNormals = Edit_Normals ()
		msNormals.displayLength = 8
		addmodifier sObj msNormals
		
		s_NumNorm = msNormals.GetNumNormals()
		msNormals.SetSelection #{1..s_NumNorm}
		msNormals.Unify()
		msNormals.MakeExplicit()
		--cache functions
		s_Convert = msNormals.ConvertVertexSelection 
		s_NumVert = msNormals.GetNumVertices()
		s_Setnormal = msNormals.Setnormal 
		s_GetVert = msNormals.GetVertex
		----get all source object vertex coordinates
		refTransform = sObj.objecttransform
		
		vCoords = for i = 1 to s_NumVert collect (s_GetVert i)	* refTransform
		sv = for i in sObj.selectedVerts collect i.index
		
		--set target
		tri_tObj = snapshotasmesh t1Obj
		tObj = editable_mesh()
		tObj.mesh = tri_tObj
		select tObj
		----set normal modifier on target object	
		mtNormals = Edit_Normals ()
		mtNormals.displayLength = 0
		addmodifier tObj mtNormals
		--cache functions
		t_Convert = mtNormals.ConvertVertexSelection 
		t_GetNormal = mtNormals.Getnormal 
		t_NumVert = mtNormals.GetNumVertices()
		
		normalArray = #()
		normalArray[t_NumVert] = 0
		closestVertArray = #()
		closestVertArray[s_NumVert] = 0
		
		--collect all normals of target object in normalArray
		for i = 1 to t_NumVert do
		(	
			tnormalIDArray = #{}
			t_Vert = #{i}
			t_Convert &t_Vert &tnormalIDArray 
			tnormID = (tnormalIDArray as array)[1]
			n = t_GetNormal tnormID
			normalArray[i] = n
		)
		
		--for each vertex of source object, collect the closest point on target object in closestVertArray
		mpi = MeshProjIntersect()
		mpi.setNode tObj
		mpi.build()
		
		if range == "all" then
		(
			for i =1 to s_NumVert do 
			(
				refPos = vCoords[i]
				check = mpi.closestFace refPos doubleSided:true
				--if hit succeed
				if check == true then
				(
					closestVert = 0
					closestPoint = mpi.getHitPos()
					closestFace = mpi.GetHitFace()
					--zero based index
					closestFace+=1
					
					d = 10000000.0 --max distance to look for
					vID = getFace tObj closestFace
					vv = #(vID.x,vID.y,vID.z)
					getVertPos = meshop.getVert
					
					for v in vv do
					(
						curDist = distance (getVertPos tObj v) closestPoint
						if curDist < d do 
						(
							closestVert = v
							d = curDist
						)
					)	
					closestVertArray[i] = closestVert
				)
				--if hit fails
				else 
				(
					closestVertArray[i] = 1 
				)
			)
		)
		else if range == "selected" then
		(
			for i in sv do
			(
				refPos = vCoords[i]
				check = mpi.closestFace refPos doubleSided:true
				--if hit succeed
				if check == true then
				(
					closestVert = 0
					closestPoint = mpi.getHitPos()
					closestFace = mpi.GetHitFace()
					--zero based index
					closestFace+=1
					
					d = 10000000.0 --max distance to look for
					vID = getFace tObj closestFace
					vv = #(vID.x,vID.y,vID.z)
					getVertPos = meshop.getVert
					
					for v in vv do
					(
						curDist = distance (getVertPos tObj v) closestPoint
						if curDist < d do 
						(
							closestVert = v
							d = curDist
						)
					)	
					closestVertArray[i] = closestVert
				)
				--if hit fails
				else 
				(
					closestVertArray[i] = 1
				)
			)
		)
		--set normals on source obj
		select sObj
		disableRefMsgs()
		
		if range == "all" then
		(
			for i =1 to s_NumVert do 
			(
				try
				(
					s_normalIDArray = #{}
					s_Convert #{i} s_normalIDArray
					s_normID = (s_normalIDArray as array)[1]
					closestVert = closestVertArray[i] 
					s_norm = normalArray[closestVert]
					s_Setnormal s_normID s_norm
					)
				catch()
			)
		)
		else if range == "selected" then
		(
			for i in sv do
			(
				try
				(
					s_normalIDArray = #{}
					s_Convert #{i} s_normalIDArray
					s_normID = (s_normalIDArray as array)[1]
					closestVert = closestVertArray[i] 
					s_norm = normalArray[closestVert]
					s_Setnormal s_normID s_norm
					)
				catch()
			)
		)
		
		enableRefMsgs()
		
		--clean scene
		delete tObj
		mpi.Free()
		
		--force UI refresh
		--update sObj	
		redrawViews() 	
		max create mode
		max modify mode
			
		
	)
	
		---------------------------------------------------------------projectNormalCenter
	fn projectNormalCenter sObj t1Obj applyMode range =
	(	
		max modify mode
			
		--set source	
		select sObj	
		
		----set normal modifier on source object	
		msNormals = Edit_Normals ()
		msNormals.displayLength = 8
		addmodifier sObj msNormals
		
		s_NumNorm = msNormals.GetNumNormals()
		msNormals.SetSelection #{1..s_NumNorm}
		msNormals.Unify()
		msNormals.MakeExplicit()
		--cache functions
		s_Convert = msNormals.ConvertVertexSelection 
		s_NumVert = msNormals.GetNumVertices()
		s_Setnormal = msNormals.Setnormal 
		s_GetVert = msNormals.GetVertex
		----get all source object vertex coordinates
		refTransform = sObj.objecttransform
		
		vCoords = for i = 1 to s_NumVert collect (s_GetVert i)	* refTransform
		sv = for i in sObj.selectedVerts collect i.index
		
		--set target
		normalArray = #()
		closestVertArray = #()
		
		if range == "all" then
		(
			--collect all normals of target object in normalArray
			for i = 1 to s_NumVert do
			(
				n = [0,0,0]
				if applyMode == "out" then
				(
					n =  vCoords[i] - t1Obj.position
				)
				else if applyMode == "in" then
				(
					n = t1Obj.position - vCoords[i]
				)
				
				normalArray[i] = n
				closestVertArray[i] = i
			)
		)
		else if range == "selected" then
		(
			for i in sv do
			(
				n = [0,0,0]
				if applyMode == "out" then
				(
					n =  vCoords[i] - t1Obj.position
				)
				else if applyMode == "in" then
				(
					n = t1Obj.position - vCoords[i]
				)
				
				normalArray[i] = n
				closestVertArray[i] = i
			)
		)
		--set normals on source obj
		select sObj
		disableRefMsgs()
		
		if range == "all" then
		(
			for i =1 to s_NumVert do 
			(
				try
				(
					s_normalIDArray = #{}
					s_Convert #{i} s_normalIDArray
					s_normID = (s_normalIDArray as array)[1]
					closestVert = closestVertArray[i] 
					s_norm = normalArray[closestVert]
					s_Setnormal s_normID s_norm
				)
				catch()
			)
		)
		else if range == "selected" then
		(
			for i in sv do
			(
				try
				(
					s_normalIDArray = #{}
					s_Convert #{i} s_normalIDArray
					s_normID = (s_normalIDArray as array)[1]
					closestVert = closestVertArray[i] 
					s_norm = normalArray[closestVert]
					s_Setnormal s_normID s_norm
				)
				catch()
			)
		)
			
		enableRefMsgs()
		
		--force UI refresh
		--update sObj	
		redrawViews() 	
		max create mode
		max modify mode
		
	)
	
		---------------------------------------------------------------projectNormalOffset
	fn projectNormalOffset sObj inpos applyMode range =
	(	
		max modify mode
		
		--set source	
		select sObj	
		
		----set normal modifier on source object	
		msNormals = Edit_Normals ()
		msNormals.displayLength = 8
		addmodifier sObj msNormals
		
		s_NumNorm = msNormals.GetNumNormals()
		msNormals.SetSelection #{1..s_NumNorm}
		msNormals.Unify()
		msNormals.MakeExplicit()
		--cache functions
		s_Convert = msNormals.ConvertVertexSelection 
		s_NumVert = msNormals.GetNumVertices()
		s_Setnormal = msNormals.Setnormal 
		s_GetNormal = msNormals.Getnormal 
		s_GetVert = msNormals.GetVertex
		
		----get all source object vertex coordinates
		refTransform = sObj.objecttransform
		
		vCoords = for i = 1 to s_NumVert collect (s_GetVert i)	* refTransform
		sv = for i in sObj.selectedVerts collect i.index
		--set target
		normalArray = #()
		closestVertArray = #()
		
		if range == "all" then
		(
			--collect all normals of target object in normalArray
			for i = 1 to s_NumVert do
			(
				n = [0,0,0]
				s_normalIDArray = #{}
				s_Convert #{i} s_normalIDArray
				s_normID = (s_normalIDArray as array)[1]
				tn = s_GetNormal s_normID
				
				if applyMode == "add" then
				(
					n =  tn + inpos
				)
				else if applyMode == "mul" then
				(
					n = tn * inpos
				)
				
				normalArray[i] = n
				closestVertArray[i] = i
			)
		)
		else if range == "selected" then
		(
			--collect selected verts's normals of target object in normalArray
			for i in sv do
			(
				n = [0,0,0]
				s_normalIDArray = #{}
				s_Convert #{i} s_normalIDArray
				s_normID = (s_normalIDArray as array)[1]
				tn = s_GetNormal s_normID
				
				if applyMode == "add" then
				(
					n =  tn + inpos
				)
				else if applyMode == "mul" then
				(
					n = tn * inpos
				)
				
				normalArray[i] = n
				closestVertArray[i] = i
			)
		)
		--set normals on source obj
		select sObj
		disableRefMsgs()
		
		if range == "all" then
		(
			for i =1 to s_NumVert do 
			(
				try
				(
					s_normalIDArray = #{}
					s_Convert #{i} s_normalIDArray
					s_normID = (s_normalIDArray as array)[1]
					closestVert = closestVertArray[i] 
					s_norm = normalArray[closestVert]
					s_Setnormal s_normID s_norm
				)
				catch()
			)
		)
		else if range == "selected" then
		(
			for i in sv do
			(
				try
				(
					s_normalIDArray = #{}
					s_Convert #{i} s_normalIDArray
					s_normID = (s_normalIDArray as array)[1]
					closestVert = closestVertArray[i] 
					s_norm = normalArray[closestVert]
					s_Setnormal s_normID s_norm
				)
				catch()
			)
		)
		enableRefMsgs()
		
		--force UI refresh
		--update sObj	
		redrawViews() 	
		max create mode
		max modify mode
		
	)
	
		---------------------------------------------------------------projectNormalReset
		fn projectNormalReset sObj  range =
	(
		max modify mode
		
		--set source	
		select sObj	
		
		----set normal modifier on source object	
		msNormals = Edit_Normals ()
		msNormals.displayLength = 8
		addmodifier sObj msNormals
		
		s_NumNorm = msNormals.GetNumNormals()
		msNormals.SetSelection #{1..s_NumNorm}
		msNormals.Unify()
		msNormals.MakeExplicit()
		--cache functions
		s_Convert = msNormals.ConvertVertexSelection 
		s_NumVert = msNormals.GetNumVertices()
		s_Setnormal = msNormals.Setnormal 
		s_GetNormal = msNormals.Getnormal 
		s_GetVert = msNormals.GetVertex
		
		----get all source object vertex coordinates
		sv = for i in sObj.selectedVerts collect i.index
		
		--set normals on source obj
		select sObj
		disableRefMsgs()
		
		if range == "all" then
		(
			for i =1 to s_NumVert do 
			(
				s_normalIDArray = #{}
				s_Convert #{i} s_normalIDArray
				msNormals.Reset selection:s_normalIDArray
			)
		)
		else if range == "selected" then
		(
			for i in sv do 
			(
				s_normalIDArray = #{}
				s_Convert #{i} s_normalIDArray
				msNormals.Reset selection:s_normalIDArray
			)
		)
		enableRefMsgs()
		
		--force UI refresh
		--update sObj	
		redrawViews() 	
		max create mode
		max modify mode
		
	)


		--UI
		rollout NormalsAdjust "NormalsAdjust" width:280
			(
				group "Adjust vertices mode"
				(
					radioButtons affectmode width:240 height:30 labels:#("All vertices","Selected only") default:1 columns:2 align:#left
				)
				
				label lbl1 "======================================================"align:#center
				
				group "Offset"
				(
					spinner objx "X" range:[-100, 100, 0] type:#float align:#center width: 80
					spinner objy "Y" range:[-100, 100, 0] type:#float align:#center width: 80
					spinner objz "Z" range:[-100, 100, 1] type:#float align:#center width: 80
					
					button bt_add "Add" width:240 align:#left toolTip:"加法模式，将输入的值添加到法线中。"
					button bt_mul "Multiply" width:240 align:#left toolTip:"乘法模式，输入的值与法线相乘。"
					
				)
				
				label lbl7 "======================================================"align:#center
				
				group "Copy normals from"
				(
					pickbutton refPick "Reference Object" width:240 align:#left
				)
				group "Give normals to"
				(
					pickbutton objPick "Target Object" width:240 align:#left
				)
				group "Apply mode"
				(
					button bt_copy "Copy" width:240 align:#left toolTip:"拷贝引用目标最近顶点的法线到目标"
					button bt_centerOut "Center Out" width:240 align:#left toolTip:"以引用目标的位置为中心，进行发散，法线方向为 中心-->顶点"
					button bt_centerIn "Center In" width:240 align:#left toolTip:"以引用目标的位置为中心，进行收缩，法线方向为 顶点-->中心"
				)
				group "Reset"
				(
					button bt_reset "Reset" width:240 align:#left toolTip:"重置法线"
				)
				
				on refPick picked refmesh do
				(
					if (refmesh != undefined) do
						 refPick.text = refmesh.name
				)
				
				on objPick picked objmesh do
				(
					if (objmesh != undefined) do
						 objPick.text = objmesh.name
				)
				
				on bt_copy pressed  do
				(	
					obj = objPick.object 
					ref = refPick.object
					range = "all"
					if affectmode.state == 1 then
					(
						range = "all"
					)
					else
					(
						range = "selected"
					)
					if (obj != undefined) and (ref != undefined) then 
					(
						if (superclassof obj == geometryclass) and (superclassof ref == geometryclass) then
						(
							projectNormal objPick.object refPick.object range
						)
						else(messageBox "Please set valid geometry objects." title:"Oops !" )
					)
					else(messageBox "Please set target and source objects." title:"Oops !" )
				)
				
				on bt_centerOut pressed  do
				(	
					obj = objPick.object 
					ref = refPick.object
					range = "all"
					if affectmode.state == 1 then
					(
						range = "all"
					)
					else
					(
						range = "selected"
					)
					if (obj != undefined) and (ref != undefined) then 
					(
						if (superclassof obj == geometryclass) and (superclassof ref == geometryclass) then
						(
							projectNormalCenter objPick.object refPick.object "out" range
						)
						else(messageBox "Please set valid geometry objects." title:"Oops !" )
					)
					else(messageBox "Please set Reference and Target objects." title:"Oops !" )
				)
				
				on bt_centerIn pressed  do
				(	
					obj = objPick.object 
					ref = refPick.object
					range = "all"
					if affectmode.state == 1 then
					(
						range = "all"
					)
					else
					(
						range = "selected"
					)
					if (obj != undefined) and (ref != undefined) then 
					(
						if (superclassof obj == geometryclass) and (superclassof ref == geometryclass) then
						(
							projectNormalCenter objPick.object refPick.object "in" range
						)
						else(messageBox "Please set valid geometry objects." title:"Oops !" )
					)
					else(messageBox "Please set Reference and Target objects." title:"Oops !" )
				)
				
				on bt_add pressed  do
				(
					inpos = [objx.value,objy.value,objz.value]
					obj = objPick.object 
					range = "all"
					if affectmode.state == 1 then
					(
						range = "all"
					)
					else
					(
						range = "selected"
					)
					if (obj != undefined)then 
					(
						if (superclassof obj == geometryclass) then
						(
							projectNormalOffset objPick.object inpos "add" range
						)
						else(messageBox "Please set valid geometry objects." title:"Oops !" )
					)
					else(messageBox "Please set Target objects." title:"Oops !" )
				)
				
				on bt_mul pressed  do
				(
					inpos = [objx.value,objy.value,objz.value]
					obj = objPick.object 
					range = "all"
					if affectmode.state == 1 then
					(
						range = "all"
					)
					else
					(
						range = "selected"
					)
					if (obj != undefined)then 
					(
						if (superclassof obj == geometryclass) then
						(
							projectNormalOffset objPick.object inpos "mul" range
						)
						else(messageBox "Please set valid geometry objects." title:"Oops !" )
					)
					else(messageBox "Please set Target objects." title:"Oops !" )
				)
				
				on bt_reset pressed  do
				(
					inpos = [objx.value,objy.value,objz.value]
					obj = objPick.object 
					range = "all"
					if affectmode.state == 1 then
					(
						range = "all"
					)
					else
					(
						range = "selected"
					)
					if (obj != undefined)then 
					(
						if (superclassof obj == geometryclass) then
						(
							projectNormalReset objPick.object range
						)
						else(messageBox "Please set valid geometry objects." title:"Oops !" )
					)
					else(messageBox "Please set Target objects." title:"Oops !" )
				)
			)
			
		try(destroyDialog NormalsAdjust)catch()
		createDialog NormalsAdjust
)

macros.run "lbj" "NormalsAdjust"