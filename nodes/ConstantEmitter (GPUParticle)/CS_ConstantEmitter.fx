#include "../common/CS_AgeLife.fxh"
#include "../common/CS_Random.fxh"

uint MaxCount;
uint EmitCount = 1;

float Life = 1;
float LifeVariance = 0.5;

RWStructuredBuffer<AgeLife> Data : BACKBUFFER;

////////////////////////////////////////////////////////////////////////////////

[numthreads(64, 1, 1)]
void CS(
	uint3 dtid : SV_DispatchThreadID)
{
	if (dtid.x >= MaxCount) { return; }
	
	AgeLife p = Data[dtid.x];
	
	if (isDead(p))
	{
		uint cnt = Data.IncrementCounter();
		if (cnt < EmitCount)
		{
			p.Age = 0;
			p.Life = max(Life + rand(dtid.x + cnt) * LifeVariance, 0.0);
		}
	}	
	
	Data[dtid.x] = p;
}

technique11 Emit {
	pass P0 {
		SetComputeShader( CompileShader( cs_5_0, CS() ) );
	}
}
