# Acceptance runs that failed validation (kept, not published)

Four acceptance runs on 2026-10-16 completed their timing phases and were then rejected by
`record_run` because the recorder had started writing `host.role` while the schema still forbade it:

```
FAIL .../run.yaml
  schema: $.host: additional properties are not allowed ('role' was unexpected)
```

The fix is toolkit PR #6 (the property is in the schema again, in both copies) and the runs are kept
here because their CSVs hold real chronological samples; they were **not** published and their
manifests are the ones that failed. The acceptance grid was re-run afterwards with the same settings
and the fixed schema.
