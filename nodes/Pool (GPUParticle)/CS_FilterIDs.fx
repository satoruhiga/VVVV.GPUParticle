#include "../common/CS_AgeLife.fxh"
#include "../common/CS_PID.fxh"

uint Count;

StructuredBuffer<AgeLife> Input;
AppendStructuredBuffer<PID> Output : BACKBUFFER;

////////////////////////////////////////////////////////////////////////////////

[numthreads(64, 1, 1)]
void CS_Alive(
	uint3 dtid : SV_DispatchThreadID)
{
	if (dtid.x >= Count) { return; }
	
	AgeLife p = Input[dtid.x];
	
	if (!isDead(p))
	{
		PID pid;
		pid.ID = dtid.x;
		pid.Pct = clamp(p.Age / p.Life, 0, 1);
		Output.Append(pid);
	}
}

technique11 Alive {
	pass P0 {
		SetComputeShader( CompileShader( cs_5_0, CS_Alive() ) );
	}
}

////////////////////////////////////////////////////////////////////////////////

[numthreads(64, 1, 1)]
void CS_Emit(
	uint3 dtid : SV_DispatchThreadID)
{
	if (dtid.x >= Count) { return; }
	
	AgeLife p = Input[dtid.x];
	
	if (p.Age == 0)
	{
		PID pid;
		pid.ID = dtid.x;
		pid.Pct = 0;
		Output.Append(pid);
	}
}

technique11 Emit {
	pass P0 {
		SetComputeShader( CompileShader( cs_5_0, CS_Emit() ) );
	}
}
