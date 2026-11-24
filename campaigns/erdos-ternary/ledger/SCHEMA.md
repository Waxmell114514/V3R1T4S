experiments.jsonl 每行一条，只追加：
{
"id": "g012-e07",
"parent": "g011-e03",
"track": "C | P",
"milestone": "M2",
"hypothesis": "一句话，只含一个机制",
"prediction": {"metric": "T1.nodes_per_s", "delta": "+40%"},
"touched": ["search/kernel.c"],
"result": {"T0": "pass", "T1.nodes_per_s": 2.1e8, "std": 3e6},
"claim_level": "仅理论轨道：PROVED-HERE | SKETCH | HEURISTIC | SPECULATION | KNOWN",
"verdict": "accept | reject | escalate | failed_T0 | not_implemented",
"lesson": "一句话",
"cost": {"wall_min": 42}
}
prediction 必须在运行评估之前写入。
