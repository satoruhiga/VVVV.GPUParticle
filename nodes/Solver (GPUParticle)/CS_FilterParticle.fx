#include "../common/CS_ParticleData.fxh"

uint Count;

StructuredBuffer<Particle> Input;
AppendStructuredBuffer<Particle> Output : BACKBUFFER;

////////////////////////////////////////////////////////////////////////////////

[numthreads(64, 1, 1)]
void CS(
	uint3 dtid : SV_DispatchThreadID)
{
	if (dtid.x >= Count) return;
	
	Particle p = Input[dtid.x];
	if (isAlive(p))
	{
		Output.Append(p);
	}
}

technique11 Update {
	pass P0 {
		SetComputeShader( CompileShader( cs_5_0, CS() ) );
	}
}
