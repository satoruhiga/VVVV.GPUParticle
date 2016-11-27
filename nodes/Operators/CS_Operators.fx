#include "../common/CS_PID.fxh"
#include "../common/CS_ParticleData.fxh"

StructuredBuffer<PID> IDs;
ByteAddressBuffer InputCountBuffer;

StructuredBuffer<float> Data1f;
StructuredBuffer<float3> Data3f;
StructuredBuffer<float4> Data4f;

RWStructuredBuffer<Particle> Output : BACKBUFFER;

////////////////////////////////////////////////////////////////////////////////

[numthreads(64, 1, 1)]
void CS_AddForce(
	uint3 dtid : SV_DispatchThreadID)
{
	uint cnt = InputCountBuffer.Load(0);
	if (dtid.x >= cnt) { return; }
	
	uint num_input, dummy;
	Data3f.GetDimensions(num_input, dummy);
	
	uint ID = IDs[dtid.x].ID;
	Particle p = Output[ID];
	p.Force += Data3f[dtid.x % num_input];
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
	uint cnt = InputCountBuffer.Load(0);
	if (dtid.x >= cnt) { return; }
	
	uint num_input, dummy;
	Data3f.GetDimensions(num_input, dummy);
	
	uint ID = IDs[dtid.x].ID;
	Particle p = Output[ID];
	p.Velocity += Data3f[dtid.x % num_input];
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
	uint cnt = InputCountBuffer.Load(0);
	if (dtid.x >= cnt) { return; }
	
	uint num_input, dummy;
	Data1f.GetDimensions(num_input, dummy);
	
	uint ID = IDs[dtid.x].ID;
	Particle p = Output[ID];
	p.Size = Data1f[dtid.x % num_input];
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
	uint cnt = InputCountBuffer.Load(0);
	if (dtid.x >= cnt) { return; }
	
	uint num_input, dummy;
	Data4f.GetDimensions(num_input, dummy);
	
	uint ID = IDs[dtid.x].ID;
	Particle p = Output[ID];
	
	p.Color = Data4f[ID % num_input];
	Output[ID] = p;
}

technique11 SetColor {
	pass P0 {
		SetComputeShader( CompileShader( cs_5_0, CS_SetColor() ) );
	}
}
