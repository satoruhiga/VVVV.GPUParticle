#include "CS_AgeLife.fxh"

uint ThreadCount;

StructuredBuffer<uint> IDs;
StructuredBuffer<AgeLife> Input;
RWStructuredBuffer<AgeLife> Output : BACKBUFFER;

////////////////////////////////////////////////////////////////////////////////

[numthreads(64, 1, 1)]
void CS_Update(
	uint3 dtid : SV_DispatchThreadID)
{
	if (dtid.x >= ThreadCount) { return; }
	
	uint ID = IDs[dtid.x];
	AgeLife p = Input[ID];
	Output[dtid.x] = p;;
}

technique11 Update {
	pass P0 {
		SetComputeShader( CompileShader( cs_5_0, CS_Update() ) );
	}
}
