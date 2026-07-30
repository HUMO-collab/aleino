# Free Source

A security-validated stack of free and open-source AI **video** and **voice** tools.

The rule of this repo: **nothing gets listed until it has been independently verified.** Every
asset below was checked against the live GitHub API, its source tree was inspected, and its
license was confirmed. What survived is here. What didn't is in
[`SECURITY-AUDIT.md`](SECURITY-AUDIT.md), named and explained.

---

## Why this repo exists

This started as a beginner-friendly "free AI video + voice business stack" document. When the six
GitHub repos it recommended were actually checked, the results were not what the document claimed:

- **2 of 6 were malware distribution pages** — no source code, an obfuscated redirect to a
  throwaway domain serving an auto-downloading `.zip`.
- **1 of 6 did not exist at all.**
- **3 of 6 were genuine**, though one has a materially different risk profile than advertised.

The original document also recommended a workflow that would have put a paying business in breach
of a vendor's license terms on day one.

That is a 50% failure rate on a list that reads as confident and well-cited. This repo is the
corrected version.

---

## Verdicts at a glance

| Asset | Verdict | Why |
|---|---|---|
| [`saharmor/gemini-multimodal-playground`](https://github.com/saharmor/gemini-multimodal-playground) | ✅ **Safe to use** | Real code, Apache-2.0, 322★/70 forks, active since Dec 2024 |
| [`naqashafzal/AI-Content-Studio`](https://github.com/naqashafzal/AI-Content-Studio) | ⚠️ **Safe, license gap** | Real Python, 699★/167 forks — but the `LICENSE` file it links to **does not exist** |
| [`lcy362/agnes-video-generator`](https://github.com/lcy362/agnes-video-generator) | ⚠️ **Works, but not "self-hosted"** | Real MIT code, but every prompt and asset goes to a third-party cloud API |
| `lcy362/vimax-agnes` | ❌ **Does not exist** | Zero results on the GitHub API. Fabricated. |
| `NicholasCone/agnes-ai-video-suite` | 🚨 **Malicious** | No code. Obfuscated redirect → `mcglynger.com` |
| `wordghost1234/agnes-ai-storyboard-studio` | 🚨 **Malicious** | No code. Obfuscated redirect → `unlocktool.click` |

**Do not clone, run, or visit the two malicious entries.** Full evidence, including the decoded
payload, is in [`SECURITY-AUDIT.md`](SECURITY-AUDIT.md).

---

## The validated stack

### Voice agents — `gemini-multimodal-playground`

The strongest asset on the original list, and the one to start with.

```bash
git clone https://github.com/saharmor/gemini-multimodal-playground
```

- **License:** Apache-2.0 — explicitly grants commercial use, includes a patent grant.
- **Signals:** 322 stars, 70 forks, real TypeScript, live since December 2024.
- **What it does:** real-time voice conversation with Gemini; a workable base for an AI
  receptionist or website voice assistant.
- **Watch:** Gemini's free tier is generous but not contractual — check current quotas and data-use
  terms before putting client calls through it.

### Content pipeline — `AI-Content-Studio`

```bash
git clone https://github.com/naqashafzal/AI-Content-Studio
```

- **Signals:** 699 stars, 167 forks, real Python, actively updated.
- **Requires:** a Google Gemini API key (via AI Studio); NewsAPI key optional. Uses Gemini TTS,
  so you are not forced onto a paid voice vendor.
- **⚠️ License gap:** the README says *"licensed under the MIT License – see LICENSE"*, but no
  `LICENSE`, `LICENSE.md`, or `LICENSE.txt` exists in the repository (all return 404). A README
  sentence is not a license grant. **Open an issue asking the maintainer to add the file before
  you use this commercially.** Until then your right to use the output for clients is unclear.

### Video generation — `agnes-video-generator`

```bash
git clone https://github.com/lcy362/agnes-video-generator
```

- **License:** MIT, file present and valid. ✅
- **Signals:** 197 stars, 46 forks, real Python (`server.py`, tests, Docker, `start.sh`).
- **The vendor is real:** Agnes AI is a Singapore-based platform (Sapiens AI) offering a free
  multimodal API tier. It is not a scam.
- **⚠️ Correct the mental model:** the original document sold this as *"self-hosted, no GPU
  needed."* Both halves are misleading together. You host the *orchestration*; the *generation*
  runs on Agnes's servers. **Every script, prompt, and client asset leaves your machine.** That is
  fine for your own content and disqualifying for anything under an NDA. Do not resell this as a
  "privacy-first" or "your data never leaves" service — that claim would be false.
- **Also:** a free tier is a business decision, not a guarantee. Price it as if it may end.

---

## Before you add anything to this stack

A vetting script is included. Run it on any repo before you trust it:

```bash
./scripts/vet-repo.sh owner/repo
```

It checks the signals that actually caught the malicious repos: code-to-marketing ratio,
obfuscated `index.html`, star-to-fork anomalies, repo age, and license presence.

The red flags worth memorising, in rough order of usefulness:

1. **Stars but no forks.** 155 stars and 0 forks is not a project people use. Real tools get forked.
2. **No source code.** A "video suite" whose entire tree is `README.md` + `index.html` + two SVGs
   is not a video suite.
3. **The README describes a differently-named product.** Both malicious repos described tools
   ("EchoSync", "AuraSynth") whose names matched neither the repo nor each other — the tell of a
   templated, machine-generated spam campaign.
4. **A "Download" button instead of a `git clone`.** Open source is distributed by cloning. A big
   download button pointing off-site is the single loudest signal here.
5. **Identical topic tags across unrelated repos.** All three Agnes-branded repos carried the same
   13 tags — one SEO campaign, not three independent projects.
6. **Security theater in the copy.** "SLSA level 3", "ClamAV — 0 threats", "AES-256",
   "GitHub Verified". Real projects rarely advertise this; fake ones lean on it hard.

---

## Licensing reality check for the business models

The original document recommended the **ElevenLabs free tier** for client narration and monetised
YouTube. Do not do this.

> The ElevenLabs free plan carries **no commercial usage rights** and requires attribution.
> Client work, monetised video, and advertising need at minimum the paid Starter tier.

Using free-tier output for a paying client is a license breach, and it is the client who inherits
the exposure. For genuinely free commercial narration, use a locally-run engine instead — Piper or
Coqui TTS — where you own the output outright and pay nothing per character. This also gives you a
defensible version of the "privacy-first voice" offering that the cloud video pipeline above
cannot honestly support.

**General rule:** "free tier" describes price, not rights. Read what the tier permits, not what it
costs. MIT and Apache-2.0 are safe for commercial use; a README claiming a license is not the
same as a license file.

---

## What is actually still true from the original plan

The strategy was sound; the sourcing was not. These hold up:

- Pick **one** stack and **one** niche instead of building broadly.
- Reproduce the upstream demo before customising anything.
- Build 2–3 demo assets before approaching anyone.
- Lead with a low-cost pilot rather than a pitch.
- Prefer self-hosted and open-source over subscription platforms — just verify each one first.

The honest version of the pitch is *"built on open-source tooling, so you are not paying platform
margin"* — not *"your data never leaves the building,"* unless you are running local TTS and a
local model end to end.

---

## Repository contents

| File | Purpose |
|---|---|
| `README.md` | This file — verdicts and the validated stack |
| `SECURITY-AUDIT.md` | Full evidence, methodology, and indicators of compromise |
| `ai-video-voice-business-stack.md` | The corrected business blueprint |
| `scripts/vet-repo.sh` | Vetting script for any new candidate repo |

---

*Audit date: 30 July 2026. Signals such as star counts and repo availability change — re-run
`scripts/vet-repo.sh` before relying on any entry.*
