float Seed;

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