ByteAddressBuffer SummedAreaBuffer;

uint Count = 1;
uint PrimitiveCount = 1;

struct VS_IN_OUT {
	float3 Pos : POSITION;
	float3 Normal : NORMAL;
	float2 TextureCoord : TEXCOORD0;
};

struct GS_OUT {
	float3 Pos : POSITION;
	float3 Normal : NORMAL;
	float2 TextureCoord : TEXCOORD;
};

VS_IN_OUT VS(VS_IN_OUT input)
{
	return input;
}

////////////////////////////////////////////////////////////////////////////////

float Seed = 0;

float rand(float2 p) {
   float2 r = float2(23.14069263277926, 2.665144142690225);
   return frac(cos(dot(p, r)) * 123456.);
}

float urand(float seed) {
    return rand(float2(Seed, seed));
}

float rand(float seed) {
    return urand(seed) * 2.0 - 1.0;
}

////////////////////////////////////////////////////////////////////////////////
[maxvertexcount(128)]
void GS(triangle VS_IN_OUT input[3],
	inout PointStream<GS_OUT> outStream,
	uint pID : SV_PrimitiveID)
{
    GS_OUT output = (GS_OUT)0;
	
	float3 p = input[0].Pos;
	float3 v0 = input[1].Pos - input[0].Pos;
	float3 v1 = input[2].Pos - input[0].Pos;
	
	float area = length(cross(v0, v1)) / 2;
	
	float SummedArea = asfloat(SummedAreaBuffer.Load(0));
	float pct = area / SummedArea;

	float N = min(Count * pct, 128) - 1 + rand(pID);
	
	for (int i = 0; i < N; i++)
	{
		float u = urand((i * 1.23 + pID));
		float v = urand((i * 4.56 + pID));
		
		if (u + v > 1)
		{
			u = 1 - u;
			v = 1 - v;
		}
		
		output.Pos = p + v0 * u + v1 * v;
		output.Normal = input[0].Normal
			+ (input[1].Normal - input[0].Normal) * u
			+ (input[2].Normal - input[0].Normal) * v;
		output.TextureCoord = input[0].TextureCoord
			+ (input[1].TextureCoord - input[0].TextureCoord) * u
			+ (input[2].TextureCoord - input[0].TextureCoord) * v;
		
		outStream.Append(output);
		outStream.RestartStrip();
	}
}

GeometryShader StreamOutGS = ConstructGSWithSO(CompileShader(gs_4_0, GS()),
	"POSITION.xyz;NORMAL.xyz;TEXCOORD.xy;", NULL, NULL, NULL, -1);

technique10 Scatter
{
    pass PP2
    {
        SetVertexShader( CompileShader( vs_4_0, VS() ) );
        SetGeometryShader( StreamOutGS );
    }  
}