Type TOBJOperation
	Field Parameters:TList
	
	Method New()
		Parameters:TList = New TList
	End Method
End Type

Type TOBJParam
	Field Content:String
	
	Method ToFloat:Float()
		Return Float(Content)
	End Method
End Type

Type TOBJFace
	Field v:TOBJOperation
	Field vn:TOBJOperation
	Field vt:TOBJOperation
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
		Local Face:TOBJOperation
		Local VerticesA:TOBJOperation[] = TOBJOperation[](Vertices.ToArray())
		Local VerticesNormalsA:TOBJOperation[] = TOBJOperation[](VerticesNormals.ToArray())
		
		If DestMesh = Null
			DestMesh:TMesh = New TMesh
			DestMesh.Init()
		EndIf
		For Face = EachIn Faces
			
		Next
	End Method
	
	Method ParseFaces(in:String)
		Rem
		Now this needs a little explanation.
		Faces can be one of the following formats:
		f v v v
		f v/vt v/vt v/vt
		f v/vt/vn v/vt/vn v/vt/vn
		f v//vn v//vn v//vn
		EndRem
		
	EndMethod
	
	Method ParseVertParams:TOBJOperation(in:String)
		Local spaceloc:Int
		Local spaceloc2:Int
		Local Op:TOBJOperation = New TOBJOperation
		spaceloc = Instr(in, " ")
		spaceloc2 = Instr(in, " ", spaceloc + 1)
		
		While spaceloc2 <> 0
			Local Param:TOBJParam = New TOBJParam
			Param.Content = Mid(in, spaceloc + 1, spaceloc2 - spaceloc)
			Op.Parameters.AddLast(Param:TOBJParam)
			
			spaceloc = spaceloc2
			spaceloc2 = Instr(in, " ", spaceloc + 1)
		Wend
		Return Op:TOBJOperation
	End Method
	
	Method ParseFile(fstream:TStream)
		Local inline:String
		Local inop:String
		While Not Eof(fstream)
			inline = ReadLine(fstream)
			inop = Left(inline,Instr(inline, " ") - 1)
			Select inop
				Case "v", "vn", "f"
					DebugLog("+|" + inop)
					Select inop
						Case "v"
							Vertices.AddLast(ParseVertParams(inline))
						Case "vn"
							VerticesNormals.AddLast(ParseVertParams(inline))
						Case "f"

					End Select
					
				Default
					DebugLog("!|Unknown Operation: " + inop)
			EndSelect
		Wend
	EndMethod
	
End Type