#include "CS_interlockedAddFloat.fxh"

uint Count;

static const uint stride = 12;
ByteAddressBuffer Positions;
RWByteAddressBuffer Output : BACKBUFFER;

[numthreads(64, 1, 1)]
void CS(
	uint3 dtid : SV_DispatchThreadID)
{
	if (dtid.x >= Count) { return; }
	if (dtid.x == 0)
	{
		Output.Store(0, 0);
	}
	
	uint offset = dtid.x * stride * 3;
	
	float3 p0 = asfloat(Positions.Load3(offset + stride * 0));
	float3 p1 = asfloat(Positions.Load3(offset + stride * 1));
	float3 p2 = asfloat(Positions.Load3(offset + stride * 2));
	
	float3 v0 = p1 - p0;
	float3 v1 = p2 - p0;
	float area = length(cross(v0, v1)) / 2;
	
	interlockedAddFloat(Output, 0, area);
	
	return;
}

technique11 Update {
	pass P0 {
		SetComputeShader( CompileShader( cs_5_0, CS() ) );
	}
}
