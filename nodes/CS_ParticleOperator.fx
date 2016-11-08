#include "CS_ParticleData.fxh"

uint ThreadCount;

StructuredBuffer<uint> IDs;
StructuredBuffer<Particle> Input;

RWStructuredBuffer<Particle> Output : BACKBUFFER;

////////////////////////////////////////////////////////////////////////////////

[numthreads(64, 1, 1)]
void CS_Set(
	uint3 dtid : SV_DispatchThreadID)
{
	if (dtid.x >= ThreadCount) { return; }
	
	Particle p = Input[dtid.x];
	uint ID = IDs[dtid.x];
	Output[ID] = p;
}

technique11 Set {
	pass P0 {
		SetComputeShader( CompileShader( cs_5_0, CS_Set() ) );
	}
}

////////////////////////////////////////////////////////////////////////////////

[numthreads(64, 1, 1)]
void CS_Solve(
	uint3 dtid : SV_DispatchThreadID)
{
	if (dtid.x >= ThreadCount) { return; }
	
	uint ID = IDs[dtid.x];
	Particle p = Output[ID];
	
	float d = p.Mass * 0.1;
	
	p.Velocity += p.Force * d;
	p.Position += p.Velocity * d;
	p.Force = float3(0, 0, 0);
	Output[ID] = p;
}

technique11 Solve {
	pass P0 {
		SetComputeShader( CompileShader( cs_5_0, CS_Solve() ) );
	}
}
