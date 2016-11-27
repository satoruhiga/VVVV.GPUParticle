#include "../common/CS_PID.fxh"
#include "../common/CS_ParticleData.fxh"

uint Count;

StructuredBuffer<Particle> Input;
RWStructuredBuffer<float> Output : BACKBUFFER;

////////////////////////////////////////////////////////////////////////////////

[numthreads(64, 1, 1)]
void CS_Update01(
	uint3 dtid : SV_DispatchThreadID)
{
	if (dtid.x >= Count) return;
	
	Particle p = Input[dtid.x];
	Output[dtid.x] = p.Pct;
}

technique11 Update01 {
	pass P0 {
		SetComputeShader( CompileShader( cs_5_0, CS_Update01() ) );
	}
}
