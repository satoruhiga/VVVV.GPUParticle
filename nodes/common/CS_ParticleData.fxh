struct Particle {
	float Age;
	float Life;
	float3 Position;
	float3 Velocity;
	float3 Force;
	float4 Color;
	float Size;
	float Mass;
};

bool isAlive(Particle p) {
	return p.Age < p.Life;
}