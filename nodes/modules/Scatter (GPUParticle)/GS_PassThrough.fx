struct VS_IN_OUT {
	float3 Pos : POSITION;
};

struct GS_OUT {
	float3 Pos : POSITION;
};

VS_IN_OUT VS(VS_IN_OUT input)
{
	return input;
}

////////////////////////////////////////////////////////////////////////////////
[maxvertexcount(3)]
void GS(triangle VS_IN_OUT input[3],
	inout TriangleStream<GS_OUT> outStream,
	uint pID : SV_PrimitiveID)
{
    GS_OUT output = (GS_OUT)0;
	
	output.Pos = input[0].Pos;
	outStream.Append(output);
	
	output.Pos = input[1].Pos;
	outStream.Append(output);

	output.Pos = input[2].Pos;
	outStream.Append(output);

	outStream.RestartStrip();
}

GeometryShader StreamOutGS = ConstructGSWithSO(CompileShader(gs_4_0, GS()),
	"POSITION.xyz;", NULL, NULL, NULL, -1);

technique10 PassThrough
{
    pass PP2
    {
        SetVertexShader( CompileShader( vs_4_0, VS() ) );
        SetGeometryShader( StreamOutGS );
    }  
}