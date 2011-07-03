Type TRenderer
	Const COLOR_SCALE:Float = 1.0/256.0
	
	Global Camera:TCamera
	
	Global Meshes:TList = New TList
	Global Lights:TList = New TList
	
	Global GWidth :Int
	Global GHeight:Int
	
	Function RenderWorld()
		Local TransMatrix:Float Ptr
		glEnable( GL_DEPTH_TEST )
		
		glClearColor( Camera.ClsColor.X*COLOR_SCALE, Camera.ClsColor.Y*COLOR_SCALE, Camera.ClsColor.Z*COLOR_SCALE, Camera.ClsColor.W*COLOR_SCALE )
		glClear( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT )
		
		If Camera.FogMode = Camera.FOG_ENABLED Then
			glEnable( GL_FOG )
			
			glFogi( GL_FOG_MODE, GL_LINEAR )
			glFogf( GL_FOG_START, Camera.FogRangeMin )
			glFogf( GL_FOG_END, Camera.FogRangeMax )
			glFogfv( GL_FOG_COLOR, Float Ptr [ Camera.FogColor.X*COLOR_SCALE, Camera.FogColor.Y*COLOR_SCALE, Camera.FogColor.Z*COLOR_SCALE, Camera.FogColor.W*COLOR_SCALE ] )
		Else
			glDisable( GL_FOG )
		EndIf
		
		glMatrixMode( GL_PROJECTION )
		'glLoadMatrixf( Camera.ProjectionMatrix.A )
		glLoadIdentity()
		gluPerspective(Camera.AOV, Camera.ViewportW/Float( Camera.ViewportH ), Camera.DepthRangeMin, Camera.DepthRangeMax )
		
		glMatrixMode( GL_MODELVIEW )
		
		glLoadIdentity()
		
		TransMatrix = Camera.GetInvTransform().A
		
		glEnable( GL_LIGHTING )
		glEnable( GL_COLOR_MATERIAL )
		glShadeModel( GL_SMOOTH )
		
		TLight.SetStateAmbient( GL_LIGHT0 )
		
		Local LightIndex:Int = GL_LIGHT1
		For Local Light:TLight = EachIn Lights
			If LightIndex - GL_LIGHT0 >= GL_MAX_LIGHTS Then Exit
			
			glLoadMatrixf( TransMatrix )
			glMultMatrixf( Light.GetVectorTransform().A )
			
			Light.SetState( LightIndex )
			
			LightIndex :+ 1
		Next
		
		glEnable( GL_CULL_FACE )
		glCullFace( GL_FRONT )
		
		For Local Mesh:TMesh = EachIn Meshes
			If Not Mesh.Hidden Then
				glLoadMatrixf( TransMatrix )
				glMultMatrixf( Mesh.GetTransform().A )
				
				Mesh.Draw()
			EndIf
		Next
	End Function
	
	Function Graphics3D( pGWidth:Int, pGHeight:Int )
		GWidth  = pGWidth
		GHeight = pGHeight
		
		GLGraphics GWidth, GHeight, 32
		
		glewInit()
	End Function
End Type