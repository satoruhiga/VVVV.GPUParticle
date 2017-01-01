#include "../Common/Random.fxh"

uint Count;

float3 Size = float3(1, 1, 1);
float3 Offset = float3(0, 0, 0);

RWStructuredBuffer<float3> Output : BACKBUFFER;

[numthreads(64, 1, 1)]
void CS_Signed(uint3 dtid : SV_DispatchThreadID)
{
	if (dtid.x >= Count) { return; }
	float3 v = float3(rand(dtid.x + 1), rand(dtid.x + 2), rand(dtid.x + 3));
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
	float3 v = float3(urand(dtid.x + 1), urand(dtid.x + 2), urand(dtid.x + 3));
	Output[dtid.x] = v * Size + Offset;
}

technique11 Unsigned {
	pass P0 {
		SetComputeShader( CompileShader( cs_5_0, CS_Unsigned() ) );
	}
}

////////////////////////////////////////////////////////////////////////////////

[numthreads(64, 1, 1)]
void CS_Normalized(uint3 dtid : SV_DispatchThreadID)
{
	if (dtid.x >= Count) { return; }
	float3 v = float3(rand(dtid.x + 1), rand(dtid.x + 2), rand(dtid.x + 3));
	Output[dtid.x] = normalize(v) * Size + Offset;
}

technique11 Normalized {
	pass P0 {
		SetComputeShader( CompileShader( cs_5_0, CS_Normalized() ) );
	}
}

////////////////////////////////////////////////////////////////////////////////

[numthreads(64, 1, 1)]
void CS_Clamped(uint3 dtid : SV_DispatchThreadID)
{
	if (dtid.x >= Count) { return; }
	float3 v = float3(rand(dtid.x + 1), rand(dtid.x + 2), rand(dtid.x + 3));
	Output[dtid.x] = normalize(v) * (Size * pow(rand(dtid.x + 4), 0.5)) + Offset;
}

technique11 Clamped {
	pass P0 {
		SetComputeShader( CompileShader( cs_5_0, CS_Clamped() ) );
	}
}