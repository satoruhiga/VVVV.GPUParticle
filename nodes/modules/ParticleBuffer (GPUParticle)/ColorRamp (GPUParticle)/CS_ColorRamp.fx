#include "../../Common/CID.fxh"
#include "../../Common/AgeLife.fxh"
#include "../ParticleData.fxh"

Texture2D Texture <string uiname = "Texture"; >;
bool Invert = false;

SamplerState Sampler {
	Filter = MIN_MAG_MIP_LINEAR; 
	AddressU = CLAMP; 
	AddressV = CLAMP;
};

StructuredBuffer<AgeLife> AgeLifeBuffer;
RWStructuredBuffer<Particle> Particles : BACKBUFFER;

////////////////////////////////////////////////////////////////////////////////

[numthreads(64, 1, 1)]
void CS_Set(uint3 dtid : SV_DispatchThreadID)
{
	if (dtid.x >= CID_GetCount()) { return; }
	uint ID = CID_GetID(dtid.x);

	Particle p = Particles[ID];
	AgeLife AL = AgeLifeBuffer[dtid.x];
	
	float Pct = clamp(AL.Age / AL.Life, 0, 1);
	Pct = Invert ? 1 - Pct : Pct;
	float4 C = Texture.SampleLevel(Sampler, float2(Pct, 0.5), 0);
	p.Color = C;
	
	Particles[ID] = p;
}

technique11 Set {
	pass P0 {
		SetComputeShader( CompileShader( cs_5_0, CS_Set() ) );
	}
}