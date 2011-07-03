SuperStrict

Import "Perlin.cpp"

SeedRnd(MilliSecs())

Extern
	Function GetNoise1D:Float( X:Float,                   Octave:Int, PerlinTable:Byte Ptr )
	Function GetNoise2D:Float( X:Float, Y:Float,          Octave:Int, PerlinTable:Byte Ptr )
	Function GetNoise3D:Float( X:Float, Y:Float, Z:Float, Octave:Int, PerlinTable:Byte Ptr )
End Extern

Function CreatePerlinTable:Float[]()
	Local Randoms:Float[ $10000 ]
	
	For Local I:Int = 0 Until $10000
		Randoms[ I ] = Rnd( -1.0, 1.0 )
	Next
	
	Return Randoms
End Function