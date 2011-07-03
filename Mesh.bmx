Type TMesh Extends TEntity
	Const MAX_TEXTURES:Int = 8
	
	Global NullPointer:Byte Ptr = Null
	
	Field Hidden:Int
	
	Field VertexSize:Int
	Field PositionIndex:Int
	Field NormalIndex:Int
	Field ColorIndex:Int
	Field TexCoordIndex:Int
	
	Field VertexCount:Int
	
	Field VBO:TVertexBufferObject
	Field IBO:TVertexBufferObject
	
	Field Textures:TTexture2D[ MAX_TEXTURES ]
	
	Field DrawCallback( Mesh:TMesh )
	
	Method New()
		TRenderer.Meshes.AddLast( Self )
		
		VertexSize = 13*4
		
		PositionIndex = 0
		  NormalIndex = 3*4
		   ColorIndex = 6*4
		TexCoordIndex = 7*4
	End Method
	
	Method SetTexture( Texture:TTexture2D, Level:Int = 0 )
		Textures[ Level ] = Texture
	End Method
	
	Method Init()	
		If Not VBO Then 
			VBO = TVertexBufferObject.Create( TVertexBufferObject.KIND_VERTEX_BUFFER )
			
			VBO.Bind()
			VBO.SetUsage( VBO.USAGE_STATIC, VBO.USAGE_DRAW )
		EndIf
		
		If Not IBO Then
			IBO = TVertexBufferObject.Create( TVertexBufferObject.KIND_INDEX_BUFFER )
			
			IBO.Bind()
			IBO.SetUsage( IBO.USAGE_STATIC, IBO.USAGE_DRAW )
		EndIf
	End Method
	
	Method Draw()
		If DrawCallback <> Null Then
			DrawCallback( Self )
		Else
			DefaultDraw()
		EndIf
	End Method
	
	Method DefaultDraw()
		VBO.Bind()
		If IBO Then IBO.Bind()
		
		If PositionIndex >= 0 Then
			glEnableClientState( GL_VERTEX_ARRAY )
			glVertexPointer( 3, GL_FLOAT, VertexSize, NullPointer + PositionIndex )
		Else
			glDisableClientState( GL_VERTEX_ARRAY )
		EndIf
		
		If NormalIndex >= 0 Then
			glEnableClientState( GL_NORMAL_ARRAY )
			glNormalPointer( GL_FLOAT, VertexSize, NullPointer + NormalIndex )
		Else
			glDisableClientState( GL_NORMAL_ARRAY )
		EndIf
		
		If ColorIndex >= 0 Then
			glEnableClientState( GL_COLOR_ARRAY )
			glColorPointer( 4, GL_UNSIGNED_BYTE, VertexSize, NullPointer + ColorIndex )
		Else
			glDisableClientState( GL_COLOR_ARRAY )
		EndIf
		
		For Local I:Int = 0 To 1
			If Textures[ I ] Then
				glActiveTexture( GL_TEXTURE0 + I )
				glClientActiveTexture( GL_TEXTURE0 + I )
				
				Textures[ I ].SetState()
				
				glEnable( GL_TEXTURE_2D )
				
				glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST )
				glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST )
				
				If TexCoordIndex >= 0 Then
					glEnableClientState( GL_TEXTURE_COORD_ARRAY )
					glTexCoordPointer( 3, GL_FLOAT, VertexSize, NullPointer + ( TexCoordIndex + 3*4*I ) )
				EndIf
			EndIf
		Next
		
		If IBO Then
			glDrawElements( GL_QUADS, VertexCount, GL_UNSIGNED_SHORT, Null )
		Else
			glDrawArrays( GL_QUADS, 0, VertexCount )
		EndIf
		
		For Local I:Int = 0 Until MAX_TEXTURES
			If Textures[ I ] Then
				glActiveTexture( GL_TEXTURE0 + I )
				
				glDisable( GL_TEXTURE_2D )
			EndIf
		Next
		
		glDisableClientState( GL_VERTEX_ARRAY )
		glDisableClientState( GL_NORMAL_ARRAY )
		glDisableClientState( GL_COLOR_ARRAY )
		glDisableClientState( GL_TEXTURE_COORD_ARRAY )
	End Method
	
	Function Create:TMesh( VBO:TVertexBufferObject = Null, IBO:TVertexBufferObject = Null, DrawCallback( Mesh:TMesh ) = Null )
		Local Mesh:TMesh = New TMesh
		
		Mesh.VBO = VBO
		Mesh.IBO = IBO
		Mesh.DrawCallback = DrawCallBack
		
		Mesh.Init()
		
		Return Mesh
	End Function
	
	Method MakeCube()
		VBO.Bind()
		VBO.BufferData( 24*24, Null )
		VBO.Map()
		
		RenderCubeIntoBuffer( VBO.DataPointer, -0.5, -0.5, -0.5 )
		
		VBO.UnMap()
		
		IBO.Bind()
		IBO.BufferData( 24*2, Null )
		IBO.Map()
		Local Buffer:Short Ptr = Short Ptr IBO.DataPointer
		
		For Local I:Int = 0 Until 24
			Buffer[ I ] = I
		Next
		
		IBO.UnMap()
		
		VertexCount = 24
	End Method
	
	Method RenderCubeIntoBuffer:Byte Ptr( Buffer:Byte Ptr, X:Float, Y:Float, Z:Float )
		Buffer = RenderVertexIntoBuffer( Buffer, 0.0 + X, 1.0 + Y, 1.0 + Z,  0.0,  0.0,  1.0 )
		Buffer = RenderVertexIntoBuffer( Buffer, 1.0 + X, 1.0 + Y, 1.0 + Z,  0.0,  0.0,  1.0 )
		Buffer = RenderVertexIntoBuffer( Buffer, 1.0 + X, 0.0 + Y, 1.0 + Z,  0.0,  0.0,  1.0 )
		Buffer = RenderVertexIntoBuffer( Buffer, 0.0 + X, 0.0 + Y, 1.0 + Z,  0.0,  0.0,  1.0 )
		
		Buffer = RenderVertexIntoBuffer( Buffer, 1.0 + X, 0.0 + Y, 0.0 + Z,  1.0,  0.0,  0.0 )
		Buffer = RenderVertexIntoBuffer( Buffer, 1.0 + X, 0.0 + Y, 1.0 + Z,  1.0,  0.0,  0.0 )
		Buffer = RenderVertexIntoBuffer( Buffer, 1.0 + X, 1.0 + Y, 1.0 + Z,  1.0,  0.0,  0.0 )
		Buffer = RenderVertexIntoBuffer( Buffer, 1.0 + X, 1.0 + Y, 0.0 + Z,  1.0,  0.0,  0.0 )
		
		Buffer = RenderVertexIntoBuffer( Buffer, 0.0 + X, 0.0 + Y, 0.0 + Z,  0.0,  0.0, -1.0 )
		Buffer = RenderVertexIntoBuffer( Buffer, 1.0 + X, 0.0 + Y, 0.0 + Z,  0.0,  0.0, -1.0 )
		Buffer = RenderVertexIntoBuffer( Buffer, 1.0 + X, 1.0 + Y, 0.0 + Z,  0.0,  0.0, -1.0 )
		Buffer = RenderVertexIntoBuffer( Buffer, 0.0 + X, 1.0 + Y, 0.0 + Z,  0.0,  0.0, -1.0 )
		
		Buffer = RenderVertexIntoBuffer( Buffer, 0.0 + X, 0.0 + Y, 1.0 + Z, -1.0,  0.0,  0.0 )
		Buffer = RenderVertexIntoBuffer( Buffer, 0.0 + X, 0.0 + Y, 0.0 + Z, -1.0,  0.0,  0.0 )
		Buffer = RenderVertexIntoBuffer( Buffer, 0.0 + X, 1.0 + Y, 0.0 + Z, -1.0,  0.0,  0.0 )
		Buffer = RenderVertexIntoBuffer( Buffer, 0.0 + X, 1.0 + Y, 1.0 + Z, -1.0,  0.0,  0.0 )
		
		Buffer = RenderVertexIntoBuffer( Buffer, 1.0 + X, 1.0 + Y, 1.0 + Z,  0.0,  1.0,  0.0 )
		Buffer = RenderVertexIntoBuffer( Buffer, 0.0 + X, 1.0 + Y, 1.0 + Z,  0.0,  1.0,  0.0 )
		Buffer = RenderVertexIntoBuffer( Buffer, 0.0 + X, 1.0 + Y, 0.0 + Z,  0.0,  1.0,  0.0 )
		Buffer = RenderVertexIntoBuffer( Buffer, 1.0 + X, 1.0 + Y, 0.0 + Z,  0.0,  1.0,  0.0 )
		
		Buffer = RenderVertexIntoBuffer( Buffer, 1.0 + X, 0.0 + Y, 1.0 + Z,  0.0, -1.0,  0.0 )
		Buffer = RenderVertexIntoBuffer( Buffer, 1.0 + X, 0.0 + Y, 0.0 + Z,  0.0, -1.0,  0.0 )
		Buffer = RenderVertexIntoBuffer( Buffer, 0.0 + X, 0.0 + Y, 0.0 + Z,  0.0, -1.0,  0.0 )
		Buffer = RenderVertexIntoBuffer( Buffer, 0.0 + X, 0.0 + Y, 1.0 + Z,  0.0, -1.0,  0.0 )
		
		Return Buffer
	End Method
	
	Method RenderVertexIntoBuffer:Byte Ptr( Buffer:Byte Ptr, X:Float, Y:Float, Z:Float, NX:Float, NY:Float, NZ:Float, U:Float = 0.0, V:Float = 0.0, W:Float = 0.0, R:Byte = 255, G:Byte = 255, B:Byte = 255, A:Byte = 255, U2:Float = 0.0, V2:Float = 0.0, W2:Float = 0.0 )
		If PositionIndex >= 0 Then
			Local Position:Float Ptr = Float Ptr ( Buffer + PositionIndex )
		
			Position[ 0 ] = X
			Position[ 1 ] = Y
			Position[ 2 ] = Z
		EndIf
		
		If NormalIndex >= 0 Then
			Local Normal:Float Ptr = Float Ptr ( Buffer + NormalIndex )
			
			Normal[ 0 ] = NX
			Normal[ 1 ] = NY
			Normal[ 2 ] = NZ
		EndIf
		
		If ColorIndex >= 0 Then
			Local Color:Byte Ptr = Byte Ptr ( Buffer + ColorIndex )
			
			Color[ 0 ] = R
			Color[ 1 ] = G
			Color[ 2 ] = B
			Color[ 3 ] = A
		EndIf
		
		If TexCoordIndex >= 0 Then
			Local TexCoord:Float Ptr = Float Ptr ( Buffer + TexCoordIndex )
			
			TexCoord[ 0 ] = U
			TexCoord[ 1 ] = V
			TexCoord[ 2 ] = W
			TexCoord[ 3 ] = U2
			TexCoord[ 4 ] = V2
			TexCoord[ 5 ] = W2
		EndIf
		
		Buffer :+ VertexSize
		
		Return Buffer
	End Method
	
	Method LoadOBJ(file:String)
		Local fstream:TStream = ReadFile(file)
		Local inline:String
		Local Op:TOBJOperation
		Local inop:String
		
		Local Parser:TOBJParser = New TOBJParser
		Parser.DestMesh = Self
		
		While Not Eof(fstream)
			inline = ReadLine(fstream)
			inop = Left(inline,Instr(inline, " ") - 1)
			Select inop
				Case "v", "vn", "f"
					DebugLog("+|" + inop)
					Op:TOBJOperation = New TOBJOperation
					Parser.Operations.AddLast(Op)
					Op.Operation = inop
					Op.ParseParams(inline)
				Default
					DebugLog("!|Unknown Operation: " + inop)
			EndSelect
		Wend
		CloseFile(fstream)
	End Method
End Type
