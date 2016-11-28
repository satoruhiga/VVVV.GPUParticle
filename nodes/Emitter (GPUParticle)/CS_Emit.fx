#include "../common/CS_ParticleData.fxh"
#include "../common/CS_Random.fxh"

uint Count;

float Life = 1;
float LifeVariance = 0.5;

StructuredBuffer<Particle> Input;
RWStructuredBuffer<Particle> Output : BACKBUFFER;

////////////////////////////////////////////////////////////////////////////////

[numthreads(64, 1, 1)]
void CS_Emit(
	uint3 dtid : SV_DispatchThreadID)
{
	if (dtid.x > Count) return;
	
	Particle p = Output[dtid.x];
	
	uint N, dummy;
	Input.GetDimensions(N, dummy);
	
	if (!isAlive(p))
	{
		uint cnt = Output.IncrementCounter();
		if (cnt < N)
		{
			p = Input[cnt];
			p.Age = 0;
			p.Life = max(Life + rand(dtid.x + cnt) * LifeVariance, 0.0);
			Output[dtid.x] = p;
		}
	}
}

technique11 Emit {
	pass P0 {
		SetComputeShader( CompileShader( cs_5_0, CS_Emit() ) );
	}
}
