#include "../common/CS_ParticleData.fxh"

uint ThreadCount;

StructuredBuffer<Particle> Particles;

RWStructuredBuffer<float> Output : BACKBUFFER;

////////////////////////////////////////////////////////////////////////////////

[numthreads(64, 1, 1)]
void CS_SplitSize(
	uint3 dtid : SV_DispatchThreadID)
{
	if (dtid.x >= ThreadCount) { return; }
	Particle p = Particles[dtid.x];
	Output[dtid.x] = p.Size;
}

technique11 SplitSize {
	pass P0 {
		SetComputeShader( CompileShader( cs_5_0, CS_SplitSize() ) );
	}
}

////////////////////////////////////////////////////////////////////////////////

[numthreads(64, 1, 1)]
void CS_SplitMass(
	uint3 dtid : SV_DispatchThreadID)
{
	if (dtid.x >= ThreadCount) { return; }
	Particle p = Particles[dtid.x];
	Output[dtid.x] = p.Size;
}

technique11 SplitMass {
	pass P0 {
		SetComputeShader( CompileShader( cs_5_0, CS_SplitMass() ) );
	}
}

////////////////////////////////////////////////////////////////////////////////

[numthreads(64, 1, 1)]
void CS_SplitPct01(
	uint3 dtid : SV_DispatchThreadID)
{
	if (dtid.x >= ThreadCount) { return; }
	Particle p = Particles[dtid.x];
	Output[dtid.x] = p.Pct;
}

technique11 SplitPct01 {
	pass P0 {
		SetComputeShader( CompileShader( cs_5_0, CS_SplitPct01() ) );
	}
}

////////////////////////////////////////////////////////////////////////////////

[numthreads(64, 1, 1)]
void CS_SplitPct10(
	uint3 dtid : SV_DispatchThreadID)
{
	if (dtid.x >= ThreadCount) { return; }
	Particle p = Particles[dtid.x];
	Output[dtid.x] = 1 - p.Pct;
}

technique11 SplitPct10 {
	pass P0 {
		SetComputeShader( CompileShader( cs_5_0, CS_SplitPct10() ) );
	}
}