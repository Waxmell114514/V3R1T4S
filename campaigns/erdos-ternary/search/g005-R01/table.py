"""print the Markdown tables of specs/node-reduction.md from search/g005-R01/out/*.json"""
import json, os
OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'out')
print("| K | baseline candidates | alive | N-leaves | D-leaves | multi-member alive | chains | lower bound 2^K-2 | baseline/(multi+chains) | baseline/lower bound | low trits/chain | top digits/chain | min(low,top)/chain |")
print("|" + "---|" * 13)
for k in range(12, 23):
    d = json.load(open(os.path.join(OUT, f'stats_{k}.json'))); c = d['chains']
    print(f"| {k} | {d['cand']} | {d['alive']} | {d['Nleaf']} | {d['Dleaf']} | {d['multi']} | {c} | {2**k-2} | "
          f"{d['cand']/(d['multi']+c):.3f} | {d['cand']/(2**k-2):.2f} | {d['lowsum']/c:.3f} | {d['highsum']/c:.3f} | {d['minsum']/c:.3f} |")
print()
print("| K | chains | killed by top 1 digit | top <=2 | top <=3 | top <=5 |")
print("|---|---|---|---|---|---|")
for k in (12, 16, 20, 22):
    d = json.load(open(os.path.join(OUT, f'stats_{k}.json'))); c = d['chains']
    print(f"| {k} | {c} | " + " | ".join(f"{d['high%d_kill' % m]/c:.3f}" for m in (1, 2, 3, 5)) + " |")
print()
print("| K | A0 | low-only units | " + " | ".join(['h1/4', 'h1/3', 'h1/2', 'h2/3', 'high']) + " | best ratio |")
print("|" + "---|" * 9)
for f in ['joint_14.json', 'joint_16.json', 'joint_12_a8.json', 'joint_14_a8.json', 'joint_16_a8.json',
          'joint_17.json', 'joint_18_a10.json']:
    d = json.load(open(os.path.join(OUT, f))); s = d['schedules']; lo = s['low']['units']
    print(f"| {d['K']} | {d['A0']} | {lo} | " + " | ".join(str(s[x]['units']) for x in ['h1/4', 'h1/3', 'h1/2', 'h2/3', 'high'])
          + f" | {lo / min(v['units'] for v in s.values()):.3f} |")
