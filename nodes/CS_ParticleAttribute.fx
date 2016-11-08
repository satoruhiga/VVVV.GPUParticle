#include "CS_ParticleData.fxh"

uint ThreadCount;

StructuredBuffer<uint> IDs;

StructuredBuffer<float> Data1f;
StructuredBuffer<float3> Data3f;
StructuredBuffer<float4> Data4f;

RWStructuredBuffer<Particle> Output : BACKBUFFER;

////////////////////////////////////////////////////////////////////////////////

[numthreads(64, 1, 1)]
void CS_AddForce(
	uint3 dtid : SV_DispatchThreadID)
{
	if (dtid.x >= ThreadCount) { return; }
	
	uint ID = IDs[dtid.x];
	Particle p = Output[ID];
	p.Force += Data3f[dtid.x];
	Output[ID] = p;
}

technique11 AddForce {
	pass P0 {
		SetComputeShader( CompileShader( cs_5_0, CS_AddForce() ) );
	}
}

////////////////////////////////////////////////////////////////////////////////

[numthreads(64, 1, 1)]
void CS_AddVelocity(
	uint3 dtid : SV_DispatchThreadID)
{
	if (dtid.x >= ThreadCount) { return; }
	
	uint ID = IDs[dtid.x];
	Particle p = Output[ID];
	p.Velocity += Data3f[dtid.x];
	Output[ID] = p;
}

technique11 AddVelocity {
	pass P0 {
		SetComputeShader( CompileShader( cs_5_0, CS_AddVelocity() ) );
	}
}

////////////////////////////////////////////////////////////////////////////////

[numthreads(64, 1, 1)]
void CS_SetSize(
	uint3 dtid : SV_DispatchThreadID)
{
	if (dtid.x >= ThreadCount) { return; }
	
	uint ID = IDs[dtid.x];
	Particle p = Output[ID];
	
	uint size, dummy;
	Data1f.GetDimensions(size, dummy);
	
	p.Size = Data1f[dtid.x % size];
	Output[ID] = p;
}

technique11 SetSize {
	pass P0 {
		SetComputeShader( CompileShader( cs_5_0, CS_SetSize() ) );
	}
}

////////////////////////////////////////////////////////////////////////////////

[numthreads(64, 1, 1)]
void CS_SetColor(
	uint3 dtid : SV_DispatchThreadID)
{
	if (dtid.x >= ThreadCount) { return; }
	
	uint ID = IDs[dtid.x];
	Particle p = Output[ID];
	
	uint size, dummy;
	Data4f.GetDimensions(size, dummy);
	
	p.Color = Data4f[ID % size];
	Output[ID] = p;
}

technique11 SetColor {
	pass P0 {
		SetComputeShader( CompileShader( cs_5_0, CS_SetColor() ) );
	}
}