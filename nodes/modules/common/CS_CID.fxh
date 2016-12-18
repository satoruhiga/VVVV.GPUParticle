StructuredBuffer<uint> IDs;
ByteAddressBuffer CopyCounterBuffer;

uint CID_GetCount() {
	return CopyCounterBuffer.Load(0);
}

uint CID_GetID(uint N) {
	return IDs[N];
}