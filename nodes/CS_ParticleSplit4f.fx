#include "CS_ParticleData.fxh"

uint ThreadCount;

StructuredBuffer<Particle> Particles;

RWStructuredBuffer<float4> Output : BACKBUFFER;

////////////////////////////////////////////////////////////////////////////////

[numthreads(64, 1, 1)]
void CS_SplitColor(
	uint3 dtid : SV_DispatchThreadID)
{
	if (dtid.x >= ThreadCount) { return; }
	Particle p = Particles[dtid.x];
	Output[dtid.x] = p.Color;
}

technique11 SplitColor {
	pass P0 {
		SetComputeShader( CompileShader( cs_5_0, CS_SplitColor() ) );
	}
}
