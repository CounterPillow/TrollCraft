Const BLOCK_AIR  :Int = 0
Const BLOCK_STONE:Int = 1
Const BLOCK_GRASS:Int = 2
Const BLOCK_DIRT :Int = 3
Const BLOCK_WATER:Int = 8
Const BLOCK_SAND :Int = 12
Const BLOCK_GOLD :Int = 14
Const BLOCK_IRON :Int = 15
Const BLOCK_SNOW :Int = 78

Const DENSITY_IRON:Float = 0.2
Const DENSITY_GOLD:Float = 0.2

Global Generators:Float[][]

For Local I:Int = 0 Until 20
	Generators :+ [ CreatePerlinTable() ]
Next

Function GenerateTerrainVolume( W:Int, H:Int, D:Int )
	Local Volume:Byte[ W, H, D ]
	
	For Local Z:Int = 0 Until D
		For Local Y:Int = 0 Until H
			For Local X:Int = 0 Until W
				Volume[ X, Y, Z ] = GetTerrainBlock( X*1.0/128.0, Y*1.0/128.0, Z*1.0/128.0 )
			Next
		Next
	Next
	
	
End Function

Function WriteVolumeToStream( StartX:Int, StartY:Int, StartZ:Int, W:Int, H:Int, D:Int, Stream:TStream )
	For Local X:Int = StartX Until StartX + W
		For Local Z:Int = StartZ Until StartZ + D
			For Local Y:Int = StartY + H - 1 To StartY Step -1
				Stream.WriteByte( GetTerrainBlock( X*1.0/128.0, Y*1.0/128.0, Z*1.0/128.0 ) )
			Next
		Next
	Next
End Function

Function GetTerrainBlock:Int( VoxelX:Float, VoxelY:Float, VoxelZ:Float )
	Local WaterLevel:Float = 0.3125
	
	Local TerrainFrequency:Float = 2.0
	Local Height:Float = ( 1.0 - VoxelY ) - Abs(    GetNoise3D( VoxelX*TerrainFrequency, VoxelY*TerrainFrequency, VoxelZ*TerrainFrequency, 4, Byte Ptr Generators[ 0 ] )*0.2 ) ..
	                                      - ( 1.0 + GetNoise3D( VoxelX*TerrainFrequency, VoxelY*TerrainFrequency, VoxelZ*TerrainFrequency, 5, Byte Ptr Generators[ 8 ] ) )*0.5
	
	Local Cell:Int = BLOCK_AIR
	
	Local HeightThreshold:Float = -0.1'Abs( GetNoise2D( VoxelX, VoxelZ, 1, Generators[ 9 ] ) )*0.1 + 0.6
	
	If Height < HeightThreshold + 0.05 Then
		Local PerturbanceFrequency:Float = 6
		Local CaveX:Float = VoxelX + GetNoise3D( VoxelX*PerturbanceFrequency, VoxelY*PerturbanceFrequency, VoxelZ*PerturbanceFrequency, 3, Byte Ptr Generators[ 1 ] )*0.25
		Local CaveY:Float = VoxelY + GetNoise3D( VoxelX*PerturbanceFrequency, VoxelY*PerturbanceFrequency, VoxelZ*PerturbanceFrequency, 3, Byte Ptr Generators[ 2 ] )*0.25
		Local CaveZ:Float = VoxelZ + GetNoise3D( VoxelX*PerturbanceFrequency, VoxelY*PerturbanceFrequency, VoxelZ*PerturbanceFrequency, 3, Byte Ptr Generators[ 3 ] )*0.25
		
		Local CaveFrequency:Float = 2.0
		Local Cave:Int = 1.0 - Abs( GetNoise3D( CaveX*CaveFrequency, CaveY*CaveFrequency, CaveZ*CaveFrequency, 1, Byte Ptr Generators[ 4 ] ) ) > 0.95
		      Cave    :* 1.0 - Abs( GetNoise3D( CaveX*CaveFrequency, CaveY*CaveFrequency, CaveZ*CaveFrequency, 1, Byte Ptr Generators[ 5 ] ) ) > 0.95
		
		If Cave Then
			Cell = BLOCK_AIR
		ElseIf Height < HeightThreshold Then
			Cell = BLOCK_STONE
			
			Local GoldFrequency:Float = 20.0
			Local GoldChance:Float = ( 1.0 + GetNoise3D( VoxelX*GoldFrequency, VoxelY*GoldFrequency, VoxelZ*GoldFrequency, 3, Byte Ptr Generators[ 6 ] ) )*0.5
			
			If GoldChance*VoxelY*0.667 > 1.0 - DENSITY_GOLD Then
				Cell = BLOCK_GOLD
			Else
				Local IronFrequency:Float = 20.0
				Local IronChance:Float = ( 1.0 + GetNoise3D( VoxelX*IronFrequency, VoxelY*IronFrequency, VoxelZ*IronFrequency, 3, Byte Ptr Generators[ 7 ] ) )*0.5
				
				If IronChance > 1.0 - DENSITY_IRON Then Cell = BLOCK_IRON
			EndIf
		Else
			If VoxelY >= 1.0 - WaterLevel Then Cell = BLOCK_SAND Else Cell = BLOCK_DIRT
		EndIf
	Else
		If VoxelY >= 1.0 - WaterLevel Then Cell = BLOCK_WATER Else Cell = BLOCK_AIR
	EndIf
	
	Return Cell
End Function