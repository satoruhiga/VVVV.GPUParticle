#include "../common/CS_PID.fxh"
#include "../common/CS_ParticleData.fxh"

StructuredBuffer<PID> IDs;
ByteAddressBuffer InputCountBuffer;

StructuredBuffer<Particle> Input;
RWStructuredBuffer<Particle> Output : BACKBUFFER;

////////////////////////////////////////////////////////////////////////////////

[numthreads(64, 1, 1)]
void CS(
	uint3 dtid : SV_DispatchThreadID)
{
	uint cnt = InputCountBuffer.Load(0);
	uint num_input, dummy;
	Input.GetDimensions(num_input, dummy);
	
	if (dtid.x >= cnt
		|| dtid.x >= num_input) return;
	
	uint ID = IDs[dtid.x].ID;
	Output[ID] = Input[dtid.x];
}

technique11 Set {
	pass P0 {
		SetComputeShader( CompileShader( cs_5_0, CS() ) );
	}
}
