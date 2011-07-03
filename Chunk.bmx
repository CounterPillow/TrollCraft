Type TChunk Extends TMesh
	Const CHUNK_OFFSET:Int = 1024
	
	Const CHUNK_WIDTH :Int = 32
	Const CHUNK_DEPTH :Int = 32
	Const CHUNK_HEIGHT:Int = 128
	
	Const CHUNK_SCALE:Float = 1.0/Max( Max( CHUNK_WIDTH, CHUNK_DEPTH ), CHUNK_HEIGHT )
	
?Threaded
	Const MAX_WORKER_THREADS:Int = 8
	
	Global WorkSemaphore:TSemaphore = CreateSemaphore( 0 )
	Global WorkList:TList = New TList
	Global WorkListMutex:TMutex = CreateMutex()
	
	Global DoneList:TList = New TList
	Global DoneListMutex:TMutex = CreateMutex()
	
	Global WorkerThreads:TThread[ MAX_WORKER_THREADS ]
	
	Global OnStartup:Int = TChunk.InitThreads()
?
	Field VertexData:Byte Ptr
	
	Field ChunkX:Int
	Field ChunkZ:Int
	
	Field GenerationCallback( Chunk:TChunk )
	
	Field VoxelData:Byte[ CHUNK_WIDTH + 4, CHUNK_HEIGHT, CHUNK_DEPTH + 4 ]
	Field Height:Byte[ CHUNK_WIDTH + 4, CHUNK_DEPTH + 4 ]
	Field  Light:Byte[ CHUNK_WIDTH + 4, CHUNK_HEIGHT, CHUNK_DEPTH + 4 ]
	
	Method New()
		Hidden = True
	End Method
	
	Method GenerateData()
		For Local Z:Int = 0 Until CHUNK_DEPTH + 4
			For Local Y:Int = 0 Until CHUNK_HEIGHT
				For Local X:Int = 0 Until CHUNK_WIDTH + 4
					Local TerrainX:Float = ( X + ( ChunkX + CHUNK_OFFSET )*CHUNK_WIDTH - 2 )*CHUNK_SCALE
					Local TerrainZ:Float = ( Z + ( ChunkZ + CHUNK_OFFSET )*CHUNK_DEPTH - 2 )*CHUNK_SCALE
					
					VoxelData[ X, CHUNK_HEIGHT - Y - 1, Z ] = GetTerrainBlock( TerrainX, Y*CHUNK_SCALE, TerrainZ )
				Next
			Next
		Next
		
		For Local Z:Int = 0 Until CHUNK_DEPTH + 4
			For Local X:Int = 0 Until CHUNK_WIDTH + 4
				For Local Y:Int = CHUNK_HEIGHT - 1 To 0 Step -1
					Height[ X, Z ] = Y
					
					If VoxelData[ X, Y, Z ] <> BLOCK_AIR Then Exit
				Next
			Next
		Next
		
		For Local Z:Int = 0 Until CHUNK_DEPTH + 2
			For Local X:Int = 0 Until CHUNK_WIDTH + 2
				For Local Y:Int = CHUNK_HEIGHT - 1 To 1 Step -1
					If VoxelData[ X + 1, Y, Z + 1 ] = BLOCK_AIR And VoxelData[ X + 1, Y - 1, Z + 1 ] = BLOCK_DIRT Then
						If Y < CHUNK_HEIGHT - 32 Then
							VoxelData[ X + 1, Y - 1, Z + 1 ] = BLOCK_GRASS
						Else
							VoxelData[ X + 1, Y - 1, Z + 1 ] = BLOCK_SNOW
						EndIf
					EndIf
				Next
			Next
		Next
		
		For Local Z:Int = 0 Until CHUNK_DEPTH
			For Local X:Int = 0 Until CHUNK_WIDTH
				For Local Y:Int = 0 Until CHUNK_HEIGHT
					Local InShadow:Int = ( Y < Height[ X + 2, Z + 2 ] ) 
					
					If InShadow Then
						For Local I:Int = 0 Until 25
							Light[ X + 2, Y, Z + 2 ] :+ 5*( Y > Height[ ( I Mod 5 ) + X, ( I  /  5 ) + Z ] )
						Next
					Else
						Light[ X + 2, Y, Z + 2 ] = 185
					EndIf
				Next
			Next
		Next
	End Method
	
	Method BuildMesh()
		VBO = TVertexBufferObject.Create( TVertexBufferObject.KIND_VERTEX_BUFFER )
		
		VBO.Bind()
		VBO.SetUsage( VBO.USAGE_STATIC, VBO.USAGE_DRAW )
		
		VBO.BufferData( VertexSize*VertexCount, VertexData )
		MemFree( VertexData )
		
		SetTexture( TBlockClass.BlockTexture, 0 )
		SetTexture( TBlockClass.AOTexture,    1 )
		
		Locate( ChunkX*CHUNK_WIDTH, 0, ChunkZ*CHUNK_DEPTH )
	End Method
	
	Method BuildVertexData()
		Local FaceCount:Int = 0
		For Local Z:Int = 0 Until CHUNK_DEPTH
			For Local Y:Int = 1 Until CHUNK_HEIGHT - 1
				For Local X:Int = 0 Until CHUNK_WIDTH
					If IsVisibleFace( X, Y, Z,  1,  0,  0 ) Then FaceCount :+ 1
					If IsVisibleFace( X, Y, Z, -1,  0,  0 ) Then FaceCount :+ 1
					If IsVisibleFace( X, Y, Z,  0,  1,  0 ) Then FaceCount :+ 1
					If IsVisibleFace( X, Y, Z,  0, -1,  0 ) Then FaceCount :+ 1
					If IsVisibleFace( X, Y, Z,  0,  0,  1 ) Then FaceCount :+ 1
					If IsVisibleFace( X, Y, Z,  0,  0, -1 ) Then FaceCount :+ 1
				Next
			Next
		Next
		
		VertexCount = 4*FaceCount
		VertexData  = MemAlloc( VertexSize*VertexCount )
		
		Local BufferLocation:Byte Ptr = VertexData
		For Local Z:Int = 0 Until CHUNK_DEPTH
			For Local Y:Int = 1 Until CHUNK_HEIGHT - 1
				For Local X:Int = 0 Until CHUNK_WIDTH
					If IsVisibleFace( X, Y, Z,  1,  0,  0 ) Then BufferLocation = RenderBlockFaceIntoBuffer( BufferLocation, X, Y, Z,  1,  0,  0 )
					If IsVisibleFace( X, Y, Z, -1,  0,  0 ) Then BufferLocation = RenderBlockFaceIntoBuffer( BufferLocation, X, Y, Z, -1,  0,  0 )
					If IsVisibleFace( X, Y, Z,  0,  1,  0 ) Then BufferLocation = RenderBlockFaceIntoBuffer( BufferLocation, X, Y, Z,  0,  1,  0 )
					If IsVisibleFace( X, Y, Z,  0, -1,  0 ) Then BufferLocation = RenderBlockFaceIntoBuffer( BufferLocation, X, Y, Z,  0, -1,  0 )
					If IsVisibleFace( X, Y, Z,  0,  0,  1 ) Then BufferLocation = RenderBlockFaceIntoBuffer( BufferLocation, X, Y, Z,  0,  0,  1 )
					If IsVisibleFace( X, Y, Z,  0,  0, -1 ) Then BufferLocation = RenderBlockFaceIntoBuffer( BufferLocation, X, Y, Z,  0,  0, -1 )
				Next
			Next
		Next
	End Method
	
	Method RenderBlockFaceIntoBuffer:Byte Ptr( Buffer:Byte Ptr, X:Int, Y:Int, Z:Int, NX:Int, NY:Int, NZ:Int, Size:Float = 0.502 )
		Local Block:TBlockClass = TBlockClass.BlockArray[ VoxelData[ X + 2 + NX, Y + NY, Z + 2 + NZ ] ]
		
		Local FaceIndex:Int = ( NX = 1 ) + ( NZ = -1 )*2 + ( NZ = 1 )*3 + ( NY = -1 )*4 + ( NY = 1 )*5
		
		Local U0:Float = Block.FaceU[ FaceIndex ]
		Local U1:Float = U0 + TBlockClass.FACE_STEP
		Local V0:Float = Block.FaceV[ FaceIndex ]
		Local V1:Float = V0 + TBlockClass.FACE_STEP
		
		Local AOIndex:Int = TBlockClass.GetAOConfiguration( VoxelData, X + 2, Y, Z + 2, NX, -NY, -NZ )
		Local U2:Float = TBlockClass.AOU[ AOIndex ]
		Local U3:Float = U2 + TBlockClass.AO_STEP
		Local V2:Float = TBlockClass.AOV[ AOIndex ]
		Local V3:Float = V2 + TBlockClass.AO_STEP
		
		Local Shade:Int = 70
		
		Shade :+ Light[ X + 2, Y, Z + 2 ]
		
		If NY = -1 Then
			Buffer = RenderVertexIntoBuffer( Buffer, X + Size, Y - Size, Z + Size, NX, NY, NZ, U0, V0,, Shade, Shade, Shade,, U2, V2 )
			Buffer = RenderVertexIntoBuffer( Buffer, X - Size, Y - Size, Z + Size, NX, NY, NZ, U1, V0,, Shade, Shade, Shade,, U3, V2 )
			Buffer = RenderVertexIntoBuffer( Buffer, X - Size, Y - Size, Z - Size, NX, NY, NZ, U1, V1,, Shade, Shade, Shade,, U3, V3 )
			Buffer = RenderVertexIntoBuffer( Buffer, X + Size, Y - Size, Z - Size, NX, NY, NZ, U0, V1,, Shade, Shade, Shade,, U2, V3 )
		ElseIf NY = 1 Then
			Buffer = RenderVertexIntoBuffer( Buffer, X - Size, Y + Size, Z + Size, NX, NY, NZ, U0, V0,, Shade, Shade, Shade,, U2, V2 )
			Buffer = RenderVertexIntoBuffer( Buffer, X + Size, Y + Size, Z + Size, NX, NY, NZ, U1, V0,, Shade, Shade, Shade,, U3, V2 )
			Buffer = RenderVertexIntoBuffer( Buffer, X + Size, Y + Size, Z - Size, NX, NY, NZ, U1, V1,, Shade, Shade, Shade,, U3, V3 )
			Buffer = RenderVertexIntoBuffer( Buffer, X - Size, Y + Size, Z - Size, NX, NY, NZ, U0, V1,, Shade, Shade, Shade,, U2, V3 )
		ElseIf NZ = -1 Then
			Buffer = RenderVertexIntoBuffer( Buffer, X - Size, Y + Size, Z - Size, NX, NY, NZ, U0, V0,, Shade, Shade, Shade,, U2, V2 )
			Buffer = RenderVertexIntoBuffer( Buffer, X + Size, Y + Size, Z - Size, NX, NY, NZ, U1, V0,, Shade, Shade, Shade,, U3, V2 )
			Buffer = RenderVertexIntoBuffer( Buffer, X + Size, Y - Size, Z - Size, NX, NY, NZ, U1, V1,, Shade, Shade, Shade,, U3, V3 )
			Buffer = RenderVertexIntoBuffer( Buffer, X - Size, Y - Size, Z - Size, NX, NY, NZ, U0, V1,, Shade, Shade, Shade,, U2, V3 )
		ElseIf NZ = 1 Then
			Buffer = RenderVertexIntoBuffer( Buffer, X + Size, Y + Size, Z + Size, NX, NY, NZ, U0, V0,, Shade, Shade, Shade,, U2, V2 )
			Buffer = RenderVertexIntoBuffer( Buffer, X - Size, Y + Size, Z + Size, NX, NY, NZ, U1, V0,, Shade, Shade, Shade,, U3, V2 )
			Buffer = RenderVertexIntoBuffer( Buffer, X - Size, Y - Size, Z + Size, NX, NY, NZ, U1, V1,, Shade, Shade, Shade,, U3, V3 )
			Buffer = RenderVertexIntoBuffer( Buffer, X + Size, Y - Size, Z + Size, NX, NY, NZ, U0, V1,, Shade, Shade, Shade,, U2, V3 )
		ElseIf NX = -1 Then
			Buffer = RenderVertexIntoBuffer( Buffer, X - Size, Y + Size, Z + Size, NX, NY, NZ, U0, V0,, Shade, Shade, Shade,, U2, V2 )
			Buffer = RenderVertexIntoBuffer( Buffer, X - Size, Y + Size, Z - Size, NX, NY, NZ, U1, V0,, Shade, Shade, Shade,, U3, V2 )
			Buffer = RenderVertexIntoBuffer( Buffer, X - Size, Y - Size, Z - Size, NX, NY, NZ, U1, V1,, Shade, Shade, Shade,, U3, V3 )
			Buffer = RenderVertexIntoBuffer( Buffer, X - Size, Y - Size, Z + Size, NX, NY, NZ, U0, V1,, Shade, Shade, Shade,, U2, V3 )
		ElseIf NX = 1 Then
			Buffer = RenderVertexIntoBuffer( Buffer, X + Size, Y + Size, Z - Size, NX, NY, NZ, U0, V0,, Shade, Shade, Shade,, U2, V2 )
			Buffer = RenderVertexIntoBuffer( Buffer, X + Size, Y + Size, Z + Size, NX, NY, NZ, U1, V0,, Shade, Shade, Shade,, U3, V2 )
			Buffer = RenderVertexIntoBuffer( Buffer, X + Size, Y - Size, Z + Size, NX, NY, NZ, U1, V1,, Shade, Shade, Shade,, U3, V3 )
			Buffer = RenderVertexIntoBuffer( Buffer, X + Size, Y - Size, Z - Size, NX, NY, NZ, U0, V1,, Shade, Shade, Shade,, U2, V3 )
		EndIf
		
		Return Buffer
	End Method
	
	Method IsVisibleFace:Int( X:Int, Y:Int, Z:Int, NX:Int, NY:Int, NZ:Int )
		X :+ 2
		Z :+ 2
		
		If VoxelData[ X, Y, Z ] = BLOCK_AIR And VoxelData[ X + NX, Y + NY, Z + NZ ] <> BLOCK_AIR Then Return True
		
		Return False
	End Method
	
	Method IsBoundaryBlock:Int( X:Int, Y:Int, Z:Int )
		X :+ 2
		Z :+ 2
		
		If VoxelData[ X, Y, Z ] <> BLOCK_AIR Then
			Local MakeBlock:Int = ( VoxelData[ X + 1, Y, Z ] = BLOCK_AIR ) + ..
			                      ( VoxelData[ X - 1, Y, Z ] = BLOCK_AIR ) + ..
			                      ( VoxelData[ X, Y + 1, Z ] = BLOCK_AIR ) + ..
			                      ( VoxelData[ X, Y - 1, Z ] = BLOCK_AIR ) + ..
			                      ( VoxelData[ X, Y, Z + 1 ] = BLOCK_AIR ) + ..
			                      ( VoxelData[ X, Y, Z - 1 ] = BLOCK_AIR )
			
			If MakeBlock Then Return True
		EndIf
		
		Return False
	End Method
	
	Function CreateChunk( ChunkX:Int, ChunkZ:Int, GenerationCallback( Chunk:TChunk ) = Null )
		Local Chunk:TChunk = New TChunk
		
		Chunk.ChunkX = ChunkX
		Chunk.ChunkZ = ChunkZ
		
		Chunk.GenerationCallback = GenerationCallback

?Threaded
		WorkListMutex.Lock()
			WorkList.AddFirst( Chunk )
		WorkListMutex.Unlock()
		
		WorkSemaphore.Post()
?
?Not Threaded
		Chunk.GenerateData()
		Chunk.BuildVertexData()
		Chunk.BuildMesh()
		
		Chunk.Hidden = False
		
		If GenerationCallback <> Null Then GenerationCallback( Chunk )
?
	End Function
	
	Function UpdateChunks()
?Threaded
		DoneListMutex.Lock()
			Rem
			For Local Chunk:TChunk = EachIn DoneList
				Chunk.BuildMesh()
				
				Chunk.Hidden = False
				
				If Chunk.GenerationCallback <> Null Then Chunk.GenerationCallback( Chunk )
			Next
			
			DoneList.Clear()
			End Rem
			
			Local Chunk:TChunk = TChunk( DoneList.First() )
			
			If Chunk Then
				Chunk.BuildMesh()
				
				Chunk.Hidden = False
				
				If Chunk.GenerationCallback <> Null Then Chunk.GenerationCallback( Chunk )
				
				DoneList.Remove( Chunk )
			EndIf
		DoneListMutex.Unlock()
?
	End Function
	
?Threaded
	Function InitThreads()
		For Local I:Int = 0 Until MAX_WORKER_THREADS
			WorkerThreads[ I ] = CreateThread( WaitForWork, Null )
		Next
	End Function
	
	Function WaitForWork:Object( Data:Object )
		While True
			WorkSemaphore.Wait()
			
			WorkListMutex.Lock()
				Local Chunk:TChunk = TChunk( WorkList.RemoveLast() )
			WorkListMutex.Unlock()
			
			Chunk.GenerateData()
			Chunk.BuildVertexData()
			
			DoneListMutex.Lock()
				DoneList.AddLast( Chunk )
			DoneListMutex.Unlock()
		Wend
	End Function
?
End Type