Type TTexture2D
	Field GLName:Int
	
	Field Width:Int
	Field Height:Int
	
	Field Path:String
	
	Method SetState()
		glBindTexture( GL_TEXTURE_2D, GLName )
	End Method
	
	Method UnsetState()
		glBindTexture( GL_TEXTURE_2D, 0 )
	End Method
	
	Function Load:TTexture2D( Path:String )
		Local Pixmap:TPixmap = LoadPixmap( Path )
		
		If Pixmap Then
			Local Texture:TTexture2D = New TTexture2D
			
			Texture.Width  = Pixmap.Width
			Texture.Height = Pixmap.Height
			Texture.Path   = Path
			Texture.GLName = GLTexFromPixmap( Pixmap )
			
			Return Texture
		EndIf
		
		Return Null
	End Function
End Type
