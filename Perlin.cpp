#define YSTEP  16
#define YSTEP2 32
#define YSTEP3 48
#define YSHIFT 4
#define ZSTEP  256
#define ZSTEP2 512
#define ZSTEP3 768
#define ZSHIFT 8

float __attribute__((alway_inline)) Lerp(float Y0, float Y1, float Y2, float Y3, float Blend) {
	float A0 = Y3 - Y2 - Y0 + Y1;
	float A1 = Y0 - Y1 - A0;
	float A2 = Y2 - Y0;
	float A3 = Y1;
	
	float BlendSq = Blend*Blend;

	return A0*Blend*BlendSq + A1*BlendSq + A2*Blend + A3;
}

extern "C" {

float GetNoise1D(float X, int Octaves, float* Randoms) {
	float Result    = 0.0f;
	float Amplitude = 0.5f;
	
	if (X < 0.0f)
		X = -X;
	
	int   IntX  = (int) X;
	float FracX = X - IntX;
	
	for (int I = 0; I < Octaves; I++) {
		float Y0 = Randoms[(IntX    ) & 0xFFFF];
		float Y1 = Randoms[(IntX + 1) & 0xFFFF];
		float Y2 = Randoms[(IntX + 2) & 0xFFFF];
		float Y3 = Randoms[(IntX + 3) & 0xFFFF];
		
		Result += Lerp(Y0, Y1, Y2, Y3, FracX)*Amplitude;
		
		Amplitude *= 0.5f;
		IntX <<= 1;
		FracX *= 2.0f;
		
		if (FracX > 1.0f) {
			IntX++;
			FracX -= 1.0f;
		}
	}
	
	return Result;
}

float GetNoise2D(float X, float Y, int Octaves, float* Randoms) {
	float Result    = 0.0f;
	float Amplitude = 0.5f;
	
	if (X < 0.0f)
		X = -X;

	if (Y < 0.0f)
		Y = -Y;
	
	int   IntX  = (int) X;
	int   IntY  = (int) Y;
	float FracX = X - IntX;
	float FracY = Y - IntY;
	
	for (int I = 0; I < Octaves; I++) {
		int Offset = IntX + (IntY << YSHIFT);

		float X0 = Lerp(Randoms[(Offset         ) & 0xFFFF], Randoms[(Offset + 1         ) & 0xFFFF], Randoms[(Offset + 2         ) & 0xFFFF], Randoms[(Offset + 3         ) & 0xFFFF], FracX);
		float X1 = Lerp(Randoms[(Offset + YSTEP ) & 0xFFFF], Randoms[(Offset + 1 + YSTEP ) & 0xFFFF], Randoms[(Offset + 2 + YSTEP ) & 0xFFFF], Randoms[(Offset + 3 + YSTEP ) & 0xFFFF], FracX);
		float X2 = Lerp(Randoms[(Offset + YSTEP2) & 0xFFFF], Randoms[(Offset + 1 + YSTEP2) & 0xFFFF], Randoms[(Offset + 2 + YSTEP2) & 0xFFFF], Randoms[(Offset + 3 + YSTEP2) & 0xFFFF], FracX);
		float X3 = Lerp(Randoms[(Offset + YSTEP3) & 0xFFFF], Randoms[(Offset + 1 + YSTEP3) & 0xFFFF], Randoms[(Offset + 2 + YSTEP3) & 0xFFFF], Randoms[(Offset + 3 + YSTEP3) & 0xFFFF], FracX);
		
		Result += Lerp(X0, X1, X2, X3, FracY)*Amplitude;
		
		Amplitude *= 0.5f;
		IntX <<= 1;
		IntY <<= 1;
		FracX *= 2.0f;
		FracY *= 2.0f;
		
		if (FracX > 1.0f) {
			IntX++;
			FracX -= 1.0f;
		}

		if (FracY > 1.0f) {
			IntY++;
			FracY -= 1.0f;
		}
	}
	
	return Result;
}

float GetNoise3D(float X, float Y, float Z, int Octaves, float* Randoms) {
	float Result    = 0.0f;
	float Amplitude = 0.5f;
	
	if (X < 0.0f)
		X = -X;

	if (Y < 0.0f)
		Y = -Y;

	if (Z < 0.0f)
		Z = -Z;
	
	int   IntX  = (int) X;
	int   IntY  = (int) Y;
	int   IntZ  = (int) Z;
	float FracX = X - IntX;
	float FracY = Y - IntY;
	float FracZ = Z - IntZ;
	
	for (int I = 0; I < Octaves; I++) {
		int Offset = IntX + (IntY << YSHIFT) + (IntZ << ZSHIFT);

		float X0 = Lerp(Randoms[(Offset         ) & 0xFFFF], Randoms[(Offset + 1         ) & 0xFFFF], Randoms[(Offset + 2         ) & 0xFFFF], Randoms[(Offset + 3         ) & 0xFFFF], FracX);
		float X1 = Lerp(Randoms[(Offset + YSTEP ) & 0xFFFF], Randoms[(Offset + 1 + YSTEP ) & 0xFFFF], Randoms[(Offset + 2 + YSTEP ) & 0xFFFF], Randoms[(Offset + 3 + YSTEP ) & 0xFFFF], FracX);
		float X2 = Lerp(Randoms[(Offset + YSTEP2) & 0xFFFF], Randoms[(Offset + 1 + YSTEP2) & 0xFFFF], Randoms[(Offset + 2 + YSTEP2) & 0xFFFF], Randoms[(Offset + 3 + YSTEP2) & 0xFFFF], FracX);
		float X3 = Lerp(Randoms[(Offset + YSTEP3) & 0xFFFF], Randoms[(Offset + 1 + YSTEP3) & 0xFFFF], Randoms[(Offset + 2 + YSTEP3) & 0xFFFF], Randoms[(Offset + 3 + YSTEP3) & 0xFFFF], FracX);

		Offset += ZSTEP;

		float X4 = Lerp(Randoms[(Offset         ) & 0xFFFF], Randoms[(Offset + 1         ) & 0xFFFF], Randoms[(Offset + 2         ) & 0xFFFF], Randoms[(Offset + 3         ) & 0xFFFF], FracX);
		float X5 = Lerp(Randoms[(Offset + YSTEP ) & 0xFFFF], Randoms[(Offset + 1 + YSTEP ) & 0xFFFF], Randoms[(Offset + 2 + YSTEP ) & 0xFFFF], Randoms[(Offset + 3 + YSTEP ) & 0xFFFF], FracX);
		float X6 = Lerp(Randoms[(Offset + YSTEP2) & 0xFFFF], Randoms[(Offset + 1 + YSTEP2) & 0xFFFF], Randoms[(Offset + 2 + YSTEP2) & 0xFFFF], Randoms[(Offset + 3 + YSTEP2) & 0xFFFF], FracX);
		float X7 = Lerp(Randoms[(Offset + YSTEP3) & 0xFFFF], Randoms[(Offset + 1 + YSTEP3) & 0xFFFF], Randoms[(Offset + 2 + YSTEP3) & 0xFFFF], Randoms[(Offset + 3 + YSTEP3) & 0xFFFF], FracX);

		Offset += ZSTEP;

		float X8  = Lerp(Randoms[(Offset         ) & 0xFFFF], Randoms[(Offset + 1         ) & 0xFFFF], Randoms[(Offset + 2         ) & 0xFFFF], Randoms[(Offset + 3         ) & 0xFFFF], FracX);
		float X9  = Lerp(Randoms[(Offset + YSTEP ) & 0xFFFF], Randoms[(Offset + 1 + YSTEP ) & 0xFFFF], Randoms[(Offset + 2 + YSTEP ) & 0xFFFF], Randoms[(Offset + 3 + YSTEP ) & 0xFFFF], FracX);
		float X10 = Lerp(Randoms[(Offset + YSTEP2) & 0xFFFF], Randoms[(Offset + 1 + YSTEP2) & 0xFFFF], Randoms[(Offset + 2 + YSTEP2) & 0xFFFF], Randoms[(Offset + 3 + YSTEP2) & 0xFFFF], FracX);
		float X11 = Lerp(Randoms[(Offset + YSTEP3) & 0xFFFF], Randoms[(Offset + 1 + YSTEP3) & 0xFFFF], Randoms[(Offset + 2 + YSTEP3) & 0xFFFF], Randoms[(Offset + 3 + YSTEP3) & 0xFFFF], FracX);

		Offset += ZSTEP;

		float X12 = Lerp(Randoms[(Offset         ) & 0xFFFF], Randoms[(Offset + 1         ) & 0xFFFF], Randoms[(Offset + 2         ) & 0xFFFF], Randoms[(Offset + 3         ) & 0xFFFF], FracX);
		float X13 = Lerp(Randoms[(Offset + YSTEP ) & 0xFFFF], Randoms[(Offset + 1 + YSTEP ) & 0xFFFF], Randoms[(Offset + 2 + YSTEP ) & 0xFFFF], Randoms[(Offset + 3 + YSTEP ) & 0xFFFF], FracX);
		float X14 = Lerp(Randoms[(Offset + YSTEP2) & 0xFFFF], Randoms[(Offset + 1 + YSTEP2) & 0xFFFF], Randoms[(Offset + 2 + YSTEP2) & 0xFFFF], Randoms[(Offset + 3 + YSTEP2) & 0xFFFF], FracX);
		float X15 = Lerp(Randoms[(Offset + YSTEP3) & 0xFFFF], Randoms[(Offset + 1 + YSTEP3) & 0xFFFF], Randoms[(Offset + 2 + YSTEP3) & 0xFFFF], Randoms[(Offset + 3 + YSTEP3) & 0xFFFF], FracX);
		
		float Y0 = Lerp(X0 , X1 , X2 , X3 , FracY);
		float Y1 = Lerp(X4 , X5 , X6 , X7 , FracY);
		float Y2 = Lerp(X8 , X9 , X10, X11, FracY);
		float Y3 = Lerp(X12, X13, X14, X15, FracY);

		Result += Lerp(Y0, Y1, Y2, Y3, FracZ)*Amplitude;
		
		Amplitude *= 0.5f;
		IntX <<= 1;
		IntY <<= 1;
		IntZ <<= 1;
		FracX *= 2.0f;
		FracY *= 2.0f;
		FracZ *= 2.0f;
		
		if (FracX > 1.0f) {
			IntX++;
			FracX -= 1.0f;
		}

		if (FracY > 1.0f) {
			IntY++;
			FracY -= 1.0f;
		}

		if (FracZ > 1.0f) {
			IntZ++;
			FracZ -= 1.0f;
		}
	}
	
	return Result;
}

}