#include "CS_AgeLife.fxh"

uint ThreadCount;
StructuredBuffer<AgeLife> Data;

AppendStructuredBuffer<uint> Pool : BACKBUFFER;

////////////////////////////////////////////////////////////////////////////////

[numthreads(64, 1, 1)]
void CS_IsDead(
	uint3 dtid : SV_DispatchThreadID)
{
	if (dtid.x >= ThreadCount) { return; }
	
	AgeLife p = Data[dtid.x];
	if (p.Age >= p.Life)
	{
		Pool.Append(dtid.x);
	}
}

technique11 IsDead {
	pass P0 {
		SetComputeShader( CompileShader( cs_5_0, CS_IsDead() ) );
	}
}

////////////////////////////////////////////////////////////////////////////////

[numthreads(64, 1, 1)]
void CS_IsAlive(
	uint3 dtid : SV_DispatchThreadID)
{
	if (dtid.x >= ThreadCount) { return; }
	
	AgeLife p = Data[dtid.x];
	if (p.Age < p.Life)
	{
		Pool.Append(dtid.x);
	}
}

technique11 IsAlive {
	pass P0 {
		SetComputeShader( CompileShader( cs_5_0, CS_IsAlive() ) );
	}
}

////////////////////////////////////////////////////////////////////////////////

StructuredBuffer<uint> IDs;

[numthreads(64, 1, 1)]
void CS_FilterIDs(
	uint3 dtid : SV_DispatchThreadID)
{
	if (dtid.x >= ThreadCount) { return; }
	
	uint id = IDs[dtid.x];
	Pool.Append(id);
}

technique11 FilterIDs {
	pass P0 {
		SetComputeShader( CompileShader( cs_5_0, CS_FilterIDs() ) );
	}
}