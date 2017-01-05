#include "../../common/CID.fxh"
#include "../ParticleData.fxh"
#include "./LineData.fxh"

uint Count = 0;
float MaxDistance = 1;
float MinDistance = 0.001;

StructuredBuffer<Particle> Input;
RWStructuredBuffer<LineData> Data : BACKBUFFER;

////////////////////////////////////////////////////////////////////////////////

[numthreads(64, 1, 1)]
void CS(
	uint3 dtid : SV_DispatchThreadID)
{
	if (dtid.x >= Count*Count) return;
	
	uint ROW = dtid.x / Count;
	uint COL = dtid.x % Count;
	
	if (ROW >= COL) return;
	
	uint CID_Count = CID_GetCount();
	if (ROW >= CID_Count) return;
	if (COL >= CID_Count) return;
	
	uint ROW_ID = CID_GetID(ROW);
	uint COL_ID = CID_GetID(COL);
	
	Particle row_p = Input[ROW_ID];
	Particle col_p = Input[COL_ID];
	
	float dist = length(row_p.Position - col_p.Position);
	if (dist > MinDistance && dist < MaxDistance)
	{
		int cnt = Data.IncrementCounter();
		LineData d;
		d.From = ROW_ID;
		d.To = COL_ID;
		d.Distance = dist;
		Data[cnt] = d;
	}
}

technique11 Update {
	pass P0 {
		SetComputeShader( CompileShader( cs_5_0, CS() ) );
	}
}
