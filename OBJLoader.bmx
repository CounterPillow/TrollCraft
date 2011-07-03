
Type TOBJOperation
	Field Operation:String
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
	Field Operations:TList
	Field DestMesh:TMesh
	
	Method New()
		Operations:TList = New TList
	End Method
	
	Method BuildMesh()
		Local Op:TOBJOperation
		If DestMesh = Null
			DestMesh:TMesh = New TMesh
			For Op:TOBJOperation = EachIn Operations
				Select Op.Operation
					Case "v"
					
					Case "vn"
					
					Case "f"
					
					Default
						DebugLog("!|Unknown Operation '" + Op.Operation + "' couldn't be processed!")
				End Select
			Next
		EndIf
	End Method
End Type