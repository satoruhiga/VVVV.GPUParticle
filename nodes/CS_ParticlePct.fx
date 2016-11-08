#include "CS_AgeLife.fxh"

uint ThreadCount;

StructuredBuffer<AgeLife> Input;
RWStructuredBuffer<float> Output : BACKBUFFER;

////////////////////////////////////////////////////////////////////////////////

[numthreads(64, 1, 1)]
void CS_Update(
	uint3 dtid : SV_DispatchThreadID)
{
	if (dtid.x >= ThreadCount) { return; }
	
	AgeLife p = Input[dtid.x];
	Output[dtid.x] = clamp(p.Age / p.Life, 0, 1);
}

technique11 Update {
	pass P0 {
		SetComputeShader( CompileShader( cs_5_0, CS_Update() ) );
	}
}

