#include "../common/CS_AgeLife.fxh"

uint Count;
float TimeInc;

RWStructuredBuffer<AgeLife> Data : BACKBUFFER;

////////////////////////////////////////////////////////////////////////////////

[numthreads(64, 1, 1)]
void CS_Update(
	uint3 dtid : SV_DispatchThreadID)
{
	if (dtid.x >= Count) { return; }
	
	AgeLife p = Data[dtid.x];
	p.Age += TimeInc;	
	Data[dtid.x] = p;
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
	if (dtid.x >= Count) { return; }
	
	AgeLife p = Data[dtid.x];
	p.Age = 0;
	p.Life = 0;	
	Data[dtid.x] = p;
}

technique11 Reset {
	pass P0 {
		SetComputeShader( CompileShader( cs_5_0, CS_Reset() ) );
	}
}
