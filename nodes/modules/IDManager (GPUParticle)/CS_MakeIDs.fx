#include "../common/CS_AgeLife.fxh"

uint Capaciaty;

StructuredBuffer<AgeLife> Input;
RWStructuredBuffer<uint> Output : BACKBUFFER;

////////////////////////////////////////////////////////////////////////////////

[numthreads(64, 1, 1)]
void CS_UpdatActive(
	uint3 dtid : SV_DispatchThreadID)
{
	if (dtid.x >= Capaciaty) return;
	
	AgeLife p = Input[dtid.x];

	if (IsAlive(p))
	{
		uint cnt = Output.IncrementCounter();
		Output[cnt] = dtid.x;
	}
}

technique11 UpdateActive {
	pass P0 {
		SetComputeShader( CompileShader( cs_5_0, CS_UpdatActive() ) );
	}
}

////////////////////////////////////////////////////////////////////////////////

[numthreads(64, 1, 1)]
void CS_UpdateFree(
	uint3 dtid : SV_DispatchThreadID)
{
	if (dtid.x >= Capaciaty) return;
	
	AgeLife p = Input[dtid.x];

	if (!IsAlive(p))
	{
		uint cnt = Output.IncrementCounter();
		Output[cnt] = dtid.x;
	}
}

technique11 UpdateFree {
	pass P0 {
		SetComputeShader( CompileShader( cs_5_0, CS_UpdateFree() ) );
	}
}


////////////////////////////////////////////////////////////////////////////////

[numthreads(64, 1, 1)]
void CS_UpdateNew(
	uint3 dtid : SV_DispatchThreadID)
{
	if (dtid.x >= Capaciaty) return;
	
	AgeLife p = Input[dtid.x];

	if (p.Age == 0)
	{
		uint cnt = Output.IncrementCounter();
		Output[cnt] = dtid.x;
	}
}

technique11 UpdateNew {
	pass P0 {
		SetComputeShader( CompileShader( cs_5_0, CS_UpdateNew() ) );
	}
}
