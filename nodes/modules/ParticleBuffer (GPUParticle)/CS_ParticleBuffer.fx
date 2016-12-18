#include "../common/CS_CID.fxh"
#include "./CS_ParticleData.fxh"

uint Capacity;
float TimeInc = 1.0 / 60.0;

static const float InvTargetTime = 1.0 / 60.0;
static const float TimeRatio = TimeInc / InvTargetTime;

RWStructuredBuffer<Particle> Data : BACKBUFFER;

////////////////////////////////////////////////////////////////////////////////

[numthreads(64, 1, 1)]
void CS_Update(
	uint3 dtid : SV_DispatchThreadID)
{
	if (dtid.x >= CID_GetCount()) return;
	uint ID = CID_GetID(dtid.x);
	Particle p = Data[ID];
	
	// Update position
	float d = p.Mass * 0.1 * TimeRatio;
	p.Velocity += p.Force * d;
	p.Position += p.Velocity * d;
	p.Force = float3(0, 0, 0);

	Data[ID] = p;
}

technique11 Update {
	pass P0 {
		SetComputeShader( CompileShader( cs_5_0, CS_Update() ) );
	}
}
