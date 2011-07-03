SuperStrict

Import "MatrixVector.bmx"
Import "FastPerlinNoise.bmx"
Include "Voxelmap Generator.bmx"
Include "Texture.bmx"
Include "Entity.bmx"
Include "Camera.bmx"
Include "Light.bmx"
Include "VBO.bmx"
Include "Mesh.bmx"
Include "Chunk.bmx"
Include "Renderer.bmx"
Include "LuaHandler.bmx"
Include "BlockClass.bmx"
Include "Collision.bmx"
Include "OBJLoader.bmx"

TRenderer.Graphics3D(DesktopWidth(), DesktopHeight())
HideMouse()
TLuaHandler.Init()
TBlockClass.Init()

Global Camera:TCamera = TCamera.Create()
Camera.SetAOV( 60.0 )
Camera.SetViewport( 0, 0, DesktopWidth(), DesktopHeight() )
Camera.SetClsColor( 64, 64, 64 )
Camera.SetRange( 1.0, 500.0 )
Camera.Move( 0.0, 100.0, 0.0 )
Camera.SetFogEnabled(True)
Camera.SetFogColor(64,64,64)
Camera.SetFogRange(0.5,50.0)

'Collision
Local CamBox:TBox = TBox.Create(Camera)
CamBox.H = 2.0

TLight.SetAmbientColor( 180, 180, 180 )
Global Brightness:Float = 0.3

Local EnableCollisions:Int = False

Local Light:TLight = TLight.Create( TLight.KIND_DIRECTIONAL )
Light.Rotate( 45.0, -30.0, 0.0 )
Light.SetColor( 255, 255, 255 )

Global OldChunkX:Int, OldChunkZ:Int, ViewRange:Int = 5, ChunksToDo:Int
Global Pitch:Int, Yaw:Int = 90

Global AmbientSound:TSound = LoadSound("ambient.ogg", SOUND_LOOP)
Global AmbientChannel:TChannel = PlaySound(AmbientSound)
AmbientChannel.SetVolume(0.5)


Local Timer:TTimer = CreateTimer( 60 )

Init()

While Not ( KeyHit( KEY_ESCAPE ) Or AppTerminate() )

	TRenderer.RenderWorld()
	
	CreateVisibleChunks()
	
	TChunk.UpdateChunks()
	
	If EnableCollisions = True
		CamBox.UpdateCollisions()
		If CamBox.Collisions[0] = Null
			Camera.Position.Y = Camera.Position.Y - 0.5
		EndIf
	EndIf
	
	UserInput()
	
	If KeyHit(KEY_L)
		Print "X: " + CamBox.GetCurrentChunk().ChunkX
		Print "Z: " + CamBox.GetCurrentChunk().ChunkZ
		EnableCollisions = True
	EndIf
	
	Flip 1
	WaitTimer Timer
Wend
End

Function Init()
	For Local X:Int = ViewRange*2 - 1 To 0 Step -1
		For Local Z:Int = 0 Until ViewRange*2
			TChunk.CreateChunk( X - ViewRange, Z - ViewRange, ChunkCallback )
			
			ChunksToDo :+ 1
		Next
	Next
	
	MoveMouse TRenderer.GWidth/2, TRenderer.GHeight/2
	MouseXSpeed()
	MouseYSpeed()
End Function

Function UserInput()
	Local msx:Float = MouseXSpeed()
	Local msy:Float = MouseYSpeed()
	Pitch :- msy / 2
	Yaw   :+ msx / 2
	
	Pitch = Min( Max( -90.0, Pitch ), 90.0 )
	
	Camera.Rotate( Pitch, 0.0, 0.0 )
	Camera.Turn( 0.0, Yaw, 0.0 )
	
	'Dynamic Brightness
	If KeyDown( KEY_D ) Or KeyDown( KEY_A ) Or KeyDown( KEY_SPACE ) Or KeyDown( KEY_S ) Or KeyDown( KEY_W ) Or msx <> 0 Or msy <> 0 Then
		If Brightness < 0.3
			Brightness:+0.001
		EndIf
	Else
		If Brightness > 0.1 Then
			Brightness = Brightness - 0.001
		EndIf
	EndIf
	DynamicBrightness(Brightness)
	
	MoveMouse TRenderer.GWidth/2, TRenderer.GHeight/2
	MouseXSpeed()
	MouseYSpeed()
	
	'If ChunksToDo < ViewRange Then Camera.Move( 0.2, 0.0, 0.0, True )
	
	Local Speed:Float = 0.1
	Camera.Move( ( KeyDown( KEY_D ) - KeyDown( KEY_A ) )*Speed, ( KeyDown( KEY_SPACE ) - KeyDown( KEY_LCONTROL ) )*Speed, ( KeyDown( KEY_S ) - KeyDown( KEY_W ) )*Speed )
	
End Function

Function CreateVisibleChunks()
	Local CamChunkX:Int = Camera.Position.X/TChunk.CHUNK_WIDTH
	Local CamChunkZ:Int = Camera.Position.Z/TChunk.CHUNK_WIDTH
	
	Local DiffX:Int = OldChunkX - CamChunkX
	Local DiffZ:Int = OldChunkZ - CamChunkZ
	
	If DiffX Or DiffZ Then
		For Local Chunk:TChunk = EachIn TRenderer.Meshes
			If Abs( Chunk.ChunkX - CamChunkX ) > ViewRange*2 Or Abs( Chunk.ChunkZ - CamChunkZ ) > ViewRange*2 Then TRenderer.Meshes.Remove( Chunk )
		Next
		
		For Local X:Int = 0 Until Abs( DiffX ) * 2
			For Local Z:Int = 0 Until ViewRange*2
				TChunk.CreateChunk( -Sgn( DiffX )*( ViewRange + X ) + OldChunkX, CamChunkZ - ViewRange + Z, ChunkCallback )
			Next
		Next
		
		For Local Z:Int = 0 Until Abs( DiffZ ) * 2
			For Local X:Int = 0 Until ViewRange*2
				TChunk.CreateChunk( CamChunkX - ViewRange + X, -Sgn( DiffZ )*( ViewRange + Z ) + OldChunkZ, ChunkCallback )
			Next
		Next
	EndIf
	
	OldChunkX = CamChunkX
	OldChunkZ = CamChunkZ
End Function

Function ChunkCallback( Chunk:TChunk )
	ChunksToDo :- 1
End Function

Function DynamicBrightness(B:Float)
	Local color:Float = B * 200.0
	Local Light:TLight
	TLight.SetAmbientColor(color, color, color)
	For Light = EachIn TRenderer.Lights
		Light.SetColor(color,color,color)
	Next
	Camera.SetFogColor(color,color,color)
	Camera.SetFogRange(0.5, B * 165)
	Camera.SetClsColor(color, color, color)
	AmbientChannel.SetVolume(0.9 - B)
End Function