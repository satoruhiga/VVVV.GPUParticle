#include "../ParticleData.fxh"
#include "./LineData.fxh"

StructuredBuffer<Particle> Particles;
StructuredBuffer<LineData> Lines;

ByteAddressBuffer CopyCounterBuffer;

cbuffer Params : register(b0) {
	float4x4 tVP : VIEWPROJECTION;
	float4x4 tW : WORLD;
	float4x4 tWV : WORLDVIEW;
	float4x4 tP : PROJECTION;
	
	float MaxDistance = 1;
	float MinDistance = 0.001;
	
	float Gamma = 1;
	float Width = 0.1;
	float Margin = 0;
	
	float4 DefaultColor <bool color = true; > = { 1, 1, 1, 1 };
};

Texture2D Texture0 <string uiname = "Texture"; >;
SamplerState s0 <string uiname = "Sampler"; > {
	Filter = MIN_MAG_MIP_LINEAR; AddressU = CLAMP; AddressV = CLAMP;
};

static const float Range = MaxDistance - MinDistance;

interface iFalloff {
	float Get(float v);
};

class cDefault : iFalloff {
	float Get(float v) {
		return 1 - (abs(v - MinDistance) / Range);
	}
};

class cRanged : iFalloff {
	float Get(float v) {
		return 1 - abs(((v - MinDistance) / Range) - 0.5) * 2;
	}
};

cDefault Default;
cRanged Ranged;

iFalloff Falloff <string linkclass="Default,Ranged";>;

struct VS_IN {
	uint iv : SV_VertexID;
};

struct VS_OUT {
	uint iv : TEXCOORD0;
};

struct GS_OUT {
	float4 Position : SV_POSITION;
	float4 Color : COLOR;
	float2 TexCoord : TEXCOORD0;
};

VS_OUT VS(VS_IN Input) {
	VS_OUT Output;
	Output.iv = Input.iv;
	return Output;
}

////////////////////////////////////////////////////////////////////////////////

[maxvertexcount(4)]
void GS_Squared(point VS_OUT In[1],
	inout TriangleStream<GS_OUT> Stream)
{
	uint iv = In[0].iv;
	uint CID_Count = CopyCounterBuffer.Load(0);
	
	if (iv >= CID_Count) return;
	
	LineData line_data = Lines[iv];
	
	float A = Falloff.Get(line_data.Distance);
	
	GS_OUT Output = (GS_OUT)0;
	
	Particle p0 = Particles[line_data.From];
	Particle p1 = Particles[line_data.To];
		
	float A0 = pow(p0.Color.a * p0.Size * A, Gamma);
	float A1 = pow(p1.Color.a * p1.Size * A, Gamma);
	
	if (A0 <= 0 || A1 <= 0) return;
	
	float tWidth = Width;
	float4 P = 0;
	
	const float3 mV = p0.Position - p1.Position;
	const float3 mN = normalize(mV);
	const float mLength = length(mV);
	float tMargin = Margin;
	
	if (mLength - tMargin * 2 < tWidth * 2)
		tMargin = (mLength - (tWidth * 2)) / 2;
	
	const float3 mMarginVec = mN * (mLength - tMargin);
	
	const float4 WVP0 = mul(float4(p0.Position - mMarginVec, 1), tWV);
	const float4 WVP1 = mul(float4(p1.Position + mMarginVec, 1), tWV);
	
	const float3 vZt = float3(0, 0, 1);
	const float3 vX = normalize(WVP0.xyz - WVP1.xyz);
	const float3 vY = cross(vX, vZt);
	const float3 vZ = cross(vX, vY);
	
	float3x3 vR = float3x3(vX, vY, vZ);
		
	// 0
	{
		P = WVP0;
		P.xyz += (mul(float3(0, -1, 0), vR) * tWidth) / P.w;
		P = mul(P, tP);
		Output.Position = P;
		Output.Color = float4(p0.Color.rgb, A0);
		Output.TexCoord = float2(0, 0);
		Stream.Append(Output);	
	}
	
	// 1
	{
		P = WVP0;
		P.xyz += (mul(float3(0, 1, 0), vR) * tWidth) / P.w;
		P = mul(P, tP);
		Output.Position = P;
		Output.Color = float4(p0.Color.rgb, A0);
		Output.TexCoord = float2(0, 1);
		Stream.Append(Output);	
	}
			
	// 3
	{
		P = WVP1;
		P.xyz += (mul(float3(0, -1, 0), vR) * tWidth) / P.w;
		P = mul(P, tP);
		Output.Position = P;
		Output.Color = float4(p1.Color.rgb, A1);
		Output.TexCoord = float2(1, 0);
		Stream.Append(Output);
	}
	
	// 4
	{
		P = WVP1;
		P.xyz += (mul(float3(0, 1, 0), vR) * tWidth) / P.w;
		P = mul(P, tP);
		Output.Position = P;
		Output.Color = float4(p1.Color.rgb, A1);
		Output.TexCoord = float2(1, 1);
		Stream.Append(Output);
	}

	Stream.RestartStrip();
}

float4 PS_Squared(GS_OUT Input) : SV_Target {
	float2 uv = Input.TexCoord.xy;
	
	float4 C = Texture0.SampleLevel(s0, uv, 0);
	C *= DefaultColor * Input.Color;
	return C;
}

technique10 Squared {
	pass P0 {
		SetVertexShader(CompileShader(vs_5_0, VS()));
		SetGeometryShader(CompileShader(gs_5_0, GS_Squared()));
		SetPixelShader(CompileShader(ps_4_0, PS_Squared()));
	}
}

////////////////////////////////////////////////////////////////////////////////

[maxvertexcount(8)]
void GS_Rounded(point VS_OUT In[1],
	inout TriangleStream<GS_OUT> Stream)
{
	uint iv = In[0].iv;
	uint CID_Count = CopyCounterBuffer.Load(0);
	
	if (iv >= CID_Count) return;
	
	LineData line_data = Lines[iv];
	
	float A = Falloff.Get(line_data.Distance);
	
	GS_OUT Output = (GS_OUT)0;
	
	Particle p0 = Particles[line_data.From];
	Particle p1 = Particles[line_data.To];
		
	float A0 = pow(p0.Color.a * p0.Size * A, Gamma);
	float A1 = pow(p1.Color.a * p1.Size * A, Gamma);
	
	if (A0 <= 0 || A1 <= 0) return;
	
	float tWidth = Width;
	
	float4 P = 0;
	
	const float3 mV = p0.Position - p1.Position;
	const float3 mN = normalize(mV);
	const float mLength = length(mV);
	float tMargin = Margin;
	
	if (mLength - tMargin * 2 < tWidth * 2)
		tMargin = (mLength - (tWidth * 2)) / 2;
	
	const float3 mMarginVec = mN * (mLength - tMargin);
	const float3 mMarginVec2 = mN * (mLength - tMargin - tWidth * 1);
	
	const float4 WVP0 = mul(float4(p0.Position - mMarginVec, 1), tWV);
	const float4 WVP1 = mul(float4(p1.Position + mMarginVec, 1), tWV);
	
	const float4 WVPH0 = mul(float4(p0.Position - mMarginVec2, 1), tWV);
	const float4 WVPH1 = mul(float4(p1.Position + mMarginVec2, 1), tWV);
	
	const float3 vZt = float3(0, 0, 1);
	const float3 vX = normalize(WVP0.xyz - WVP1.xyz);
	const float3 vY = cross(vX, vZt);
	const float3 vZ = cross(vX, vY);
	
	float3x3 vR = float3x3(vX, vY, vZ);
	
	// y->
	// 0-2-4-6
	// |/|/|/|
	// 1-3-5-7
	//
	
	// 0
	{
		P = WVP0;
		P.xyz += (mul(float3(0, -1, 0), vR) * tWidth) / P.w;
		P = mul(P, tP);
		Output.Position = P;
		Output.Color = float4(p0.Color.rgb, A0);
		Output.TexCoord = float2(0, 0);
		Stream.Append(Output);	
	}
	
	// 1
	{
		P = WVP0;
		P.xyz += (mul(float3(0, 1, 0), vR) * tWidth) / P.w;
		P = mul(P, tP);
		Output.Position = P;
		Output.Color = float4(p0.Color.rgb, A0);
		Output.TexCoord = float2(0, 1);
		Stream.Append(Output);	
	}
	
	// 2
	{
		P = WVPH0;
		P.xyz += (mul(float3(0, -1, 0), vR) * tWidth) / P.w;
		P = mul(P, tP);
		Output.Position = P;
		Output.Color = float4(p0.Color.rgb, A0);
		Output.TexCoord = float2(0.5, 0);
		Stream.Append(Output);	
	}
	
	// 3
	{
		P = WVPH0;
		P.xyz += (mul(float3(0, 1, 0), vR) * tWidth) / P.w;
		P = mul(P, tP);
		Output.Position = P;
		Output.Color = float4(p0.Color.rgb, A0);
		Output.TexCoord = float2(0.5, 1);
		Stream.Append(Output);	
	}
	
	// 4
	{
		P = WVPH1;
		P.xyz += (mul(float3(0, -1, 0), vR) * tWidth) / P.w;
		P = mul(P, tP);
		Output.Position = P;
		Output.Color = float4(p1.Color.rgb, A1);
		Output.TexCoord = float2(0.5, 0);
		Stream.Append(Output);	
	}
	
	// 5
	{
		P = WVPH1;
		P.xyz += (mul(float3(0, 1, 0), vR) * tWidth) / P.w;
		P = mul(P, tP);
		Output.Position = P;
		Output.Color = float4(p1.Color.rgb, A1);
		Output.TexCoord = float2(0.5, 1);
		Stream.Append(Output);	
	}
	
	// 6
	{
		P = WVP1;
		P.xyz += (mul(float3(0, -1, 0), vR) * tWidth) / P.w;
		P = mul(P, tP);
		Output.Position = P;
		Output.Color = float4(p1.Color.rgb, A1);
		Output.TexCoord = float2(1, 0);
		Stream.Append(Output);
	}
	
	// 7
	{
		P = WVP1;
		P.xyz += (mul(float3(0, 1, 0), vR) * tWidth) / P.w;
		P = mul(P, tP);
		Output.Position = P;
		Output.Color = float4(p1.Color.rgb, A1);
		Output.TexCoord = float2(1, 1);
		Stream.Append(Output);
	}

	Stream.RestartStrip();
}

float4 PS_Rounded(GS_OUT Input) : SV_Target {
	float2 uv = Input.TexCoord.xy;
	
	if (length(uv - 0.5) > 0.5)
		discard;
	
	float4 C = Texture0.SampleLevel(s0, uv, 0);
	C *= DefaultColor * Input.Color;
	return C;
}

technique10 Rounded {
	pass P0 {
		SetVertexShader(CompileShader(vs_5_0, VS()));
		SetGeometryShader(CompileShader(gs_5_0, GS_Rounded()));
		SetPixelShader(CompileShader(ps_4_0, PS_Rounded()));
	}
}
