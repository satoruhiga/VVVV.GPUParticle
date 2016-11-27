#include "../common/CS_PID.fxh"
#include "../common/CS_ParticleData.fxh"

StructuredBuffer<PID> IDs;
ByteAddressBuffer InputCountBuffer;

StructuredBuffer<Particle> Input;
AppendStructuredBuffer<Particle> Output : BACKBUFFER;

////////////////////////////////////////////////////////////////////////////////

[numthreads(64, 1, 1)]
void CS(
	uint3 dtid : SV_DispatchThreadID)
{
	uint cnt = InputCountBuffer.Load(0);
	if (dtid.x >= cnt) return;
	
	uint ID = IDs[dtid.x].ID;
	Particle p = Input[ID];
	Output.Append(p);
}

technique11 Update {
	pass P0 {
		SetComputeShader( CompileShader( cs_5_0, CS() ) );
	}
}
