# Chat Media Reliability TODO

This feature combines two user-visible reliability problems that share the
same underlying pressure points: replayed chat work can duplicate media-heavy
artifacts, and unbounded photo work can starve the album picker while the user
scrolls.

## Acceptance criteria

- [x] A chat turn displays one artifact per stable destination, including after
      process suspension, task recovery, history pagination, and live updates.
- [x] A later artifact revision replaces the earlier presentation instead of
      appending another card.
- [x] Replaying an identical tool result does not append another artifact
      message to the session.
- [x] Opening the album picker pauses in-progress recent-photo suggestion work.
- [x] Album thumbnails use bounded concurrency, share in-flight requests, and
      cancel work when no visible cell needs it.
- [x] Loading and failed thumbnails have visible, recoverable states rather
      than empty black cells.
- [x] Focused model, service, widget, and storage regression tests pass.
- [x] `flutter test` and `flutter analyze` pass, or any environmental blocker is
      recorded in the handoff.

## Work items

- [x] Seed each turn's artifact collector from persisted session artifacts.
- [x] Distinguish identical artifact replays from meaningful revisions.
- [x] Coalesce artifact revisions in both history and live chat projections.
- [x] Add a cancellable, bounded thumbnail request service with an LRU cache.
- [x] Use the reliable thumbnail loader in the chat image picker.
- [x] Remove unnecessary album filtering and reduce picker page pressure.
- [x] Add cancellation checkpoints to recent-photo suggestion processing.
- [x] Cover task recovery, legacy duplicate history, rapid scrolling, request
      sharing, cancellation, and retry states with tests.

## Verification

- Focused suite: 62 tests passed.
- Full suite: 920 passed, 5 skipped.
- Static analysis: no errors or warnings in changed files. The repository-wide
  analysis still reports pre-existing informational lints outside this feature.
