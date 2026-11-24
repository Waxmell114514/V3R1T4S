"""Frozen brute force: n in [a, b] such that the ternary expansion of 2^n has no digit 2."""
import sys

def to_base3(x):
    """Ternary digits of x >= 0, least significant first, no trailing zeros (divide and conquer)."""
    w = 32
    while 3 ** w <= x:
        w *= 2
    cache = {}
    def p3(h):
        if h not in cache:
            cache[h] = 3 ** h
        return cache[h]
    def digits(y, w):
        if w <= 32:
            d = []
            for _ in range(w):
                y, t = divmod(y, 3)
                d.append(t)
            return d
        h = w // 2
        hi, lo = divmod(y, p3(h))
        return digits(lo, h) + digits(hi, h)
    d = digits(x, w)
    while d and d[-1] == 0:
        d.pop()
    return d

def no_two(n):
    return 2 not in to_base3(1 << n)

def exceptions(a, b):
    return [n for n in range(a, b + 1) if no_two(n)]

if __name__ == "__main__":
    a, b = int(sys.argv[1]), int(sys.argv[2])
    print(exceptions(a, b))
