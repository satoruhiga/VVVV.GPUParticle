#include "../../common/AgeLife.fxh"
#include "../../common/Random.fxh"

uint Capacity;

int EmitCount = 0;

float Life = 1.0;
float LifeVariance = 0.5;

RWStructuredBuffer<AgeLife> Output : BACKBUFFER;

////////////////////////////////////////////////////////////////////////////////

[numthreads(64, 1, 1)]
void CS_Activate(
	uint3 dtid : SV_DispatchThreadID)
{
	if (dtid.x > Capacity) return;
	
	AgeLife o = Output[dtid.x];
	if (!IsAlive(o))
	{
		int cnt = Output.IncrementCounter();
		if (cnt < EmitCount)
		{
			float v = max(Life + rand(dtid.x + cnt) * LifeVariance, 0.0);
			MakeActive(Output[dtid.x], v);
		}
	}
}

technique11 Activate {
	pass P0 {
		SetComputeShader( CompileShader( cs_5_0, CS_Activate() ) );
	}
}
