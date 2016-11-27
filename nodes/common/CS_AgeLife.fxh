struct AgeLife {
	float Age, Life;
};

bool isDead(AgeLife v) {
	return v.Age > v.Life;
}