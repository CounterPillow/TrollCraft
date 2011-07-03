SuperStrict

Function Vec3:TVector4( X:Float, Y:Float, Z:Float )
	Return TVector4.Vec3( X, Y, Z )
End Function

Function Vec4:TVector4( X:Float, Y:Float, Z:Float, W:Float )
	Return TVector4.Vec4( X, Y, Z, W )
End Function

Type TVector4
	Field X:Float
	Field Y:Float
	Field Z:Float
	Field W:Float
	
	Method Plus:TVector4( B:TVector4 )
		X :+ B.X
		Y :+ B.Y
		Z :+ B.Z
		
		Return Self
	End Method
	
	Method Minus:TVector4( B:TVector4 )
		X :- B.X
		Y :- B.Y
		Z :- B.Z
		
		Return Self
	End Method
	
	Method Mult:TVector4( Scalar:Float )
		X :* Scalar
		Y :* Scalar
		Z :* Scalar
		
		Return Self
	End Method
	
	Method Div:TVector4( Scalar:Float )
		X :/ Scalar
		Y :/ Scalar
		Z :/ Scalar
		
		Return Self
	End Method
	
	Method Dot:Float( B:TVector4 )
		Return X*B.X + Y*B.Y + Z*B.Z
	End Method
	
	Method Cross:TVector4( B:TVector4 )
		Local NewX:Float = Y*B.Z - Z*B.Y
		Local NewY:Float = Z*B.X - X*B.Z
		Local NewZ:Float = X*B.Y - Y*B.X
		
		X = NewX
		Y = NewY
		Z = NewZ
		
		Return Self
	End Method
	
	Method Invert:TVector4()
		X = 1.0/X
		Y = 1.0/Y
		Z = 1.0/Z
		
		Return Self
	End Method
	
	Method LengthSq:Float()
		Return X*X + Y*Y + Z*Z
	End Method
	
	Method Copy:TVector4()
		Return Vec4( X, Y, Z, W )
	End Method
	
	Method ToString:String()
		Return "( " + PaddedNumber( X ) + PaddedNumber( Y ) + PaddedNumber( Z ) + PaddedNumber( W ) + ")"
		
		Function PaddedNumber:String( Number:Float )
			If Number < 0.0 Then Return String.FromFloat( Number )[ .. 8 ] + " " Else Return " " + String.FromFloat( Number )[ .. 7 ] + " "
		End Function
	End Method
	
	Method Set( X:Float, Y:Float, Z:Float, W:Float = 1.0 )
		Self.X = X
		Self.Y = Y
		Self.Z = Z
		Self.W = W
	End Method
	
	Function Vec3:TVector4( X:Float, Y:Float, Z:Float )
		Local Vector:TVector4 = New TVector4
			Vector.X = X
			Vector.Y = Y
			Vector.Z = Z
			Vector.W = 1.0
		
		Return Vector
	End Function
	
	Function Vec4:TVector4( X:Float, Y:Float, Z:Float, W:Float )
		Local Vector:TVector4 = New TVector4
			Vector.X = X
			Vector.Y = Y
			Vector.Z = Z
			Vector.W = W
		
		Return Vector
	End Function
End Type

Type TMatrix4
	Global Dummy:TMatrix4 = New TMatrix4
	
	Const A11:Int = 0, A12:Int = 4, A13:Int =  8, A14:Int = 12
	Const A21:Int = 1, A22:Int = 5, A23:Int =  9, A24:Int = 13
	Const A31:Int = 2, A32:Int = 6, A33:Int = 10, A34:Int = 14
	Const A41:Int = 3, A42:Int = 7, A43:Int = 11, A44:Int = 15
	
	Field A:Float Ptr
	
	Method New()
		A = Float Ptr MemAlloc( 64 )
	End Method
	
	Method Delete()
		MemFree( A )
	End Method
	
	Method Copy:TMatrix4()
		Local Other:TMatrix4 = New TMatrix4
		
		MemCopy( Other.A, A, 64 )
		
		Return Other
	End Method
	
	Method Transpose:TMatrix4()
		Local T12:Float = A[ A12 ], T13:Float = A[ A13 ], T14:Float = A[ A14 ], ..
		                            T23:Float = A[ A23 ], T24:Float = A[ A24 ], ..
		                                                  T34:Float = A[ A34 ]
		
		
		                A[ A12 ] = A[ A21 ]; A[ A13 ] = A[ A31 ]; A[ A14 ] = A[ A41 ]
		A[ A21 ] = T12;                      A[ A23 ] = A[ A32 ]; A[ A24 ] = A[ A42 ]
		A[ A31 ] = T13; A[ A32 ] =    T23  ;                      A[ A34 ] = 0.0
		A[ A41 ] = T14; A[ A42 ] =    T24  ; A[ A43 ] =    T34
		
		Return Self
	End Method
	
	Method Identity:TMatrix4()
		A[ A11 ] = 1.0; A[ A12 ] = 0.0; A[ A13 ] = 0.0; A[ A14 ] = 0.0
		A[ A21 ] = 0.0; A[ A22 ] = 1.0; A[ A23 ] = 0.0; A[ A24 ] = 0.0
		A[ A31 ] = 0.0; A[ A32 ] = 0.0; A[ A33 ] = 1.0; A[ A34 ] = 0.0
		A[ A41 ] = 0.0; A[ A42 ] = 0.0; A[ A43 ] = 0.0; A[ A44 ] = 1.0
		
		Return Self
	End Method
	
	Method Scale:TMatrix4( X:Float, Y:Float, Z:Float )
		A[ A11 ] =   X; A[ A12 ] = 0.0; A[ A13 ] = 0.0; A[ A14 ] = 0.0
		A[ A21 ] = 0.0; A[ A22 ] =   Y; A[ A23 ] = 0.0; A[ A24 ] = 0.0
		A[ A31 ] = 0.0; A[ A32 ] = 0.0; A[ A33 ] =   Z; A[ A34 ] = 0.0
		A[ A41 ] = 0.0; A[ A42 ] = 0.0; A[ A43 ] = 0.0; A[ A44 ] = 1.0
		
		Return Self
	End Method
	
	Method Translate:TMatrix4( X:Float, Y:Float, Z:Float )
		A[ A11 ] = 1.0; A[ A12 ] = 0.0; A[ A13 ] = 0.0; A[ A14 ] = X
		A[ A21 ] = 0.0; A[ A22 ] = 1.0; A[ A23 ] = 0.0; A[ A24 ] = Y
		A[ A31 ] = 0.0; A[ A32 ] = 0.0; A[ A33 ] = 1.0; A[ A34 ] = Z
		A[ A41 ] = 0.0; A[ A42 ] = 0.0; A[ A43 ] = 0.0; A[ A44 ] = 1.0
		
		Return Self
	End Method
	
	Method RotX:TMatrix4( O:Float )
		Local C:Float = Cos( O )
		Local S:Float = Sin( O )
		
		A[ A11 ] = 1.0; A[ A12 ] = 0.0; A[ A13 ] = 0.0; A[ A14 ] = 0.0
		A[ A21 ] = 0.0; A[ A22 ] =   C; A[ A23 ] =  -S; A[ A24 ] = 0.0
		A[ A31 ] = 0.0; A[ A32 ] =   S; A[ A33 ] =   C; A[ A34 ] = 0.0
		A[ A41 ] = 0.0; A[ A42 ] = 0.0; A[ A43 ] = 0.0; A[ A44 ] = 1.0
		
		Return Self
	End Method
	
	Method RotY:TMatrix4( O:Float )
		Local C:Float = Cos( O )
		Local S:Float = Sin( O )
		
		A[ A11 ] =   C; A[ A12 ] = 0.0; A[ A13 ] =  -S; A[ A14 ] = 0.0
		A[ A21 ] = 0.0; A[ A22 ] = 1.0; A[ A23 ] = 0.0; A[ A24 ] = 0.0
		A[ A31 ] =   S; A[ A32 ] = 0.0; A[ A33 ] =   C; A[ A34 ] = 0.0
		A[ A41 ] = 0.0; A[ A42 ] = 0.0; A[ A43 ] = 0.0; A[ A44 ] = 1.0
		
		Return Self
	End Method
	
	Method RotZ:TMatrix4( O:Float )
		Local C:Float = Cos( O )
		Local S:Float = Sin( O )
		
		A[ A11 ] =   C; A[ A12 ] =  -S; A[ A13 ] = 0.0; A[ A14 ] = 0.0
		A[ A21 ] =   S; A[ A22 ] =   C; A[ A23 ] = 0.0; A[ A24 ] = 0.0
		A[ A31 ] = 0.0; A[ A32 ] = 0.0; A[ A33 ] = 1.0; A[ A34 ] = 0.0
		A[ A41 ] = 0.0; A[ A42 ] = 0.0; A[ A43 ] = 0.0; A[ A44 ] = 1.0
		
		Return Self
	End Method
	
	Method RotZXY:TMatrix4( X:Float, Y:Float, Z:Float )
		Return RotZ( Z ).MatMult( Dummy.RotX( X ) ).MatMult( Dummy.RotY( Y ) )
	End Method
	
	Method RotYXZ:TMatrix4( X:Float, Y:Float, Z:Float )
		Return RotY( Y ).MatMult( Dummy.RotX( X ) ).MatMult( Dummy.RotZ( Z ) )
	End Method
	
	Method Perspective:TMatrix4( AOV:Float, Aspect:Float, zNear:Float, zFar:Float )
		Local F:Float = 1.0/Tan( AOV*0.5 )
		
		A[ A11 ] = F/Aspect; A[ A12 ] = 0.0; A[ A13 ] =                               0.0; A[ A14 ] = 0.0
		A[ A21 ] =      0.0; A[ A22 ] =   F; A[ A23 ] =                               0.0; A[ A24 ] = 0.0
		A[ A31 ] =      0.0; A[ A32 ] = 0.0; A[ A33 ] = ( zNear + zFar )/( zNear - zFar ); A[ A34 ] = 2.0*zFar*zNear/( zNear - zFar )
		A[ A41 ] =      0.0; A[ A42 ] = 0.0; A[ A43 ] =                              -1.0; A[ A44 ] = 0.0
		
		Return Self
	End Method
	
	Method MatMult:TMatrix4( Other:TMatrix4 )
		Local B:Float Ptr = Other.A
		Local T:Float Ptr = Float Ptr MemAlloc( 64 )
		
		T[ A11 ] = A[ A11 ]*B[ A11 ] + A[ A12 ]*B[ A21 ] + A[ A13 ]*B[ A31 ] + A[ A14 ]*B[ A41 ]
		T[ A12 ] = A[ A11 ]*B[ A12 ] + A[ A12 ]*B[ A22 ] + A[ A13 ]*B[ A32 ] + A[ A14 ]*B[ A42 ]
		T[ A13 ] = A[ A11 ]*B[ A13 ] + A[ A12 ]*B[ A23 ] + A[ A13 ]*B[ A33 ] + A[ A14 ]*B[ A43 ]
		T[ A14 ] = A[ A11 ]*B[ A14 ] + A[ A12 ]*B[ A24 ] + A[ A13 ]*B[ A34 ] + A[ A14 ]*B[ A44 ]
		
		T[ A21 ] = A[ A21 ]*B[ A11 ] + A[ A22 ]*B[ A21 ] + A[ A23 ]*B[ A31 ] + A[ A24 ]*B[ A41 ]
		T[ A22 ] = A[ A21 ]*B[ A12 ] + A[ A22 ]*B[ A22 ] + A[ A23 ]*B[ A32 ] + A[ A24 ]*B[ A42 ]
		T[ A23 ] = A[ A21 ]*B[ A13 ] + A[ A22 ]*B[ A23 ] + A[ A23 ]*B[ A33 ] + A[ A24 ]*B[ A43 ]
		T[ A24 ] = A[ A21 ]*B[ A14 ] + A[ A22 ]*B[ A24 ] + A[ A23 ]*B[ A34 ] + A[ A24 ]*B[ A44 ]
		
		T[ A31 ] = A[ A31 ]*B[ A11 ] + A[ A32 ]*B[ A21 ] + A[ A33 ]*B[ A31 ] + A[ A34 ]*B[ A41 ]
		T[ A32 ] = A[ A31 ]*B[ A12 ] + A[ A32 ]*B[ A22 ] + A[ A33 ]*B[ A32 ] + A[ A34 ]*B[ A42 ]
		T[ A33 ] = A[ A31 ]*B[ A13 ] + A[ A32 ]*B[ A23 ] + A[ A33 ]*B[ A33 ] + A[ A34 ]*B[ A43 ]
		T[ A34 ] = A[ A31 ]*B[ A14 ] + A[ A32 ]*B[ A24 ] + A[ A33 ]*B[ A34 ] + A[ A34 ]*B[ A44 ]
		
		T[ A41 ] = A[ A41 ]*B[ A11 ] + A[ A42 ]*B[ A21 ] + A[ A43 ]*B[ A31 ] + A[ A44 ]*B[ A41 ]
		T[ A42 ] = A[ A41 ]*B[ A12 ] + A[ A42 ]*B[ A22 ] + A[ A43 ]*B[ A32 ] + A[ A44 ]*B[ A42 ]
		T[ A43 ] = A[ A41 ]*B[ A13 ] + A[ A42 ]*B[ A23 ] + A[ A43 ]*B[ A33 ] + A[ A44 ]*B[ A43 ]
		T[ A44 ] = A[ A41 ]*B[ A14 ] + A[ A42 ]*B[ A24 ] + A[ A43 ]*B[ A34 ] + A[ A44 ]*B[ A44 ]
		
		MemCopy( A, T, 64 )
		MemFree( T )
		
		Return Self
	End Method
	
	Method VecMult:TVector4( V:TVector4 )
		Local NewX:Float = A[ A11 ]*V.X + A[ A12 ]*V.Y + A[ A13 ]*V.Z + A[ A14 ]*V.W
		Local NewY:Float = A[ A21 ]*V.X + A[ A22 ]*V.Y + A[ A23 ]*V.Z + A[ A24 ]*V.W
		Local NewZ:Float = A[ A31 ]*V.X + A[ A32 ]*V.Y + A[ A33 ]*V.Z + A[ A34 ]*V.W
		Local NewW:Float = A[ A41 ]*V.X + A[ A42 ]*V.Y + A[ A43 ]*V.Z + A[ A44 ]*V.W
		
		V.X = NewX
		V.Y = NewY
		V.Z = NewZ
		V.W = NewW
		
		Return V
	End Method
	
	Method ToString:String()
		Local Result:String
		
		Result :+ PaddedNumber( A[ A11 ] ) + PaddedNumber( A[ A12 ] ) + PaddedNumber( A[ A13 ] ) + PaddedNumber( A[ A14 ] ) + "~n"
		Result :+ PaddedNumber( A[ A21 ] ) + PaddedNumber( A[ A22 ] ) + PaddedNumber( A[ A23 ] ) + PaddedNumber( A[ A24 ] ) + "~n"
		Result :+ PaddedNumber( A[ A31 ] ) + PaddedNumber( A[ A32 ] ) + PaddedNumber( A[ A33 ] ) + PaddedNumber( A[ A34 ] ) + "~n"
		Result :+ PaddedNumber( A[ A41 ] ) + PaddedNumber( A[ A42 ] ) + PaddedNumber( A[ A43 ] ) + PaddedNumber( A[ A44 ] ) + "~n"
		
		Return Result
		
		Function PaddedNumber:String( Number:Float )
			If Number < 0.0 Then Return String.FromFloat( Number )[ .. 8 ] + " " Else Return " " + String.FromFloat( Number )[ .. 7 ] + " "
		End Function
	End Method	
End Type