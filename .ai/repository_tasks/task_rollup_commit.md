## Task: Generate Roll-up Commit Message

### Preparation — determine scope

**If the diff includes an updated `CHANGELOG.md`** (check this first, before any
directory-based scoping):
- Treat this as a release-level commit. Scope the full range since the last tagged
  release (`<last-tag>..HEAD`), repo-wide — ignore any directory specified in the request.
- Use the CHANGELOG's Added/Updated/Removed entries as the source of truth for
  classification in Step 2, rather than re-deriving categories independently from the
  raw diff. The commit message's three sections should match the CHANGELOG entry's
  content (not necessarily word-for-word, but no omissions or additions).

**If the request specifies a directory name** (e.g., "Generate commit for ci-sto-hcr-standard"):
- Restrict all git operations below to that directory only.

**If the request is generic** (e.g., "Generate a commit" with no directory specified):
- Run `git diff main..HEAD --name-only` to identify which root-level directories changed.
- Process the commit covering all affected directories.

### Steps

1. **Gather the commit range.** Collect all commits and changes since this branch diverged
   from `main`, scoped per the Preparation step above (e.g. `git log main..HEAD -- <dir>`
   when a directory is specified, or `git log main..HEAD` otherwise), including commit
   messages and the files/diffs touched.

2. **Branch on commit type, determined in Preparation:**

   **If this is a standard, non-CHANGELOG commit:**
   - Skip classification — go straight to writing a one-line summary (3-6 words) naming
     the overall theme of the change, e.g. `Fix retry logic in provisioning handler`.
   - Write that single line to `<COMMITMSG location>` and stop. Do not add
     Added/Updated/Removed sections.

   **If this is a CHANGELOG-based commit:**
   - **Classify the changes** into exactly three categories, using the CHANGELOG's
     Added/Updated/Removed entries as the source of truth (per the Preparation section),
     supplemented by the file-level diff where needed:
     - **Added** — new files, features, or capabilities
     - **Updated** — modifications to existing files or behavior
     - **Removed** — deleted files, deprecated features, or removed functionality
   - **Write a one-line summary** at the top in this exact format:
     `<3-6 word thematic summary of the overall changes>`
     The summary should name the 2-3 biggest themes across all categories (e.g.,
     "Infrastructure modernization, plugin updates, and operational improvements"), not
     restate every category.
   - **Assemble the extended message** and write it to `<COMMITMSG location>` in this
     exact structure:

```
<One-line summary>

Added:
    - new files, features, or capabilities
    - etc...
Updated:
    - modifications to existing files or behavior
    - etc...
Removed:
    - deleted files, deprecated features, or removed functionality
    - etc...
```
