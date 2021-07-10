---
name: Error/crash/problem report
about: Something that should work but does not, or produces wrong results.
---

## Minimal code example to reproduce the problem

> Include a reproducible sample of code that causes the problem. Others should
> be able to reproduce your problem by just copypasting your code into Julia
> shell. Use `download` to get any necessary datasets from the internet.

```
using SBML
download("https://badmodels.org/model1.xml", "model.xml")
readSBML("model.xml")
```

## Expected behavior

> Describe what you expected to happen if the above code worked correctly, and
> why you think that behavior is correct.

## Actual behavior

> What was the unexpected thing that happened instead?

## Optional: Suggestions for fixing

> Feel free to suggest whatever change in the package that might remove the
> described problematic behavior. You may want to open a pull request if you
> already have a fix.
