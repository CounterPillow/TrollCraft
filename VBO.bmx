Type TVertexBufferObject
	Const KIND_VERTEX_BUFFER:Int = 0
	Const KIND_INDEX_BUFFER:Int  = 1
	
	Const USAGE_STATIC :Int = 0
	Const USAGE_DYNAMIC:Int = 1
	Const USAGE_STREAM :Int = 2
	
	Const USAGE_DRAW:Int = 0
	Const USAGE_READ:Int = 1
	Const USAGE_COPY:Int = 2
	
	Const ACCESS_WRITE:Int = 0
	Const ACCESS_READ:Int = 1
	Const ACCESS_READ_WRITE:Int = 2
	
	Global UsageToGLConstant:Int[][] = [ ..
		[ GL_STATIC_DRAW_ARB , GL_STATIC_READ_ARB , GL_STATIC_COPY_ARB  ], ..
		[ GL_DYNAMIC_DRAW_ARB, GL_DYNAMIC_READ_ARB, GL_DYNAMIC_COPY_ARB ], ..
		[ GL_STREAM_DRAW_ARB , GL_STREAM_READ_ARB , GL_STREAM_COPY_ARB  ]  ..
	]
	
	Global KindToGLConstant:Int[] = [ GL_ARRAY_BUFFER, GL_ELEMENT_ARRAY_BUFFER ]
	
	Global AccessToGLConstant:Int[] = [ GL_WRITE_ONLY_ARB, GL_READ_ONLY_ARB, GL_READ_WRITE_ARB ]
	
	Field BufferID:Int
	
	Field Kind:Int
	
	Field Usage:Int
	
	Field DataPointer:Byte Ptr
	Field DataBuffered:Int
	
	Method Bind()
		glBindBufferARB( KindToGLConstant[ Kind ], BufferID )
	End Method
	
	Method Map( Access:Int = ACCESS_WRITE )
		DataPointer = glMapBufferARB( KindToGLConstant[ Kind ], AccessToGLConstant[ Access ] )
	End Method
	
	Method UnMap()
		glUnMapBufferARB( KindToGLConstant[ Kind ] )
		DataPointer = Null
	End Method
	
	Method SetUsage( Behaviour:Int, _Usage:Int )
		Usage = UsageToGLConstant[ Behaviour ][ _Usage ]
	End Method
	
	Method BufferData( Size:Int, Data:Byte Ptr )
		DataBuffered = Size
		
		glBufferDataARB( KindToGLConstant[ Kind ], Size, Data, Usage )
	End Method
	
	Method BufferSubData( Offset:Int, Size:Int, Data:Byte Ptr )
		glBufferSubDataARB( KindToGLConstant[ Kind ], Offset, Size, Data )
	End Method
	
	Method Delete()
		glDeleteBuffersARB( 1, Int Ptr [ BufferID ] )
	End Method
	
	Function Create:TVertexBufferObject( Kind:Int )
		Local VBO:TVertexBufferObject = New TVertexBufferObject
		
		glGenBuffers( 1, Varptr VBO.BufferID )
		
		VBO.Kind = Kind
		
		Return VBO
	End Function
End Type

Type TShader
	Field ProgramObject:Int
	Field VertexShader:Int
	Field FragmentShader:Int
	
	Method New()
		ProgramObject	= glCreateProgramObjectARB()
		VertexShader	= glCreateShaderObjectARB( GL_VERTEX_SHADER_ARB )
		FragmentShader	= glCreateShaderObjectARB( GL_FRAGMENT_SHADER_ARB )
	End Method
	
	Method Load:TShader( VertexPath:String, FragmentPath:String )
		LoadShader( VertexPath,   VertexShader   )
		LoadShader( FragmentPath, FragmentShader )
		
		glCompileShaderARB( VertexShader   ); CheckForErrors( VertexShader   )
		glCompileShaderARB( FragmentShader ); CheckForErrors( FragmentShader )
		
		glAttachObjectARB( ProgramObject, VertexShader   )
		glAttachObjectARB( ProgramObject, FragmentShader )
		
		glDeleteObjectARB( VertexShader   )
		glDeleteObjectARB( FragmentShader )
		
		glLinkProgramARB( ProgramObject ); CheckForErrors( ProgramObject )
		
		Return Self
	End Method
	
	Method Enable()
		glUseProgramObjectARB( ProgramObject )
	End Method
	
	Method Disable()
		glUseProgramObjectARB( 0 )
	End Method
	
	Method Remove()
		glDeleteObjectARB( ProgramObject )
		
		Print "Removed!"
	End Method
	
	Function LoadShader( Path:String, ShaderObject:Int, ExistingShaderCode:String = "" )
		Local ShaderCode:String
		
		If ExistingShaderCode <> "" Then
			ShaderCode = ExistingShaderCode
		Else
			Try ShaderCode = LoadText( Path ) Catch Error:Object Return; EndTry
		EndIf
		
		If ShaderCode <> "" Then
			Local ShaderCodeC:Byte Ptr		= ShaderCode.ToCString()
			Local ShaderCodeLen:Int		= ShaderCode.Length
			
			glShaderSourceARB( ShaderObject, 1, Varptr ShaderCodeC, Varptr ShaderCodeLen )
			
			MemFree( ShaderCodeC )
		EndIf
	End Function
	
	Function CheckForErrors( ShaderObject:Int )
		Local ErrorLength:Int
		
		glGetObjectParameterivARB( ShaderObject, GL_OBJECT_INFO_LOG_LENGTH_ARB, Varptr ErrorLength )
		
		If ErrorLength Then
			Local Message:Byte[ ErrorLength ], Dummy:Int
			
			glGetInfoLogARB( ShaderObject, ErrorLength, Varptr Dummy, Varptr Message[ 0 ] )
			
			WriteStdout "Shader object '" + ShaderObject + "': " + StringFromCharArray( Message )
			WriteStdout "~n"
		EndIf
	End Function
	
	Function StringFromCharArray:String( Array:Byte[] )
		Local Output:String
		For Local I:Int = 0 To Array.Length - 1
			Output :+ Chr( Array[ I ] )
		Next
		
		Return Output
	End Function
	
	Function CheckCompability:Int()
		Local Extensions:String	= String.FromCString( Byte Ptr glGetString( GL_EXTENSIONS ) )
		Local GLVersion:String		= String.FromCString( Byte Ptr glGetString( GL_VERSION ) )
		Local GLVersionInt:Int		= GLVersion[ .. 3 ].Replace( ".", "" ).ToInt()
		
		If Extensions.Find( "GL_ARB_shader_objects"  ) >= 0 And ..
		   Extensions.Find( "GL_ARB_vertex_shader"   ) >= 0 And ..
		   Extensions.Find( "GL_ARB_fragment_shader" ) >= 0 Or GLVersionInt >= 20 Then Return True
		
		Return False
	End Function
End Type