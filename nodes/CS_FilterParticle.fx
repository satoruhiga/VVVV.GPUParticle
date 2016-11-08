#include "CS_ParticleData.fxh"

uint ThreadCount;

StructuredBuffer<uint> IDs;
StructuredBuffer<Particle> Input;
AppendStructuredBuffer<Particle> Output : BACKBUFFER;

////////////////////////////////////////////////////////////////////////////////

[numthreads(64, 1, 1)]
void CS_Update(
	uint3 dtid : SV_DispatchThreadID)
{
	if (dtid.x >= ThreadCount) { return; }
	
	uint ID = IDs[dtid.x];
	Particle p = Input[ID];
	Output.Append(p);
}

technique11 Update {
	pass P0 {
		SetComputeShader( CompileShader( cs_5_0, CS_Update() ) );
	}
}
