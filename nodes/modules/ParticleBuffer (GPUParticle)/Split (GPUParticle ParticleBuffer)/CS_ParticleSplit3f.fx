#include "../ParticleData.fxh"

uint ThreadCount;

StructuredBuffer<Particle> Particles;

RWStructuredBuffer<float3> Output : BACKBUFFER;

////////////////////////////////////////////////////////////////////////////////

[numthreads(64, 1, 1)]
void CS_SplitPosition(
	uint3 dtid : SV_DispatchThreadID)
{
	if (dtid.x >= ThreadCount) { return; }
	Particle p = Particles[dtid.x];
	Output[dtid.x] = p.Position;
}

technique11 SplitPosition {
	pass P0 {
		SetComputeShader( CompileShader( cs_5_0, CS_SplitPosition() ) );
	}
}

////////////////////////////////////////////////////////////////////////////////

[numthreads(64, 1, 1)]
void CS_SplitVelocity(
	uint3 dtid : SV_DispatchThreadID)
{
	if (dtid.x >= ThreadCount) { return; }
	Particle p = Particles[dtid.x];
	Output[dtid.x] = p.Velocity;
}

technique11 SplitVelocity {
	pass P0 {
		SetComputeShader( CompileShader( cs_5_0, CS_SplitVelocity() ) );
	}
}
