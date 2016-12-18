#include "../../common/noiseSimplex.fxh"
#include "../../common/CS_CID.fxh"
#include "../CS_ParticleData.fxh"

float Time = 0;
float persistence = 1.0;
float freq = 1;
float amplitude = 1;
float speed = 1;

RWStructuredBuffer<Particle> Particles : BACKBUFFER;

float3 snoise3D(float3 v)
{
	return float3(
		snoise(v),
		snoise(v + float3(12.34, 56.78, 78.91)),
		snoise(v + float3(23.45, 67.89, 12.34))
	);
}

float3 snoise3D(float3 v, float w)
{
	return float3(
		snoise(float4(v, w)),
		snoise(float4(v + float3(12.34, 56.78, 78.91), w)),
		snoise(float4(v + float3(23.45, 67.89, 12.34), w))
	);
}

////////////////////////////////////////////////////////////////////////////////

#define eps 0.01

float3 ComputeCurl(float x, float y, float z, float w)
{
	float n1, n2, a, b;
	float3 curl;
	
	float inv_eps = 1.0 / (2.0 * eps);
	
	float3 x0 = snoise3D(float3(x + eps, y, z), w);
	float3 x1 = snoise3D(float3(x - eps, y, z), w);
	float3 y0 = snoise3D(float3(x, y + eps, z), w);
	float3 y1 = snoise3D(float3(x, y - eps, z), w);
	float3 z0 = snoise3D(float3(x, y, z + eps), w);
	float3 z1 = snoise3D(float3(x, y, z - eps), w);
		
	curl.x = y1.z - y0.z - z1.y + z0.y;
	curl.y = z1.x - z0.x - x1.z + x0.z;
	curl.z = x1.y - x0.y - y1.x + y0.x;
	
	return (curl * inv_eps);
}

[numthreads(64, 1, 1)]
void CS_SimpleCurlForce(
	uint3 dtid : SV_DispatchThreadID)
{
	if (dtid.x >= CID_GetCount()) { return; }
	uint ID = CID_GetID(dtid.x);
	
	Particle p = Particles[ID];
	float3 v = p.Position * freq;
	float3 f = ComputeCurl(v.x, v.y, v.z, Time * speed);
	Particles[ID].Force += f * 0.0025 * amplitude;
}

technique11 SimpleCurl {
	pass P0 {
		SetComputeShader( CompileShader( cs_5_0, CS_SimpleCurlForce() ) );
	}
}

////////////////////////////////////////////////////////////////////////////////

float3 ComputeCurl(float x, float y, float z, float w, float persistence)
{
	float3 xv = float3(0, 0, 0);
	float3 yv = float3(0, 0, 0);
	float3 zv = float3(0, 0, 0);
	
	float3 p = float3(x, y, z);
	
	for (int i = 0; i < 3; i++)
	{
		float twoPowI = pow(2.0, float(i));
        float scale = 0.5 * twoPowI * pow(persistence, float(i));
		
		xv += snoise3D(p * twoPowI, w) * scale;
		yv += snoise3D((p + float3(123.4, 129845.6, -1239.1)) * twoPowI, w) * scale;
		zv += snoise3D((p + float3(-9519.0, 9051.0, -123.0)) * twoPowI, w) * scale;
	}
	
	return float3(
		zv.y - yv.z,
		xv.z - zv.x,
		yv.x - xv.y
	);
}

[numthreads(64, 1, 1)]
void CS_CurlForce(
	uint3 dtid : SV_DispatchThreadID)
{
	if (dtid.x >= CID_GetCount()) { return; }
	uint ID = CID_GetID(dtid.x);
	
	Particle p = Particles[ID];
	float3 v = p.Position * freq;
	float3 f = ComputeCurl(v.x, v.y, v.z, Time * speed, persistence);
	Particles[ID].Force += f * 0.01 * amplitude;
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
	if (dtid.x >= CID_GetCount()) { return; }
	uint ID = CID_GetID(dtid.x);
	
	Particle p = Particles[ID];
	float3 v = p.Position * freq;
	float3 f = snoise3D(v, Time * speed);
	Particles[ID].Force += f * 0.01 * amplitude;
}

technique11 Simplex {
	pass P0 {
		SetComputeShader( CompileShader( cs_5_0, CS_SimplexForce() ) );
	}
}
