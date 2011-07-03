Type TLight Extends TEntity
	Const COLOR_SCALE:Float = 1.0/256.0
	
	Const KIND_DIRECTIONAL:Int = 1
	Const KIND_POINT      :Int = 2
	Const KIND_SPOT       :Int = 3
	
	Const DEFAULT_RANGE:Float = 100.0
	Const DEFAULT_GAMMA:Float = 30.0
	Const DEFAULT_THETA:Float = 45.0
	
	Global AmbientColor:TVector4 = Vec3( 128, 128, 128 )
	
	Field Kind:Int
	
	Field Color:TVector4
	
	Field Range:Float
	
	Field Gamma:Float, Theta:Float
	
	Method New()
		TRenderer.Lights.AddLast( Self )
		
		Color = Vec3( 255.0, 255.0, 255.0 )
		
		Range = DEFAULT_RANGE
		Gamma = DEFAULT_GAMMA
		Theta = DEFAULT_THETA
	End Method
	
	Method SetColor( R:Int, G:Int, B:Int )
		Color = Vec3( R, G, B )
	End Method
	
	Method SetRange( Range:Float )
		Self.Range = Range
	End Method
	
	Method SetConeAngles( Gamma:Float, Theta:Float )
		Self.Gamma = Gamma
		Self.Theta = Theta
	End Method
	
	Method SetState( LightIndex:Int )
		EnableLight( LightIndex )
		
		Local DiffuseArray:Float[] = [ ..
			Color.X*COLOR_SCALE, ..
			Color.Y*COLOR_SCALE, ..
			Color.Z*COLOR_SCALE, ..
			Color.W ..
		]
		
		glLightfv( LightIndex, GL_DIFFUSE, Float Ptr DiffuseArray )
		
		Select Kind
			Case KIND_DIRECTIONAL
				glLightfv( LightIndex, GL_POSITION, Float Ptr [ 0.0, 0.0, 1.0, 0.0 ] )
				glLightf( LightIndex, GL_CONSTANT_ATTENUATION, 1.0 )
				glLightf( LightIndex, GL_LINEAR_ATTENUATION, 0.0 )
				glLightf( LightIndex, GL_QUADRATIC_ATTENUATION, 0.0 )
			Case KIND_POINT
				glLightfv( LightIndex, GL_POSITION, Float Ptr [ 0.0, 0.0, 0.0, 1.0 ] )
				glLightf( LightIndex, GL_CONSTANT_ATTENUATION, 0.0 )
				glLightf( LightIndex, GL_LINEAR_ATTENUATION, 1.0/Range )
				glLightf( LightIndex, GL_QUADRATIC_ATTENUATION, 0.0 )
			Case KIND_SPOT
				glLightfv( LightIndex, GL_POSITION, Float Ptr [ 0.0, 0.0, 0.0, 1.0 ] )
				glLightfv( LightIndex, GL_SPOT_DIRECTION, Float Ptr [ 0.0, 0.0, 1.0, 1.0 ] )
				glLightf( LightIndex, GL_CONSTANT_ATTENUATION, 0.0 )
				glLightf( LightIndex, GL_LINEAR_ATTENUATION, 1.0/Range )
				glLightf( LightIndex, GL_QUADRATIC_ATTENUATION, 0.0 )
				glLightf( LightIndex, GL_SPOT_CUTOFF, Gamma )
				glLightf( LightIndex, GL_SPOT_EXPONENT, Theta )
		End Select
	End Method
	
	Function SetStateAmbient( LightIndex:Int )
		Local AmbientArray:Float[] = [ ..
			AmbientColor.X*COLOR_SCALE, ..
			AmbientColor.Y*COLOR_SCALE, ..
			AmbientColor.Z*COLOR_SCALE, ..
			AmbientColor.W ..
		]
		
		EnableLight( LightIndex )
		glLightfv( LightIndex, GL_AMBIENT, Float Ptr AmbientArray )
	End Function
	
	Function EnableLight( LightIndex:Int )
		glEnable( LightIndex )
		
		Local NullBuffer:Float[] = [ 0.0, 0.0, 0.0, 0.0 ]
		
		glLightfv( LightIndex, GL_AMBIENT,  Float Ptr NullBuffer )
		glLightfv( LightIndex, GL_DIFFUSE,  Float Ptr NullBuffer )
		glLightfv( LightIndex, GL_SPECULAR, Float Ptr NullBuffer )
	End Function
	
	Function SetAmbientColor( R:Int, G:Int, B:Int )
		AmbientColor = Vec3( R, G, B )
	End Function
	
	Function Create:TLight( Kind:Int )
		Local Light:TLight = New TLight
		
		Light.Kind = Kind
		
		Return Light
	End Function
End Type
