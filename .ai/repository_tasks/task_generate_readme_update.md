## Task: Update README.md

### Preparation
_Note: This repository contains a mono-repo of Terraform templates, each includes its own README._

Before proceeding with the README modification, determine scope:

**If the request specifies a directory name** (e.g., "Update README for ci-sto-hcr-standard")
- Skip the git diff check; update that specific directory's README directly

**If the request is generic** (e.g., "Update the README" with no directory specified)
- Run `git diff main..HEAD --name-only` to identify which root-level directories changed
- Update READMEs only for those affected directories

**If the request says "all"** (e.g., "Update all READMEs")
- Scan all directories and update all READMEs

Then perform the steps independently per identified directory.

### Steps

For each identified directory, known as `${WorkingDirectory}$`:
1. **Read the current README.** Load `${WorkingDirectory}$/README.md` in full to understand what is currently documents: structure, file/module descriptions, setup steps, usage examples, and any conventions (heading levels, tone, level of detail, code block style).

2. **Inventory the actual directory.** Walk this repository and its subdirectories to see what currently exists — files, modules, scripts, configs, subdirectories. **Do not rely on git history or diffs**; evaluate the present state of the filesystem as the source of truth.

3. **Identify discrepancies** between the README and reality, such as:
   - Files, modules, or subdirectories that exist but aren't documented
   - Documented files, functions, or paths that no longer exist
   - Usage examples, commands, or config references that no longer match current behavior
   - Outdated structure diagrams or file trees
   - Stale version numbers or references

4. **Update only what's inaccurate or missing.** Preserve all still-accurate content as-is.
   Match the existing README's formatting conventions exactly — do not restructure sections,
   change tone, or introduce a new style.

5. **Do not modify anything outside README.md** files within `${WorkingDirectory}$` and its subdirectories.
