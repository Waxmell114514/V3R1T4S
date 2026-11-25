"""check tree_stats.top_digits (frac(r*log_3 2) route) against exact 2^r for 400 <= r < 6000"""
import os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
sys.argv = ['x', '1']
import tree_stats as T
bad = 0; n = 0
for r in range(400, 6000, 7):
    x = 1 << r; s = []
    while x:
        s.append(x % 3); x //= 3
    s.reverse()
    n += 1
    if T.top_digits(r, 30) != s[:30]:
        bad += 1
print('checked', n, 'mismatches', bad)
