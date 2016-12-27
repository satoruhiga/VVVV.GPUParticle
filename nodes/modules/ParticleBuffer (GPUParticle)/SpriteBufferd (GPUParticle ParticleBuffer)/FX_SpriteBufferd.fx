#include "../../common/CID.fxh"
#include "../ParticleData.fxh"

StructuredBuffer<Particle> Particles;

cbuffer Params : register(b0) {
	float4x4 tVP : VIEWPROJECTION;
	float4x4 tVI : VIEWINVERSE;
	float4x4 tW : WORLD;
	
	float DefaultSize = 1;
	float4 DefaultColor <bool color = true; > = { 1, 1, 1, 1 };

	bool CircleShape = true;
};

Texture2D Texture0 <string uiname = "Texture"; >;
SamplerState s0 <string uiname = "Sampler"; > {
	Filter = MIN_MAG_MIP_LINEAR; AddressU = CLAMP; AddressV = CLAMP;
};

struct VS_IN {
	uint iv : SV_VertexID;
};

struct VS_OUT {
	uint iv : TEXCOORD0;
};

struct GS_OUT {
	float4 Position : SV_POSITION;
	float2 TexCoord : TEXCOORD0;
	float4 Color : COLOR;
};

VS_OUT VS(VS_IN Input) {
	VS_OUT Output;
	Output.iv = Input.iv;
	return Output;
}

static const float3 Quad[4] : IMMUTABLE = {
	{-1, 1, 0}, {1, 1, 0},
	{-1, -1, 0}, {1, -1, 0}
};

static const float2 TexCoord[4] : IMMUTABLE = {
	{0, 0}, {1, 0},
	{0, 1}, {1, 1}
};

[maxvertexcount(4)]
void GS(point VS_OUT In[1],
	inout TriangleStream<GS_OUT> Stream)
{
	uint iv = In[0].iv;
	if (iv >= CID_GetCount()) return;
	
	uint ID = CID_GetID(iv);
	Particle p = Particles[ID];
	
	if ((DefaultColor * p.Color).a <= 0
		|| DefaultSize * p.Size <= 0)
		return;
	
	float4 P;
	GS_OUT Output = (GS_OUT)0;
	Output.Color = p.Color;
	
	for (int i = 0; i < 4; i++)
	{
		float3 vP = p.Position + mul(Quad[i] * DefaultSize * p.Size, (float3x3)tVI);
		P = mul(float4(vP, 1), tW);
		P = mul(P, tVP);
		Output.Position = P;
		Output.TexCoord = TexCoord[i];
		Stream.Append(Output);
	}
	
	Stream.RestartStrip();	
}

float4 PS(GS_OUT Input) : SV_Target {
	float2 uv = Input.TexCoord.xy;
	
	float4 C = Texture0.SampleLevel(s0, uv, 0);
	C *= DefaultColor * Input.Color;
	
	if (CircleShape && length(uv - 0.5) > 0.5)
		discard;
	
	return C;
}

technique10 Sprite {
	pass P0 {
		SetVertexShader(CompileShader(vs_5_0, VS()));
		SetGeometryShader(CompileShader(gs_4_0, GS()));
		SetPixelShader(CompileShader(ps_4_0, PS()));
	}
}
