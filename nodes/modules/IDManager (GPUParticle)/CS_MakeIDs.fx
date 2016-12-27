#include "../common/AgeLife.fxh"

uint Capaciaty;

StructuredBuffer<AgeLife> Input;

RWStructuredBuffer<uint> AliveBuffer : BACKBUFFER0;
RWStructuredBuffer<uint> NewBuffer : BACKBUFFER1;
RWStructuredBuffer<AgeLife> AgeLifeBuffer : BACKBUFFER2;

////////////////////////////////////////////////////////////////////////////////

[numthreads(64, 1, 1)]
void CS(
	uint3 dtid : SV_DispatchThreadID)
{
	if (dtid.x >= Capaciaty) return;
	
	AgeLife p = Input[dtid.x];

	if (p.Age == 0)
	{
		uint cnt = NewBuffer.IncrementCounter();
		NewBuffer[cnt] = dtid.x;
	}
	else if (IsAlive(p))
	{
		uint cnt = AliveBuffer.IncrementCounter();
		AliveBuffer[cnt] = dtid.x;
		AgeLifeBuffer[cnt] = p;
	}
}

technique11 Update {
	pass P0 {
		SetComputeShader( CompileShader( cs_5_0, CS() ) );
	}
}
