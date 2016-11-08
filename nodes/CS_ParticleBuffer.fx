#include "CS_ParticleData.fxh"

RWStructuredBuffer<Particle> Output : BACKBUFFER;

////////////////////////////////////////////////////////////////////////////////

[numthreads(64, 1, 1)]
void CS_Create(
	uint3 dtid : SV_DispatchThreadID)
{
	Output[dtid.x] = (Particle)0;
}

technique11 Create {
	pass P0 {
		SetComputeShader( CompileShader( cs_5_0, CS_Create() ) );
	}
}
