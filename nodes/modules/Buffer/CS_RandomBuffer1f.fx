#include "../Common/Random.fxh"

uint Count;

float Size = 1;
float Offset = 0;

RWStructuredBuffer<float> Output : BACKBUFFER;

[numthreads(64, 1, 1)]
void CS_Signed(uint3 dtid : SV_DispatchThreadID)
{
	if (dtid.x >= Count) { return; }
	float v = float(rand(dtid.x + 1));
	Output[dtid.x] = v * Size + Offset;
}

technique11 Signed {
	pass P0 {
		SetComputeShader( CompileShader( cs_5_0, CS_Signed() ) );
	}
}

////////////////////////////////////////////////////////////////////////////////

[numthreads(64, 1, 1)]
void CS_Unsigned(uint3 dtid : SV_DispatchThreadID)
{
	if (dtid.x >= Count) { return; }
	float v = float(urand(dtid.x + 1));
	Output[dtid.x] = v * Size + Offset;
}

technique11 Unsigned {
	pass P0 {
		SetComputeShader( CompileShader( cs_5_0, CS_Unsigned() ) );
	}
}
