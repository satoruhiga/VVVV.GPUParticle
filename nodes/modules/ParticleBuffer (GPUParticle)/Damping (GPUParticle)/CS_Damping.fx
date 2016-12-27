#include "../../common/CID.fxh"
#include "../ParticleData.fxh"

float Damping = 1;

RWStructuredBuffer<Particle> Particles : BACKBUFFER;

////////////////////////////////////////////////////////////////////////////////

[numthreads(256, 1, 1)]
void CS(uint3 dtid : SV_DispatchThreadID)
{
	if (dtid.x >= CID_GetCount()) { return; }
	uint ID = CID_GetID(dtid.x);
	
	Particle p = Particles[ID];
	p.Velocity *= Damping;
	Particles[ID] = p;
}

technique11 Update {
	pass P0 {
		SetComputeShader( CompileShader( cs_5_0, CS() ) );
	}
}

