# Goal-Backed Execution

Use Goal mode as a continuity controller around the canonical PDF-to-LaTeX workflow. Keep `conversion-state.md` authoritative for durable project progress; Goal state does not replace project state, evidence, or verification gates.

## Automatic Selection

Prefer Goal-backed execution by default for:

- a full `convert` whose requested result is a completed project rather than an explicitly bounded one-turn draft;
- broad `resume` or `refine` work;
- writable `publication-polish` work;
- long, book-scale, scanned, mixed, math-heavy, encoded-math, or visual-complex work expected to require multiple batches.

Use `one-turn` for work that is genuinely bounded and can finish now. This normally includes a localized `repair`, an ordinary read-only `review`, initial triage without reconstruction, and an explicitly requested one-turn rough draft. Reclassify a repair that expands into broad project improvement as `refine`.

Do not ask for separate Goal confirmation. Start or continue Goal mode immediately when Goal tools are available and the current request, surface-provided starter prompt, or runtime policy permits creation. If the runtime requires Goal intent that the active request does not provide, do not manufacture authorization and do not ask only for Goal permission; fall back to `resumable` and continue at the same delivery level.

## Startup

Resolve Goal state before broad analysis, scaffolding, or writable project work:

1. Resolve the source PDF, target directory, operation, delivery level, and verification scope with minimal read-only inspection. Default ordinary complete work to `clean-semantic`.
2. Check current Goal state when Goal tools are available.
3. Continue an unfinished Goal when its objective matches the same PDF-derived task.
4. When no unfinished Goal conflicts, create a concise Goal immediately if runtime policy permits it.
5. Do not set a token budget unless the user explicitly requested one.
6. Record `Execution mode: goal-backed` only after a matching Goal was created or continued successfully.
7. If Goal tools are unavailable or startup is disallowed, record the reason and use `resumable`.

An unfinished unrelated Goal is a real conflict. Ask the user which objective should remain active instead of replacing it silently. Goal activation must never authorize project overwrite, source replacement, unsafe build capabilities, a delivery downgrade, or a material approximation.

Use an objective equivalent to:

```text
Use $pdf-to-latex to OPERATION SOURCE into TARGET at DELIVERY_LEVEL. Treat TARGET/conversion-state.md as the durable source of progress. On every continuation, verify source identity, follow the recorded Next action, preserve user edits, complete the gates derived from workflow-contract.json, and run scripts/workflow_contract.py to validate the project. Continue automatically until the project reaches a valid complete outcome, a user-approved downgraded outcome, or a true blocker that requires user action.
```

Keep the objective concise. Reference the skill and workflow contract instead of copying every reconstruction and publication rule into the Goal.

## Continuation

On every Goal continuation:

1. Read `conversion-state.md` first when it exists.
2. Verify the recorded source identity before source-aware work.
3. Check that active files and evidence for the recorded checkpoint still exist.
4. Perform the next concrete milestone or bounded batch.
5. Compile and inspect the affected output when the milestone changes final LaTeX.
6. Update state, notes, manifests, and inventories only after supporting files or checks exist.
7. Run the applicable workflow query or validation command and continue while the valid outcome remains `in-progress`.

Do not yield merely because one batch or the first successful compile finished. Continue automatically while meaningful work remains and no user-decision boundary has been reached.

## Completion And Fallback

Mark a matching Goal complete only after the project satisfies the completion rules in `SKILL.md` and the workflow validator accepts the terminal project state. A `downgraded` outcome also requires explicit downgrade approval.

A project blocker does not automatically permit an immediate Goal `blocked` update. Follow the current Goal tool's blocker threshold and terminal-state rules. While that threshold is not met, keep the project blocker specific and preserve its next action without falsely marking completion.

When Goal startup or continuation is unavailable, fall back to `resumable`, keep `conversion-state.md` current, and continue as far as the runtime permits. Never lower delivery quality merely because Goal mode could not start.
