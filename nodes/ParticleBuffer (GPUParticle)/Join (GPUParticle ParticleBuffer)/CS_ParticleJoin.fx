#include "../CS_ParticleData.fxh"
#include "../../common/CS_Random.fxh"

uint Count = 0;

StructuredBuffer<float3> Position;
StructuredBuffer<float3> Velocity;
StructuredBuffer<float4> Color;
StructuredBuffer<float> Size;
StructuredBuffer<float> Mass;

RWStructuredBuffer<Particle> Output : BACKBUFFER;

////////////////////////////////////////////////////////////////////////////////

[numthreads(64, 1, 1)]
void CS_Join(
	uint3 dtid : SV_DispatchThreadID)
{
	if (dtid.x >= Count) { return; }
	Particle p = (Particle)0;
	
	uint size, dummy;
	
	uint idx = dtid.x + urand(dtid.x) * 10000;
	
	Position.GetDimensions(size, dummy);
	if (size > 0)
		p.Position = Position[idx % size];
	else
		p.Position = float3(0, 0, 0);
	
	Velocity.GetDimensions(size, dummy);
	if (size > 0)
		p.Velocity = Velocity[idx % size];
	else
		p.Velocity = float3(0, 0, 0);
	
	Color.GetDimensions(size, dummy);
	if (size > 0)
		p.Color = Color[idx % size];
	else
		p.Color = float4(1, 1, 1, 1);
	
	Size.GetDimensions(size, dummy);
	if (size > 0)
		p.Size = Size[idx % size];
	else
		p.Size = 0.1;
	
	Mass.GetDimensions(size, dummy);
	if (size > 0)
		p.Mass = Mass[idx % size];
	else
		p.Mass = 1;
	
	Output[dtid.x] = p;
}

technique11 Join {
	pass P0 {
		SetComputeShader( CompileShader( cs_5_0, CS_Join() ) );
	}
}
