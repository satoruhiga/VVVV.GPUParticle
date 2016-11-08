#include "CS_ParticleData.fxh"

uint ThreadCount;

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
	if (dtid.x >= ThreadCount) { return; }
	Particle p = (Particle)0;
	
	p.Position = Position[dtid.x];
	p.Velocity = Velocity[dtid.x];
	
	///
	
	uint colorCount, sizeCount, massCount, dummy;
	
	Color.GetDimensions(colorCount, dummy);
	if (colorCount > 0)
		p.Color = Color[dtid.x];
	else
		p.Color = float4(1, 1, 1, 1);
	
	Size.GetDimensions(sizeCount, dummy);
	if (sizeCount > 0)
		p.Size = Size[dtid.x];
	else
		p.Size = 0.1;
	
	Mass.GetDimensions(massCount, dummy);
	if (massCount > 0)
		p.Mass = Mass[dtid.x];
	else
		p.Mass = 1;
	
	Output[dtid.x] = p;
}

technique11 Join {
	pass P0 {
		SetComputeShader( CompileShader( cs_5_0, CS_Join() ) );
	}
}
