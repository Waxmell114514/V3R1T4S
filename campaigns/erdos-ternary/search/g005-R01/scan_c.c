/* g005-R01: timing probe for the "scan" tree (multi-member nodes expanded, single-member chains scanned).
 * Not a checker (no E handling beyond r in {0,2,8}, no fallback past 40 trits: a chain that needs more
 * than 40 trits is counted in `deep` and abandoned). Used only to estimate compiled cost per unit.
 * usage: scan_c K      (N = 2*3^K, K <= 30)
 * prints: K multi chains trits deep seconds ns_per_unit */
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <time.h>
typedef unsigned __int128 u128;
#define L 40
static uint64_t M3, P3[L + 1], PK[64], G1[64], G2[64];
static uint64_t N;
static uint64_t multi, chains, trits, deep;

static void dfs(int k, uint64_t r, uint64_t v) {
  /* (k, r) alive: trit k-1 of v is not 2, r <= N */
  if (r + PK[k] <= N) {
    multi++;
    uint64_t vs[3] = {v, (uint64_t)((u128)v * G1[k] % M3), (uint64_t)((u128)v * G2[k] % M3)};
    for (int j = 0; j < 3; j++) {
      uint64_t rr = r + j * PK[k];
      if (rr > N) continue;
      if ((vs[j] / P3[k]) % 3 == 2) continue;
      dfs(k + 1, rr, vs[j]);
    }
    return;
  }
  chains++;
  if (r == 0 || r == 2 || r == 8) return;
  uint64_t x = v / P3[k];
  for (int i = k; i < L; i++) {
    trits++;
    if (x % 3 == 2) return;
    x /= 3;
  }
  deep++;
}

int main(int argc, char **argv) {
  int K = atoi(argv[1]);
  P3[0] = 1; for (int i = 1; i <= L; i++) P3[i] = P3[i - 1] * 3;
  M3 = P3[L];
  N = 2; for (int i = 0; i < K; i++) N *= 3;
  uint64_t p = 2;
  for (int k = 1; k < 40; k++) {
    PK[k] = p;
    /* 2^p mod 3^L */
    uint64_t b = 2, e = p, acc = 1;
    while (e) { if (e & 1) acc = (u128)acc * b % M3; b = (u128)b * b % M3; e >>= 1; }
    G1[k] = acc; G2[k] = (u128)acc * acc % M3;
    p *= 3;
  }
  struct timespec t0, t1;
  clock_gettime(CLOCK_MONOTONIC, &t0);
  dfs(1, 0, 1);
  clock_gettime(CLOCK_MONOTONIC, &t1);
  double s = (t1.tv_sec - t0.tv_sec) + 1e-9 * (t1.tv_nsec - t0.tv_nsec);
  printf("%d %lu %lu %lu %lu %.3f %.2f\n", K, multi, chains, trits, deep, s, 1e9 * s / (multi + chains));
  return 0;
}
