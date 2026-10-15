## Task: Update CHANGELOG.md

### Preparation

Before proceeding with the CHANGELOG modification,
1. **Check Current Branch for CHANGELOG edits** - HALT processing and raise an issue to the user if the CHANGELOG has been edited in the branch.
1. **Read and Execute** `.ai/repository_tasks/task_determine_next_version.md`
2. **Identify new tag version:** Set the `${NewVersionTag}$` value to the identified tags

### Steps
1. **Scope the diff.** This runs in the release pipeline immediately after a merge to main,
    before the new tag is cut. Determine the most recent existing tag automatically (e.g.
    via git describe --tags --abbrev=0) and diff it against the current HEAD on main (i.e.
    <most-recent-tag>..HEAD). Identify all changes (added, modified, deleted files) in that
    range, restricted to this repository and its subdirectories. Ignore changes elsewhere \
    in the repo.

2. **Classify the changes** into exactly three categories:
   - **Added** — new files, features, or capabilities
   - **Updated** — modifications to existing files or behavior
   - **Removed** — deleted files, deprecated features, or removed functionality

3. **Read `CHANGELOG.md`** first to learn its existing formatting conventions
   (heading levels, date/version format, bullet style, section ordering, tone/verbosity of
   entries). Match that style exactly — do not introduce a new format.

4. **Write the new entry** under version `${NewVersionTag}$` (or the next appropriate unreleased section,
   matching whatever convention the file already uses for in-progress vs. released versions).
   Include only the three sections above, and only include a section if it has at least one
   change to report.

5. **Keep entries concise** — one line per change, written in the same voice/tense as existing
   entries. Do not editorialize or add commentary outside the established format.

6. Do not modify anything outside `CHANGELOG.md`.

7. **Store Tag Value** - Write tag value in the root file `.repo_version`
