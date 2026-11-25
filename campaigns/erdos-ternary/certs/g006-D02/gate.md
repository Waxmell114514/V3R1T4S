# Gate g006-D02 (pilot)

Result: UpTo (2·3^34) = 33,354,363,399,333,138 at tier **B′** (proposals/0003, rule still awaiting human confirmation).
- Condition 1: checkWord_sound tier A (audited g005-C02; re-audited in the recheck container).
- Condition 2: run records for all 8 shards: worker_A.md (0-3), worker_B.md (4-7); all exit 0, sources match sources.sha256.
- Condition 3: independent recheck of max(2, 5%) = 2 random shards (2, 7; seed 202611250604) in a fresh container: pass (recheck.md).
- Condition 4: upTo_34_of_shards (all 8 shard hypotheses → UpTo (2·3^34)) compiled in the main environment, tier A.
Not claimed: tier A or B. The full conjunction was never evaluated in a single environment.
Pilot measurements: setup ≈ 3.3-3.6 min per fresh session; ~18-23 min per shard per core; 8 shards on 2×4 cores ≈ 48 min wall.
This is still below Saye's 2·3^45 and is a formal re-verification of a known range, not a new result.
