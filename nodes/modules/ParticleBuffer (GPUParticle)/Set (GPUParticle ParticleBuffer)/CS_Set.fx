#include "../../common/CS_CID.fxh"
#include "../CS_ParticleData.fxh"

StructuredBuffer<Particle> Input;
RWStructuredBuffer<Particle> Data : BACKBUFFER;

////////////////////////////////////////////////////////////////////////////////

[numthreads(64, 1, 1)]
void CS(
	uint3 dtid : SV_DispatchThreadID)
{
	if (dtid.x >= CID_GetCount()) return;
	uint ID = CID_GetID(dtid.x);
	Data[ID] = Input[dtid.x];
}

technique11 Update {
	pass P0 {
		SetComputeShader( CompileShader( cs_5_0, CS() ) );
	}
}
