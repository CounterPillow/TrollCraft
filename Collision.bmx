Type TBox Extends TEntity
	Field Collisions:TCollision[]
	
	Method GetCurrentChunk:TChunk()
		Local Chunk:TChunk
		For Chunk:TChunk = EachIn TRenderer.Meshes
			If Parent.Position.X > Chunk.Position.X And Parent.Position.X < Chunk.Position.X + Chunk.CHUNK_WIDTH
				If Parent.Position.Z > Chunk.Position.Z And Parent.Position.Z < Chunk.Position.Z + Chunk.CHUNK_DEPTH
					Return Chunk
				EndIf
			EndIf
		Next
	End Method
	
	Method UpdateCollisions()
		Local W:Float = Scaling.X
		Local H:Float = Scaling.Y
		Local D:Float = Scaling.Z
		Local Chunk:TChunk = GetCurrentChunk()
		Local RelPosition:TVector4 = Vec3(Parent.Position.X - Chunk.Position.X, Parent.Position.Y - Chunk.Position.Y, Parent.Position.Z - Chunk.Position.Z)
		
		If Chunk.VoxelData[Int(RelPosition.X), Int(RelPosition.Y - H / 2) - 1.0, Int(RelPosition.Z)] <> BLOCK_AIR		'BOTTOM
			Collisions[0] = New TCollision
			Collisions[0].Material = Chunk.VoxelData[Int(RelPosition.X), Int(RelPosition.Y - H / 2) - 1.0, Int(RelPosition.Z)]
		Else
			Collisions[0] = Null
		EndIf
		If Chunk.VoxelData[Int(RelPosition.X), Int(RelPosition.Y + H / 2) + 1.0, Int(RelPosition.Z)] <> BLOCK_AIR
			Collisions[1] = New TCollision
			Collisions[1].Material = Chunk.VoxelData[Int(RelPosition.X), Int(RelPosition.Y + H / 2) + 1.0, Int(RelPosition.Z)]
		Else
			Collisions[1] = Null
		EndIf
		
	End Method
	
	Function Create:TBox(p:TEntity)
		Local Box:TBox = New TBox
		Box.Parent = p
		Box.Collisions = New TCollision[6]
		Return Box
	End Function
End Type

Type TCollision
	Field Material:Byte
End Type