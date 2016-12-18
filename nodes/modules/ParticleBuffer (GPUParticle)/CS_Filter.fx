#include "../common/CS_CID.fxh"
#include "./CS_ParticleData.fxh"

uint Count;

StructuredBuffer<Particle> Input;
RWStructuredBuffer<Particle> Data : BACKBUFFER;

////////////////////////////////////////////////////////////////////////////////

[numthreads(64, 1, 1)]
void CS_Update(
	uint3 dtid : SV_DispatchThreadID)
{
	if (dtid.x >= CID_GetCount()) return;
	uint ID = CID_GetID(dtid.x);
	Data[dtid.x] = Input[ID];
}

technique11 Update {
	pass P0 {
		SetComputeShader( CompileShader( cs_5_0, CS_Update() ) );
	}
}
