Function TFormVector:TVector4( V:TVector4, Source:TEntity = Null, Dest:TEntity = Null )
	Return TEntity.TFormVector( V, Source, Dest )
End Function

Function TFormPoint:TVector4( V:TVector4, Source:TEntity = Null, Dest:TEntity = Null )
	Return TEntity.TFormPoint( V, Source, Dest )
End Function

Function TFormNormal:TVector4( V:TVector4, Source:TEntity = Null, Dest:TEntity = Null )
	Return TEntity.TFormNormal( V, Source, Dest )
End Function

Type TEntity
	Field Parent:TEntity
	
	Field Position  :TVector4
	Field Scaling   :TVector4
	Field InvScaling:TVector4
	
	Field Rotation   :TMatrix4
	Field InvRotation:TMatrix4
	
	Field FinalTransform    :TMatrix4
	Field InvFinalTransform :TMatrix4
	
	Field VectorTransform   :TMatrix4
	Field InvVectorTransform:TMatrix4
	
	Field NormalTransform   :TMatrix4
	Field InvNormalTransform:TMatrix4
	
	Method New()
		Position    = Vec3( 0.0, 0.0, 0.0 )
		Scaling     = Vec3( 1.0, 1.0, 1.0 )
		InvScaling  = Vec3( 1.0, 1.0, 1.0 )
		
		Rotation    = New TMatrix4.Identity()
		InvRotation = New TMatrix4.Identity()
	End Method
	
	Method Turn( X:Float, Y:Float, Z:Float )
		   Rotation = New TMatrix4.RotZXY( X, Y, Z ).MatMult( Rotation )
		InvRotation = InvRotation.MatMult( New TMatrix4.RotYXZ( -X, -Y, -Z ) )
		
		ResetAllTransforms()
	End Method
	
	Method Move( X:Float, Y:Float, Z:Float, GlobalSystem:Int = False )
		Local Move:TVector4 = Vec3( X, Y, Z )
		
		If Not GlobalSystem Then Move = TFormVector( Move, Self, Null )
		
		Position.Plus( Move )
		
		ResetFinalTransform()
	End Method
	
	Method Rotate( X:Float, Y:Float, Z:Float )
		   Rotation = New TMatrix4.RotZXY( X, Y, Z )
		InvRotation = New TMatrix4.RotYXZ( -X, -Y, -Z )
		
		ResetAllTransforms()
	End Method
	
	Method Locate( X:Float, Y:Float, Z:Float )
		Position = Vec3( X, Y, Z )
		
		ResetFinalTransform()
	End Method
	
	Method Scale( X:Float, Y:Float, Z:Float )
		   Scaling = Vec3(     X,     Y,     Z )
		InvScaling = Vec3( 1.0/X, 1.0/Y, 1.0/Z )
		
		ResetAllTransforms()
	End Method

	Method SetParent( Entity:TEntity )
		Parent = Entity
	End Method
	
	Method GetTransform:TMatrix4()
		If Not FinalTransform Then
			Local TransMat:TMatrix4 = New TMatrix4.Translate( Position.X, Position.Y, Position.Z )
			Local ScaleMat:TMatrix4 = TMatrix4.Dummy.Scale( Scaling.X, Scaling.Y, Scaling.Z )
			
			FinalTransform = TransMat.MatMult( Rotation ).MatMult( ScaleMat )
		EndIf
		
		Return FinalTransform
	End Method
	
	Method GetInvTransform:TMatrix4()
		If Not InvFinalTransform Then
			Local TransMat:TMatrix4 = TMatrix4.Dummy.Translate( -Position.X, -Position.Y, -Position.Z )
			Local ScaleMat:TMatrix4 = New TMatrix4.Scale( InvScaling.X, InvScaling.Y, InvScaling.Z )
			
			InvFinalTransform = ScaleMat.MatMult( InvRotation ).MatMult( TransMat )
		EndIf
		
		Return InvFinalTransform
	End Method
	
	Method GetVectorTransform:TMatrix4()
		If Not VectorTransform Then
			Local ScaleMat:TMatrix4 = TMatrix4.Dummy.Scale( Scaling.X, Scaling.Y, Scaling.Z )
			
			VectorTransform = Rotation.Copy().MatMult( ScaleMat )
		EndIf
		
		Return VectorTransform
	End Method
	
	Method GetInvVectorTransform:TMatrix4()
		If Not InvVectorTransform Then
			Local ScaleMat:TMatrix4 = New TMatrix4.Scale( InvScaling.X, InvScaling.Y, InvScaling.Z )
			
			InvVectorTransform = ScaleMat.MatMult( InvRotation )
		EndIf
		
		Return InvVectorTransform
	End Method
	
	Method GetNormalTransform:TMatrix4()
		If Not NormalTransform Then
			Local ScaleMat:TMatrix4 = TMatrix4.Dummy.Scale( InvScaling.X, InvScaling.Y, InvScaling.Z )
			
			NormalTransform = Rotation.Copy().MatMult( ScaleMat )
		EndIf
		
		Return NormalTransform
	End Method
	
	Method GetInvNormalTransform:TMatrix4()
		If Not InvNormalTransform Then
			Local ScaleMat:TMatrix4 = New TMatrix4.Scale( Scaling.X, Scaling.Y, Scaling.Z )
			
			InvNormalTransform = ScaleMat.MatMult( InvRotation )
		EndIf
		
		Return InvNormalTransform
	End Method
	
	Method ResetFinalTransform()
		   FinalTransform = Null
		InvFinalTransform = Null
	End Method
	
	Method ResetAllTransforms()
		    FinalTransform = Null
		 InvFinalTransform = Null
		   VectorTransform = Null
		InvVectorTransform = Null
		   NormalTransform = Null
		InvNormalTransform = Null
	End Method

	Function TFormVector:TVector4( V:TVector4, Source:TEntity = Null, Dest:TEntity = Null )
		If Source Then Source.GetVectorTransform().VecMult( V )
	
		If Dest Then V = Dest.GetInvVectorTransform().VecMult( V )
	
		Return V
	End Function
	
	Function TFormPoint:TVector4( V:TVector4, Source:TEntity = Null, Dest:TEntity = Null )
		If Source Then Source.GetTransform().VecMult( V )
	
		If Dest Then V = Dest.GetInvTransform().VecMult( V )
	
		Return V
	End Function
	
	Function TFormNormal:TVector4( V:TVector4, Source:TEntity = Null, Dest:TEntity = Null )
		If Source Then Source.GetNormalTransform().VecMult( V )
	
		If Dest Then V = Dest.GetInvNormalTransform().VecMult( V )
	
		Return V
	End Function
End Type