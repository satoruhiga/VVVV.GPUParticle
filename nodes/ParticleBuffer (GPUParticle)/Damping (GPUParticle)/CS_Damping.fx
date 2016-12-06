#include "../../common/CS_CID.fxh"
#include "../CS_ParticleData.fxh"

float damping = 1;

RWStructuredBuffer<Particle> Particles : BACKBUFFER;

////////////////////////////////////////////////////////////////////////////////

[numthreads(64, 1, 1)]
void CS_Damping(
	uint3 dtid : SV_DispatchThreadID)
{
	if (dtid.x >= CID_GetCount()) { return; }
	uint ID = CID_GetID(dtid.x);
	
	Particles[ID].Force *= damping;
	Particles[ID].Velocity *= damping;
}

technique11 Damping {
	pass P0 {
		SetComputeShader( CompileShader( cs_5_0, CS_Damping() ) );
	}
}

