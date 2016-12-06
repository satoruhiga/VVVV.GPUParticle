#include "../../common/CS_AgeLife.fxh"

uint Count;

StructuredBuffer<AgeLife> Input;
RWStructuredBuffer<float> Output : BACKBUFFER;

////////////////////////////////////////////////////////////////////////////////

[numthreads(64, 1, 1)]
void CS_01(
	uint3 dtid : SV_DispatchThreadID)
{
	if (dtid.x > Count) return;
	AgeLife o = Input[dtid.x];
	float v = clamp(o.Age / o.Life, 0, 1);
	Output[dtid.x] = v;
}

technique11 Update01 {
	pass P0 {
		SetComputeShader( CompileShader( cs_5_0, CS_01() ) );
	}
}


////////////////////////////////////////////////////////////////////////////////

[numthreads(64, 1, 1)]
void CS_10(
	uint3 dtid : SV_DispatchThreadID)
{
	if (dtid.x > Count) return;
	AgeLife o = Input[dtid.x];
	float v = 1 - clamp(o.Age / o.Life, 0, 1);
	Output[dtid.x] = v;
}

technique11 Update10 {
	pass P0 {
		SetComputeShader( CompileShader( cs_5_0, CS_10() ) );
	}
}
