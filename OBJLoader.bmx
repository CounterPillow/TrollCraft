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

Type TOBJFace	'Using TOBJParam doesn't make sense because f always has 3 space separated parameters
	Field v:TOBJOperation[3]
	Field vn:TOBJOperation[3]
	Field vt:TOBJOperation[3]
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
	
	Method ParseFaces:TOBJOperation(in:String)
		Rem
		Now this needs a little explanation.
		Faces can be one of the following formats:
		f v v v
		f v/vt v/vt v/vt
		f v/vt/vn v/vt/vn v/vt/vn
		f v//vn v//vn v//vn
		EndRem
		'Someone smarter would have generalized the parameter parsing, but I'm not that smart.
		Local SpaceLoc:Int
		Local SpaceLoc2:Int
		Local Param:String
		Local Face:TOBJFace = New TOBJFace
		SpaceLoc = Instr(in, " ")
		SpaceLoc2 = Instr(in, " ", SpaceLoc + 1)
		
		While SpaceLoc <> 0
			
			SpaceLoc = SpaceLoc2
			SpaceLoc2 = Instr(in, " ", SpaceLoc + 1)
		Wend
	EndMethod
	
	Method ParseVertParams:TOBJOperation(in:String)
		Local SpaceLoc:Int
		Local SpaceLoc2:Int
		Local Op:TOBJOperation = New TOBJOperation
		SpaceLoc = Instr(in, " ")
		SpaceLoc2 = Instr(in, " ", SpaceLoc + 1)
		
		While SpaceLoc2 <> 0
			Local Param:TOBJParam = New TOBJParam
			Param.Content = Mid(in, SpaceLoc + 1, SpaceLoc2 - SpaceLoc)
			Op.Parameters.AddLast(Param:TOBJParam)
			
			SpaceLoc = SpaceLoc2
			SpaceLoc2 = Instr(in, " ", SpaceLoc + 1)
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
					DebugLog("+|" + inop)	'I like pointless debuglog entries.
					Select inop
						Case "v"
							Vertices.AddLast(ParseVertParams(inline))
						Case "vn"
							VerticesNormals.AddLast(ParseVertParams(inline))
						Case "f"
							Faces.AddLast(ParseFaces(inline))
					End Select
				Default
					DebugLog("!|Unknown Operation: " + inop)
			EndSelect
		Wend
	EndMethod
	
End Type