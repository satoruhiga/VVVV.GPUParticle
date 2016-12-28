#include "../Common/Random.fxh"

uint Count;

float Size = 1;
float Offset = 0;

RWStructuredBuffer<float> Output : BACKBUFFER;

[numthreads(64, 1, 1)]
void CS(uint3 dtid : SV_DispatchThreadID)
{
	if (dtid.x >= Count) { return; }
	float v = rand(123);
	Output[dtid.x] = v * Size + Offset;
}

technique11 Update {
	pass P0 {
		SetComputeShader( CompileShader( cs_5_0, CS() ) );
	}
}
