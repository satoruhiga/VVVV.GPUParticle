#include "../common/CS_PID.fxh"
#include "../common/CS_ParticleData.fxh"

StructuredBuffer<PID> IDs;
ByteAddressBuffer InputCountBuffer;
RWStructuredBuffer<Particle> Output : BACKBUFFER;

////////////////////////////////////////////////////////////////////////////////

[numthreads(64, 1, 1)]
void CS_Solve(
	uint3 dtid : SV_DispatchThreadID)
{
	uint cnt = InputCountBuffer.Load(0);
	if (dtid.x > cnt) return;
	
	uint ID = IDs[dtid.x].ID;
	Particle p = Output[ID];
	
	float d = p.Mass * 0.1;
	p.Velocity += p.Force * d;
	p.Position += p.Velocity * d;
	p.Force = float3(0, 0, 0);
	p.Pct = IDs[dtid.x].Pct;
	
	Output[ID] = p;
}

technique11 Solve {
	pass P0 {
		SetComputeShader( CompileShader( cs_5_0, CS_Solve() ) );
	}
}
