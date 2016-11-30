struct AgeLife {
	float Age;
	float Life;
};

void InitAgeLife(inout AgeLife p) {
	p.Age = 0;
	p.Life = -1;
}

bool IsAlive(AgeLife p) {
	return p.Life >= 0 && p.Age < p.Life;
}

void MakeActive(inout AgeLife p, float Life) {
	p.Age = 0;
	p.Life = Life;
}
