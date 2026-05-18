#!/usr/bin/env tape

@V := "tape" :: spec [active]
  version = "1.2"

@I id001 := "setup" :: identity-claim [d=2026-05-14 active]
  kind = "Lumière — one-time setup for TestFlight delivery"
  brief = "This guide covers the manual steps required before `.github/workflows/release.yml` can ship a build to TestFlight. None of these can be automated by Claude / fastlane — they require human action in Ap"
  parent = "dancinlab/lumiere"
  sibling-md = "SETUP.md"

# ─── §Log (append @A / @D events here, chronological) ────────────────
# 
# Pre-existing log entries live in SETUP.md.
# New per-domain history entries land here as typed events:
#
#   @A commit_<hash> :: <domain> [d=<YYYY-MM-DD> ok]
#     <- <prev-id>
#     => "<one-line description>"
#
#   @D <id> := "<decision-name>" :: <domain> [<grades>]
#     <- <evidence-id>
#     |> <verifier>
#
# See ~/core/tape/spec/tape.md for full grammar.
