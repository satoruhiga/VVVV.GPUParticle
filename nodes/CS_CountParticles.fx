#include "CS_ParticleData.fxh"

StructuredBuffer<Particle> Input;
RWStructuredBuffer<uint> Output : BACKBUFFER;

////////////////////////////////////////////////////////////////////////////////

[numthreads(1, 1, 1)]
void CS_Update(
	uint3 dtid : SV_DispatchThreadID)
{
	uint count, dummy;
	Input.GetDimensions(count, dummy);
	Output[0] = count;
}

technique11 Update {
	pass P0 {
		SetComputeShader( CompileShader( cs_5_0, CS_Update() ) );
	}
}
