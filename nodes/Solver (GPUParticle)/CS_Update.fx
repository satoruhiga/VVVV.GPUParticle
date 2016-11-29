#include "../common/CS_ParticleData.fxh"

uint Count;
float TimeInc;

static const float InvTargetTime = 1.0 / 60.0;

RWStructuredBuffer<Particle> Particles : BACKBUFFER;

////////////////////////////////////////////////////////////////////////////////

[numthreads(64, 1, 1)]
void CS_Update(
	uint3 dtid : SV_DispatchThreadID)
{
	if (dtid.x >= Count) return;
	
	Particle p = Particles[dtid.x];

	if (isAlive(p))
	{
		float TimeRatio = TimeInc / InvTargetTime; 
		
		{
			// Update position
			float d = p.Mass * 0.1 * TimeRatio;
			p.Velocity += p.Force * d;
			p.Position += p.Velocity * d;
			p.Force = float3(0, 0, 0);
		}
		
		{
			// Update age
			p.Age += TimeInc;
		}
		
		Particles[dtid.x] = p;
	}
}

technique11 Update {
	pass P0 {
		SetComputeShader( CompileShader( cs_5_0, CS_Update() ) );
	}
}

////////////////////////////////////////////////////////////////////////////////

[numthreads(64, 1, 1)]
void CS_Reset(
	uint3 dtid : SV_DispatchThreadID)
{
	if (dtid.x >= Count) { return; }
	Particles[dtid.x].Age = 0;
	Particles[dtid.x].Life = 0;
}

technique11 Reset {
	pass P0 {
		SetComputeShader( CompileShader( cs_5_0, CS_Reset() ) );
	}
}