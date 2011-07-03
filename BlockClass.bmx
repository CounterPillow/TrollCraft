Type TBlockClass
	Const MAX_BLOCK_COUNT:Int = 1024
	
	Const TEXTURE_PATH:String = "terrain.png"
	Const AO_PATH     :String = "AO.png"
	
	Const FACES_PER_SIDE:Int = 16
	Const FACE_STEP:Float = 1.0/FACES_PER_SIDE
	
	Const AO_PER_SIDE:Int = 16
	Const AO_STEP:Float = 1.0/AO_PER_SIDE
	
	Global BlockTexture:TTexture2D
	Global AOTexture   :TTexture2D
	
	Global BlockArray:TBlockClass[ MAX_BLOCK_COUNT ]
	Global BlockList:TList = New TList
	
	Global AOU:Float[ 256 ]
	Global AOV:Float[ 256 ]
	
	Field ID:Int
	
	Field FaceTexture:Int[ 6 ]
	Field FaceU:Float[ 6 ]
	Field FaceV:Float[ 6 ]
	
	Field IsSolidBlock:Int
	Field IsLight:Int
	
	Field Masked:Int
	Field Transparent:Int
	Field Colliding:Int
	Field Flowing:Int
	
	Field TransparentIndex:Int
	Field Transparency:Float
	
	Field LightRadius:Float
	Field InvLightRadius:Float
	Field LightR:Float
	Field LightG:Float
	Field LightB:Float
	
	Field ForceBorders:Int
	
	Method New()
		BlockList.AddLast( Self )
	End Method
	
	Method InitFields()
		InvLightRadius = 1.0/LightRadius
		
		If Masked Then TransparentIndex = -1
		
		IsSolidBlock = ( Not Transparent ) And ( Not Masked )
		
		For Local I:Int = 0 Until 6
			FaceU[ I ] = ( ( FaceTexture[ I ] - 1 ) Mod FACES_PER_SIDE )*FACE_STEP
			FaceV[ I ] = ( ( FaceTexture[ I ] - 1 )  /  FACES_PER_SIDE )*FACE_STEP
		Next
	End Method
	
	Function Init()
		LoadBlockTextures()
		PrecalcAOCoordinates()
	End Function
	
	Function LoadBlockTextures()
		BlockTexture = TTexture2D.Load( TEXTURE_PATH )
		AOTexture    = TTexture2D.Load(      AO_PATH )
	End Function
	
	Function PrecalcAOCoordinates()
		For Local I:Int = 0 Until 256
			AOU[ I ] = ( I Mod AO_PER_SIDE )*AO_STEP
			AOV[ I ] = ( I  /  AO_PER_SIDE )*AO_STEP
		Next
	End Function
	
	Function GetAOConfiguration:Int( MapData:Byte[,,], X:Int, Y:Int, Z:Int, NX:Int, NY:Int, NZ:Int )
		Local Index:Int = 0
		
		If NY Then
			Local O:Int = -Sgn( NY )
			
			NY = 0
			
			Index :| ( BlockArray[ MapData[ X - O, Y + NY, Z + 1 ] ].IsSolidBlock )
			Index :| ( BlockArray[ MapData[ X    , Y + NY, Z + 1 ] ].IsSolidBlock ) Shl 1
			Index :| ( BlockArray[ MapData[ X + O, Y + NY, Z + 1 ] ].IsSolidBlock ) Shl 2
			Index :| ( BlockArray[ MapData[ X - O, Y + NY, Z     ] ].IsSolidBlock ) Shl 3
			Index :| ( BlockArray[ MapData[ X + O, Y + NY, Z     ] ].IsSolidBlock ) Shl 4
			Index :| ( BlockArray[ MapData[ X - O, Y + NY, Z - 1 ] ].IsSolidBlock ) Shl 5
			Index :| ( BlockArray[ MapData[ X    , Y + NY, Z - 1 ] ].IsSolidBlock ) Shl 6
			Index :| ( BlockArray[ MapData[ X + O, Y + NY, Z - 1 ] ].IsSolidBlock ) Shl 7
		ElseIf NX Then
			Local O:Int = Sgn( NX )
			
			NX = 0
			
			Index :| ( BlockArray[ MapData[ X + NX, Y + 1, Z - O ] ].IsSolidBlock )
			Index :| ( BlockArray[ MapData[ X + NX, Y + 1, Z     ] ].IsSolidBlock ) Shl 1
			Index :| ( BlockArray[ MapData[ X + NX, Y + 1, Z + O ] ].IsSolidBlock ) Shl 2
			Index :| ( BlockArray[ MapData[ X + NX, Y    , Z - O ] ].IsSolidBlock ) Shl 3
			Index :| ( BlockArray[ MapData[ X + NX, Y    , Z + O ] ].IsSolidBlock ) Shl 4
			Index :| ( BlockArray[ MapData[ X + NX, Y - 1, Z - O ] ].IsSolidBlock ) Shl 5
			Index :| ( BlockArray[ MapData[ X + NX, Y - 1, Z     ] ].IsSolidBlock ) Shl 6
			Index :| ( BlockArray[ MapData[ X + NX, Y - 1, Z + O ] ].IsSolidBlock ) Shl 7
		ElseIf NZ Then
			Local O:Int = Sgn( NZ )
			
			NZ = 0
			
			Index :| ( BlockArray[ MapData[ X - O, Y + 1, Z + NZ ] ].IsSolidBlock )
			Index :| ( BlockArray[ MapData[ X    , Y + 1, Z + NZ ] ].IsSolidBlock ) Shl 1
			Index :| ( BlockArray[ MapData[ X + O, Y + 1, Z + NZ ] ].IsSolidBlock ) Shl 2
			Index :| ( BlockArray[ MapData[ X - O, Y    , Z + NZ ] ].IsSolidBlock ) Shl 3
			Index :| ( BlockArray[ MapData[ X + O, Y    , Z + NZ ] ].IsSolidBlock ) Shl 4
			Index :| ( BlockArray[ MapData[ X - O, Y - 1, Z + NZ ] ].IsSolidBlock ) Shl 5
			Index :| ( BlockArray[ MapData[ X    , Y - 1, Z + NZ ] ].IsSolidBlock ) Shl 6
			Index :| ( BlockArray[ MapData[ X + O, Y - 1, Z + NZ ] ].IsSolidBlock ) Shl 7
		EndIf
		
		Return Index
	End Function
End Type