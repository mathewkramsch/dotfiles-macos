# Jira Comment Posting Workflow

Before calling `jira_post_jira_issue_comment`, always:

1. Draft the full comment text (following the style guide below).
2. Print the complete draft in the conversation, in full Jira wiki markup, exactly as it will be posted — wrapped in a fenced code block (```). Without the code fence, the chat renderer treats leading `*`/`**` as markdown list syntax and re-renders it, which silently mangles the literal wiki markup (e.g. normalizing `*` bullets to `-` on display/copy). The code fence keeps it literal.
3. Explicitly ask the user to accept, decline, or request adjustments.
4. Do NOT call `jira_post_jira_issue_comment` until the user gives explicit approval of the current draft. If the user requests changes, revise and re-print the full draft for approval again — do not post partial approvals.

# Jira Comment Style Guide

When posting a comment to a Jira issue (`jira_post_jira_issue_comment`), follow this format. It uses Jira wiki markup, not Markdown.

## Structure

- Open with 1-2 plain sentences stating what was done / found — no header needed for this lead-in.
- Break the rest into sections with `h1.` headers (e.g. `h1. Query:`, `h1. Results`, `h1. Summary`, `h1. Examples`, `h1. Testing Considerations`, `h1. Conclusions`, `h1. Next Steps`). Use whichever subset fits the comment — not all sections are required every time.
- Within a section, use bullets (`*`) and nested sub-bullets (`**`) for everything: queries run, results, observations, analysis, actions. Nest code blocks and tables under a bullet line like `* results:` or `* raw JSON result:`.
- Never use markdown-style `-` bullets — Jira wiki markup doesn't render them as a list at all. Always use `*`/`**`, never `-`, for every bullet in every comment.
- Bold (`*text*`) section labels inside a bullet, e.g. `* *Goal*:`, `* *Action*:`, `* *Caveats*:` — the bold label still needs its own leading `*` bullet marker, it doesn't replace it.
- Inline code/field names use `{{monospace}}`, e.g. `{{field_name}}`.
- Fenced code blocks use `{code:JSON}` ... `{code}` for queries and raw results.
- Tables use Jira wiki table syntax: `||Header||Header||` for the header row, `|cell|cell|` for data rows.
- Attach screenshots/visualizations inline with `!filename.jpg|thumbnail!` when available.
- **Max sentence length: 150 characters.** This is not a hard line-wrap rule — don't break a single sentence across lines with `\\`. Instead, keep each sentence itself under 150 chars; if a sentence runs long, rewrite it shorter/more concise rather than wrapping it. This also keeps bullet descriptions from getting too wordy. Multiple short sentences in the same bullet are fine — just don't let any individual sentence exceed 150 chars.
  - Exception: a bare link/URL (`[text|url]`) can't be shortened — if the link itself pushes a line past 150, leave that line as-is and put any surrounding prose in its own sentence.

## Wording

- Bullet points over complete sentences. Fragments are fine.
- Simple, common terminology — no jargon, no fluff, straight to the point.
- Each bullet should carry one fact or one observation, not a paragraph.

## Content expectations

- Show the actual query run (raw JSON in a code block), not just a description of it.
- Show raw results (raw JSON in a code block) AND a formatted table version when the result is tabular.
- Call out what the results mean (e.g. "High max, low p99 → one-off spike"), not just the numbers.
- End investigation comments with concrete next steps — `*Action*:` or `*TODO*:` bullets — and any `*Caveats*:` about the data (partial coverage, early termination, low sample counts, etc.).
