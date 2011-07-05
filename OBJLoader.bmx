Type TOBJOperation
	Field Parameters:TList
	
	Method New()
		Parameters:TList = New TList
	End Method
	
	Method ParseParams(in:String)
		Local spaceloc:Int
		Local spaceloc2:Int
		spaceloc = Instr(in, " ")
		spaceloc2 = Instr(in, " ", spaceloc + 1)
		
		While spaceloc2 <> 0
			Local Param:TOBJParam = New TOBJParam
			Param.Content = Mid(in, spaceloc + 1, spaceloc2 - spaceloc)
			Parameters.AddLast(Param:TOBJParam)
			
			spaceloc = spaceloc2
			spaceloc2 = Instr(in, " ", spaceloc + 1)
		Wend
	End Method
End Type

Type TOBJParam
	Field Content:String
	
	Method ToFloat:Float()
		Return Float(Content)
	End Method
End Type

Type TOBJParser
	Field Vertices:TList
	Field VerticesNormals:TList
	Field Faces:TList
	Field DestMesh:TMesh
	
	Method New()
		Vertices:TList = New TList
		VerticesNormals:TList = New TList
		Faces:TList = New TList
	End Method
	
	Method BuildMesh()
		Local Op:TOBJOperation
		Local VNOp:TOBJOperation	'VerticesNormals
		
		If DestMesh = Null
			DestMesh:TMesh = New TMesh
			DestMesh.Init()
		EndIf
		VNOp = TOBJOperation(VerticesNormals.FirstLink().Value())
		For Op = EachIn Vertices
			DestMesh.VBO.DataPointer = DestMesh.RenderVertexIntoBuffer( DestMesh.VBO.DataPointer, ..
											TOBJParam(Op.Parameters.FirstLink().Value()).ToFloat(), ..
											TOBJParam(Op.Parameters.FirstLink().NextLink().Value()).ToFloat(), ..
											TOBJParam(Op.Parameters.FirstLink().NextLink().NextLink().Value()).ToFloat(), ..
											TOBJParam(VNOp.Parameters.FirstLink().Value()).ToFloat(), ..
											TOBJParam(VNOp.Parameters.FirstLink().NextLink().Value()).ToFloat(), ..
											TOBJParam(VNOp.Parameters.FirstLink().NextLink().NextLink().Value()).ToFloat())
			VNOp = TOBJOperation(VerticesNormals.FindLink(VNOp).NextLink().Value())
		Next
		For Op = EachIn Faces
			
		Next
	End Method
End Type