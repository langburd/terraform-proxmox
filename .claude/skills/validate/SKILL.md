---
name: validate
description: Run full validation suite (tofu validate, tflint, checkov) before opening a PR or applying changes. Use to catch issues before they reach production.
---

Run the following validation commands in sequence and report any failures:

```bash
tofu validate
tflint --recursive
checkov -d . --quiet
```

Report results in a table:

| Check | Status | Details |
|-------|--------|---------|
| tofu validate | ... | ... |
| tflint | ... | ... |
| checkov | ... | ... |

If all pass, say so clearly. If any fail, quote the error and suggest a fix.
