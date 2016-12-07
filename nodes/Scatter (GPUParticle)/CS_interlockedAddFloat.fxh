void interlockedAddFloat(RWByteAddressBuffer b, uint addr, float value)
{
	uint comp, orig = b.Load(addr);
	[allow_uav_condition]do {
		b.InterlockedCompareExchange(addr, 
			comp = orig, 
			asuint(asfloat(orig) + value), 
			orig);
	}
	while(orig != comp);
}