#include "../CS_ParticleData.fxh"

uint Count;

StructuredBuffer<Particle> Particles;

RWStructuredBuffer<float3> Position : BACKBUFFER0;
RWStructuredBuffer<float3> Velocity : BACKBUFFER1;
RWStructuredBuffer<float4> Color : BACKBUFFER2;
RWStructuredBuffer<float> Size : BACKBUFFER3;
RWStructuredBuffer<float> Mass : BACKBUFFER4;

////////////////////////////////////////////////////////////////////////////////

[numthreads(64, 1, 1)]
void CS(
	uint3 dtid : SV_DispatchThreadID)
{
	if (dtid.x >= Count) { return; }
	Particle p = Particles[dtid.x];
	Position[dtid.x] = p.Position;
	Velocity[dtid.x] = p.Velocity;
	Color[dtid.x] = p.Color;
	Size[dtid.x] = p.Size;
	Mass[dtid.x] = p.Mass;
}

technique11 Update {
	pass P0 {
		SetComputeShader( CompileShader( cs_5_0, CS() ) );
	}
}
