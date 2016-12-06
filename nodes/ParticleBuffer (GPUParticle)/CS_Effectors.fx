#include "../common/CS_CID.fxh"
#include "./CS_ParticleData.fxh"

StructuredBuffer<float> Data1f;
StructuredBuffer<float3> Data3f;
StructuredBuffer<float4> Data4f;

RWStructuredBuffer<Particle> Particles : BACKBUFFER;

////////////////////////////////////////////////////////////////////////////////

[numthreads(64, 1, 1)]
void CS_AddForce(
	uint3 dtid : SV_DispatchThreadID)
{
	if (dtid.x >= CID_GetCount()) { return; }
	uint ID = CID_GetID(dtid.x);
	
	uint num_input, dummy;
	Data3f.GetDimensions(num_input, dummy);
	
	Particles[ID].Force += Data3f[dtid.x % num_input];
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
	if (dtid.x >= CID_GetCount()) { return; }
	uint ID = CID_GetID(dtid.x);
	
	uint num_input, dummy;
	Data3f.GetDimensions(num_input, dummy);

	Particles[ID].Velocity += Data3f[dtid.x % num_input];
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
	if (dtid.x >= CID_GetCount()) { return; }
	uint ID = CID_GetID(dtid.x);
	
	uint num_input, dummy;
	Data1f.GetDimensions(num_input, dummy);

	Particles[ID].Velocity = Data1f[dtid.x % num_input];
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
	if (dtid.x >= CID_GetCount()) { return; }
	uint ID = CID_GetID(dtid.x);
	
	uint num_input, dummy;
	Data4f.GetDimensions(num_input, dummy);

	Particles[ID].Color = Data4f[dtid.x % num_input];
}

technique11 SetColor {
	pass P0 {
		SetComputeShader( CompileShader( cs_5_0, CS_SetColor() ) );
	}
}
