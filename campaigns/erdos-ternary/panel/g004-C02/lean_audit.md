# Lean audit g004-C02 (in progress)
- Verbatim check of moved definitions: code identical modulo ℕ→Nat (only one docstring shortened).
- ETNative.lean: no imports, no extern/implemented_by/export/unsafe/partial/opaque/set_option/macro/attribute (only matches are in comments).
- lakefile: only change is the ETNative [[lean_lib]] block; no link-arg/extraDepTargets tricks.
- Rebuild running.
