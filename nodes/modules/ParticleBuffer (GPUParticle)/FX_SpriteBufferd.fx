#include "../common/CS_CID.fxh"
#include "CS_ParticleData.fxh"

StructuredBuffer<Particle> Particles;

float DefaultSize = 1;
float4 DefaultColor <bool color = true; > = { 1, 1, 1, 1 };

Texture2D Texture0 <string uiname = "Texture"; >;

SamplerState s0 <string uiname = "Sampler"; > {
	Filter = MIN_MAG_MIP_LINEAR; AddressU = CLAMP; AddressV = CLAMP;
};

cbuffer cbControls : register(b0) {
	float4x4 tVP : VIEWPROJECTION;
	float4x4 tVI : VIEWINVERSE;
	float4x4 tW : WORLD;
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
};

/*
struct VS_OUTvel {
	float4 PosWVP:SV_POSITION;
	float2 TexCd:TEXCOORD0;
	float4 PosW:TEXCOORD1;
	float Size : TEXCOORD2;
	float4 Color:COLOR0;
	float3 vel : TEXCOORD3;
};
*/

VS_OUT VS(VS_IN Input) {
	VS_OUT Output;
	Output.iv = Input.iv;
	return Output;
}

/*
VS_OUTvel VSvel(VS_IN In) {
	VS_OUTvel Out = (VS_OUTvel)0;

	// get buffer count
	uint sCount, cCount, dummy;	
	sbSize.GetDimensions(sCount,dummy);
	sbColor.GetDimensions(cCount,dummy);
	// set default value for buffer if empty
	float size = defaultSize;
	float4 color = defaultColor; 
	if(sCount>0) size = sbSize[In.iv % sCount] * defaultSize;
	if(cCount>0) color = sbColor[In.iv % cCount];
	
	float3 p = sbPos[In.iv];

	float4 PosW = mul(float4(p, 1), tW);
	Out.PosW = PosW;
	Out.PosWVP = mul(PosW, tVP);
	//Out.TexCd = 0;
	Out.Size = size;
	Out.Color = color;
	float3 velocity = sbVel[In.iv];
	velocity *= step(length(velocity),MaxVelLength);
	Out.vel = velocity;
	return Out;
}
*/

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
	
	float4 P;
	GS_OUT Output = (GS_OUT)0;
	
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
	
	/*
	for (int i = 0; i<4; i++) {
		Out.TexCd = g_texcoords[i].xy;

		Out.PosWVP = mul(float4(In[0].PosW.xyz + In[0].Size*mul(float4(g_positions[i].xyz, 1), (float3x3)tVI), 1), tVP);
		SpriteStream.Append(Out);
	}
	*/
	
	
}

/*
[maxvertexcount(4)]
void gsSPRITETail(point VS_OUTvel In[1], inout TriangleStream<VS_OUTvel> SpriteStream)
{
	VS_OUTvel Out = In[0];
	
	float3 p=In[0].PosW.xyz;
	float3 vel=In[0].vel;
	float3 camPos=mul(float4(0,0,0,1),tVI).xyz;
	float3 View = p - camPos;
	View = normalize(View);
	float3 upVector = normalize(vel+.0000001*float3(0,1,0));//float3(1, 1, 0);
	float3 rightVector = normalize(cross(View, upVector));
	
	
	float size =In[0].Size;
	
	upVector*=size;
	upVector*=1+TailLength*40*(length(vel));
	rightVector*=size;
	Out.TexCd=float2(1,1);
    Out.PosWVP = mul(float4(p+rightVector+upVector,1.0),tVP);  
    SpriteStream.Append(Out);
	Out.TexCd=float2(0,1);
	Out.PosWVP = mul(float4(p-rightVector+upVector,1.0),tVP);  
    SpriteStream.Append(Out);
	Out.TexCd=float2(1,0);
	Out.PosWVP = mul(float4(p+rightVector-upVector*1,1.0),tVP);  
    SpriteStream.Append(Out);
	Out.TexCd=float2(0,0);
	Out.PosWVP = mul(float4(p-rightVector-upVector*1,1.0),tVP);  
    SpriteStream.Append(Out);
	SpriteStream.RestartStrip();
}
*/

float4 PS(GS_OUT Input) : SV_Target {
	/*
	if (circleCut && length(In.TexCd.xy-.5)>0.5) discard;
	
	float4 c = tex0.SampleLevel(s0,In.TexCd.xy,0);
	
	if (alphaCut && c.a < AlphaDiscard) discard;
	
	c = c*In.Color;
	return c;
	*/
	
	float2 uv = Input.TexCoord.xy;
	
	float4 c = Texture0.SampleLevel(s0, uv, 0);
	
	if (length(uv - 0.5) > 0.5)
		discard;
	
	return c * DefaultColor;
}

technique10 Sprite {
	pass P0 {
		SetVertexShader(CompileShader(vs_5_0, VS()));
		SetGeometryShader(CompileShader(gs_4_0, GS()));
		SetPixelShader(CompileShader(ps_4_0, PS()));
	}
}

/*
technique10 SpriteTailed {
	pass P0 {
		SetVertexShader(CompileShader(vs_5_0, VSvel()));
		SetGeometryShader(CompileShader(gs_4_0, gsSPRITETail()));
		SetPixelShader(CompileShader(ps_4_0, PS()));
	}
}
*/

