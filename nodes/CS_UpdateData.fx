#include "CS_AgeLife.fxh"

float Seed;

uint EmitCount;
StructuredBuffer<uint> IDs;

uint UpdateCount;
float TimeInc;

RWStructuredBuffer<AgeLife> Data : BACKBUFFER;

float rand(float2 p) {
   float2 r = float2(23.14069263277926, 2.665144142690225);
   return frac(cos(dot(p, r)) * 123456.);
}

float urand(float seed) {
    return rand(float2(Seed, seed));
}

float rand(float seed) {
    return urand(seed) * 2.0 - 1.0;
}

////////////////////////////////////////////////////////////////////////////////

float Life = 1;
float LifeVariance = 0.5;

[numthreads(64, 1, 1)]
void CS_Emit(
	uint3 dtid : SV_DispatchThreadID)
{
	if (dtid.x >= EmitCount) { return; }
	
	uint ID = IDs[dtid.x];
	AgeLife p = Data[ID];
	
	p.Age = 0;
	p.Life = max(Life + rand(ID) * LifeVariance, 0.0);
	
	Data[ID] = p;
}

technique11 Emit
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS_Emit() ) );
	}
}

////////////////////////////////////////////////////////////////////////////////

[numthreads(64, 1, 1)]
void CS_Update(
	uint3 dtid : SV_DispatchThreadID)
{
	if (dtid.x >= UpdateCount) { return; }
	
	AgeLife p = Data[dtid.x];
	
	p.Age += TimeInc;
	
	Data[dtid.x] = p;
}

technique11 Update
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS_Update() ) );
	}
}

////////////////////////////////////////////////////////////////////////////////

[numthreads(64, 1, 1)]
void CS_Reset(
	uint3 dtid : SV_DispatchThreadID)
{
	if (dtid.x >= UpdateCount) { return; }
	
	AgeLife p = Data[dtid.x];
	
	p.Age = 0;
	p.Life = 0;
	
	Data[dtid.x] = p;
}

technique11 Reset
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS_Reset() ) );
	}
}
