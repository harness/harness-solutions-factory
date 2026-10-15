## Task: Determine Next Version

Inputs: most recent tag (from git describe --tags --abbrev=0), diff range <most-recent-tag>..HEAD

###  Steps
1. **Enumerate changed paths.** From the diff range, collect the full list of changed files and derive the set of distinct root-level directories touched (e.g. terraform/foo, terraform/bar).
2. **Is this a new addition or an update?** Check the changes:
    - **New single root-level directory added?** - Likely a **Minor** change
    - **Majority of root-level directories changed?** - Likely a **Major** change
    - **One or more root-level directories changed?** - Likely a **Minor** change
    - **Update existing directories?** - Likely a **Patch** change
3. **If a Major change identified,** evaulate section `Rule: Infrastructure File Exemption`
4. **Classify the bump using these rules, in order**:
    - **Major** — changes touch root-level directories representing more than half of all root-level directories in the repo, OR any file is deleted/renamed in a way that removes a previously published root-level folder entirely.
    - **Minor** — changes add one or more new root-level directories that did not exist at the previous tag (ALWAYS check if directories are new, not just modified).
    - **Patch** — all changed files fall within one or more existing root-level directories only (no new directories created, no existing directories deleted).
    - If changes span multiple existing root-level directories but add no new ones and remove none, default to Minor (cross-cutting but non-breaking) — flag this case explicitly in the output so the user can override.
3. *Compute the next version* by bumping the appropriate segment of the most recent tag (semver: MAJOR.MINOR.PATCH), resetting lower segments to 0.
4. **On Major classification**, halt and request confirmation rather than proceeding automatically. Output: the classification reasoning, the list of root-level directories affected vs. total, and an explicit prompt for the user/approver to confirm the Major bump before the pipeline continues.
5. **Emit the result** (current tag, classification, next version) as pipeline output variables for downstream steps (changelog, tagging) to consume.

### Rule: Infrastructure File Exemption

**Define an exempt path set** (repo-root-relative, matched by prefix or exact name):

- README*
- mise.toml
- Makefile
- .ai/
- .harness/
- .devcontainer/
- scaffolds/
- LICENSE
- providers.tf.example
- .gitignore
- .editorconfig
- CONTRIBUTING.md

**Apply before classification, not after:**

1. From the full changed-file list, partition into two sets: `exempt` (matches the list above) and `substantive` (everything else).
2. Run the Major/Minor/Patch classification (root-directory counting, new-folder detection, etc.) using **only the `substantive` set**. Exempt files are invisible to that logic — they never count toward "new root-level folder" or "majority of repo" thresholds.
3. **If `substantive` is empty** (i.e., every changed file matched the exempt list), classify the release as **Patch**, regardless of how many exempt files changed or how widely they're spread (e.g., touching `.harness/`, `README.md`, and `.editorconfig` together is still Patch).
4. **If `substantive` is non-empty**, classify normally based on `substantive` alone, and ignore the exempt files entirely when computing the bump (they neither upgrade nor downgrade the result).
