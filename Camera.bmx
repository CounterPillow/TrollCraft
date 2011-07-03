Type TCamera Extends TEntity
	Const FOG_DISABLED:Int = False
	Const FOG_ENABLED :Int = True
	
	Const DEFAULT_AOV:Float = 60.0
	
	Const DEFAULT_DEPTH_MIN:Float = 1.0
	Const DEFAULT_DEPTH_MAX:Float = 100.0
	
	Field AOV:Float
	
	Field ClsColor:TVector4
	
	Field FogColor:TVector4
	Field FogMode:Int
	Field FogRangeMin:Float, FogRangeMax:Float
	
	Field DepthRangeMin:Float, DepthRangeMax:Float
	
	Field ViewportX:Int, ViewportY:Int, ViewportW:Int, ViewportH:Int
	
	Field ProjectionMatrix:TMatrix4
	
	Method New()
		TRenderer.Camera = Self
		
		AOV = DEFAULT_AOV
		
		ClsColor = Vec3( 0.0, 0.0, 0.0 )
		FogColor = Vec3( 0.0, 0.0, 0.0 )
		
		FogMode = FOG_DISABLED
		
		FogRangeMin = DEFAULT_DEPTH_MIN
		FogRangeMax = DEFAULT_DEPTH_MAX
		
		DepthRangeMin = DEFAULT_DEPTH_MIN
		DepthRangeMax = DEFAULT_DEPTH_MAX
		
		ProjectionMatrix = New TMatrix4
		
		'RebuildProjection()
	End Method
	
	Method SetAOV( Angle:Float )
		AOV = Angle
		
		'RebuildProjection()
	End Method
	
	Method SetClsColor( R:Int, G:Int, B:Int )
		ClsColor = Vec3( R, G, B )
	End Method
	
	Method SetFogColor( R:Int, G:Int, B:Int )
		FogColor = Vec3( R, G, B )
	End Method
	
	Method SetFogEnabled( Mode:Int )
		FogMode = ( Mode <> 0 )
	End Method
	
	Method SetFogRange( RangeMin:Float, RangeMax:Float )
		FogRangeMin = RangeMin
		FogRangeMax = RangeMax
	End Method
	
	Method SetRange( RangeMin:Float, RangeMax:Float )
		DepthRangeMin = RangeMin
		DepthRangeMax = RangeMax
		
		'RebuildProjection()
	End Method
	
	Method SetViewport( X:Int, Y:Int, W:Int, H:Int )
		ViewportX = X
		ViewportY = Y
		ViewportW = W
		ViewportH = H
		
		'RebuildProjection()
	End Method
	
	Method Project:TVector4( Vector:TVector4 )
		Return ProjectionMatrix.VecMult( Vector.Copy() )
	End Method
	
	Rem
	Method RebuildProjection()
		ProjectionMatrix.Perspective( AOV, ViewportW/Float( ViewportH ), DepthRangeMin, DepthRangeMax )
	End Method
	EndRem
	
	Function Create:TCamera()
		Return New TCamera
	End Function
End Type
