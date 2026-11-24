---
name: finding-to-check
description: Every bug that gets fixed also gets the test or lint rule that would have caught it, proven to fail without the fix. Use whenever a bug, finding or review comment is fixed, and when closing a finding in the findings register.
---

# finding-to-check

Rules that live in memory drift; rules in tools don't. A fix without its check can come back the
next time someone builds that part.

1. **Name the class, not the instance.** "The price wrapped apart from 'kr' on the tablet" is an
   instance; "a number split from its unit" is the class. The check targets the class.
2. **Pick the cheapest check that sees it**, in this order: a lint rule (the linter, the type
   checker) → a unit test → a layout check → a browser test → a picture (`picture-check`).
   Shell scripts: a bats test.
3. **Prove it**: the check fails on the code before the fix (check out the fix's parent, or undo
   the fix in the working tree) and passes with it. A check that never failed proves nothing.
4. **Where it lives**:
   - true for every project built the same way → the shared kit or template those projects copy
     from: the check, plus a seeded bad example that proves it fires;
   - true for one repo → that repo's tests or lint config.
5. **Record it** in the findings register (`findings-register`): "✅ fixed in <commit> · check:
   <path or rule>".

A finding that can't get a check (taste, content) says so in the register, with why.
