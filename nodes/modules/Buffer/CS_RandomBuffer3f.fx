#include "../Common/Random.fxh"

uint Count;

float3 Size = float3(1, 1, 1);
float3 Offset = float3(0, 0, 0);

RWStructuredBuffer<float3> Output : BACKBUFFER;

[numthreads(64, 1, 1)]
void CS(uint3 dtid : SV_DispatchThreadID)
{
	if (dtid.x >= Count) { return; }
	float3 v = float3(rand(123), rand(456), rand(789));
	Output[dtid.x] = v * Size + Offset;
}

technique11 Update {
	pass P0 {
		SetComputeShader( CompileShader( cs_5_0, CS() ) );
	}
}
