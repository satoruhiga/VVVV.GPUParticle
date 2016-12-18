#include "../common/CS_AgeLife.fxh"

uint Capacity;
float TimeInc;

static const float InvTargetTime = 1.0 / 60.0;

RWStructuredBuffer<AgeLife> Output : BACKBUFFER;

////////////////////////////////////////////////////////////////////////////////

[numthreads(64, 1, 1)]
void CS_Update(
	uint3 dtid : SV_DispatchThreadID)
{
	if (dtid.x >= Capacity) return;
	Output[dtid.x].Age += TimeInc;
}

technique11 Update {
	pass P0 {
		SetComputeShader( CompileShader( cs_5_0, CS_Update() ) );
	}
}

////////////////////////////////////////////////////////////////////////////////

[numthreads(64, 1, 1)]
void CS_Reset(
	uint3 dtid : SV_DispatchThreadID)
{
	if (dtid.x >= Capacity) { return; }
	InitAgeLife(Output[dtid.x]);
}

technique11 Reset {
	pass P0 {
		SetComputeShader( CompileShader( cs_5_0, CS_Reset() ) );
	}
}
