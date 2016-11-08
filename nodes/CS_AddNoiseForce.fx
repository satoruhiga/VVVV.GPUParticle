#include "libs/noiseSimplex.fxh"

#include "CS_ParticleData.fxh"

uint ThreadCount;

StructuredBuffer<uint> IDs;

RWStructuredBuffer<Particle> Output : BACKBUFFER;

float3 offset = float3(0, 0, 0);
float freq = 1;
float amplitude = 1;

float3 snoise3D(float3 v)
{
	return float3(
		snoise(v),
		snoise(v + float3(12.34, 56.78, 78.91)),
		snoise(v + float3(23.45, 67.89, 12.34))
	);
}

////////////////////////////////////////////////////////////////////////////////

#define eps 0.01

float3 ComputeCurl(float x, float y, float z)
{
	float n1, n2, a, b;
	float3 curl;
	
	float inv_eps = 1.0 / (2.0 * eps);
	
	float3 x0 = snoise3D(float3(x + eps, y, z));
	float3 x1 = snoise3D(float3(x - eps, y, z));
	float3 y0 = snoise3D(float3(x, y + eps, z));
	float3 y1 = snoise3D(float3(x, y - eps, z));
	float3 z0 = snoise3D(float3(x, y, z + eps));
	float3 z1 = snoise3D(float3(x, y, z - eps));
		
	curl.x = y1.z - y0.z - z1.y + z0.y;
	curl.y = z1.x - z0.x - x1.z + x0.z;
	curl.z = x1.y - x0.y - y1.x + y0.x;
	
	return (curl * inv_eps);
}

[numthreads(64, 1, 1)]
void CS_CurlForce(
	uint3 dtid : SV_DispatchThreadID)
{
	if (dtid.x >= ThreadCount) { return; }
	
	uint ID = IDs[dtid.x];
	Particle p = Output[ID];
	
	float3 v = (p.Position + offset) * freq;
	float3 f = ComputeCurl(v.x, v.y, v.z);
	p.Force += f * 0.01 * amplitude;
	Output[ID] = p;
}

technique11 Curl {
	pass P0 {
		SetComputeShader( CompileShader( cs_5_0, CS_CurlForce() ) );
	}
}

////////////////////////////////////////////////////////////////////////////////

[numthreads(64, 1, 1)]
void CS_SimplexForce(
	uint3 dtid : SV_DispatchThreadID)
{
	if (dtid.x >= ThreadCount) { return; }
	
	uint ID = IDs[dtid.x];
	Particle p = Output[ID];
	
	float3 v = (p.Position + offset) * freq;
	float3 f = snoise3D(v);
	p.Force += f * 0.01 * amplitude;
	Output[ID] = p;
}

technique11 Simplex {
	pass P0 {
		SetComputeShader( CompileShader( cs_5_0, CS_SimplexForce() ) );
	}
}
