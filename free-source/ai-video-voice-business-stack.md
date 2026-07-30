# Free AI Video + Voice Stack — Validated Edition

The corrected version of the original beginner blueprint. Every tool named here was verified on
30 July 2026; see [`SECURITY-AUDIT.md`](SECURITY-AUDIT.md) for the evidence and for what was
removed.

**Removed from the original list:** `NicholasCone/agnes-ai-video-suite` and
`wordghost1234/agnes-ai-storyboard-studio` (malware), `lcy362/vimax-agnes` (does not exist).

---

## 1. Video generation

### `naqashafzal/AI-Content-Studio` — end-to-end content pipeline

✅ Verified: 699★ / 167 forks, real Python, active.

Script → voiceover → video → upload, aimed at non-technical operators. The most complete pipeline
on the list and a reasonable starting point for faceless-channel or content-calendar work.

- **Needs:** Google Gemini API key (AI Studio). NewsAPI key optional. Uses Gemini TTS, so you are
  not pushed onto a paid voice vendor.
- **⚠️ License:** README claims MIT but **no LICENSE file exists**. Open an issue asking for it
  before commercial use.
- **⚠️ Not offline:** prompts and content are processed by Google.

### `lcy362/agnes-video-generator` — multi-scene video via API

✅ Verified: 197★ / 46 forks, MIT license present, real Python.

Text to multi-scene video with narration and subtitles, driven through a web UI. Install via
`start.sh`, Docker, or npm.

- **Needs:** free API key from `platform.agnes-ai.com`. Agnes AI (Sapiens AI, Singapore) is a real
  vendor.
- **⚠️ Cloud, not local.** You host the orchestration; generation runs on Agnes's servers. Every
  script and asset leaves your machine. Not for NDA work. Never sell output from this pipeline as
  "privacy-first."
- **⚠️** Free tiers get withdrawn. Do not price a fixed retainer on the assumption it won't.

---

## 2. Voice agents

### `saharmor/gemini-multimodal-playground` — real-time voice

✅ Verified: 322★ / 70 forks, **Apache-2.0**, active since December 2024.

The cleanest asset on the list, and the recommended entry point. Live voice conversation with
Gemini 2.0, suitable as a base for an AI receptionist or website voice assistant.

Apache-2.0 explicitly permits commercial use and includes a patent grant — the strongest license
position of anything here.

- **Watch:** Gemini free-tier quotas are a product decision, not a contract. Check current limits
  and data-use terms before routing client calls.

### LiveKit and Deepgram + Twilio patterns

The original document referenced these as categories rather than specific repos, so there was
nothing concrete to verify. Both organisations are established and publish their own official
examples.

**Go to the vendors' own GitHub organisations directly** — `livekit/`, `deepgram/`, `twilio/` — and
avoid third-party repos claiming to package them. That is precisely the gap the malicious repos in
this audit were exploiting.

Vet anything you find with `./scripts/vet-repo.sh` first.

---

## 3. Text-to-speech

### Local engines — the actual recommendation

**Piper** and **Coqui TTS** run on your own hardware. Genuinely free for commercial use, no
per-character cost, no volume ceiling, and audio never leaves your machine.

This is also the **only** option here that supports an honest "privacy-first" or "your data stays
in-house" pitch. If you want that positioning, the local TTS path is what makes it true.

### ElevenLabs — paid tier only

Quality is excellent. But:

> **The free tier grants no commercial usage rights and requires attribution.** Monetised video,
> client work, and advertising require at minimum the paid Starter plan.

The original document recommended the free tier for exactly these uses. Following it would put you
in breach from your first delivery. Either pay for Starter or use local TTS.

### Free voice-agent platforms

Retell AI, Voiceflow, Vocode and similar are fine for prototyping flows. Before any of them touches
a paying client, read what the free plan *permits*, not just what it costs — the ElevenLabs case
above is the general pattern, not an exception.

---

## 4. Business models

The strategy from the original document holds up. Only the tooling needed correcting.

### A. AI video agency (faceless content)

**Stack:** AI-Content-Studio or agnes-video-generator + local TTS (Piper/Coqui).

Weekly educational video for coaches and consultants, short-form for local business, explainers
for SaaS. Content demand is continuous and open-source tooling keeps platform margin out of your
costs.

**Honest pitch:** *"built on open-source tooling, so you're not paying platform margin."*
**Not:** *"your data never leaves the building"* — not true if you use the cloud video path.

### B. AI voice receptionist

**Stack:** `gemini-multimodal-playground` + Twilio.

Never-miss-a-call, after-hours coverage, lead qualification. Small businesses lose real revenue to
unanswered phones, and an AI receptionist costs a fraction of a hire. Apache-2.0 makes this the
most legally comfortable offering to build on.

### C. Content repurposing studio

**Stack:** AI-Content-Studio + local TTS.

Blog posts, newsletters and podcasts into video; one webinar into a month of short-form. Clients
already own the source material — you are selling transformation, which is an easier sale than
creation.

---

## 5. Getting started

1. **Pick one stack and one niche.** Voice-first is the easier start: `gemini-multimodal-playground`
   has the cleanest license and the fastest demo.
2. **Vet before you clone.** `./scripts/vet-repo.sh owner/repo` on anything new. Half the original
   list failed this.
3. **Reproduce the upstream demo unmodified.** Do not customise until it runs.
4. **Build 2–3 demo assets** for your chosen niche, on a simple landing page.
5. **Offer a pilot,** not a pitch. Three videos, or a one-week receptionist trial.

### Staying outside paywalls, honestly

- Prefer self-hosted and open-source — after verification.
- Prefer **MIT** and **Apache-2.0**. Confirm the license *file* exists; a README claim is not a grant.
- Local TTS keeps marginal cost at zero and makes privacy claims defensible.
- Monitor free-tier quotas, and assume any free tier can end.
- **"Free tier" describes price, not rights.** Read what each tier permits.

---

## 6. Security habits worth keeping

The two malware repos in the original list presented better than the genuine ones. What separated
them:

| Red flag | What it looked like |
|---|---|
| Stars but no forks | 155★ / 0 forks — nobody actually uses it |
| No source code | `README.md` + `index.html` + 2 SVGs, for a "video suite" |
| README names a different product | Repo `agnes-ai-video-suite`, README describes "EchoSync" |
| Download button, not `git clone` | Open source is distributed by cloning |
| Identical topic tags across repos | Same 13 tags on three "independent" projects |
| Security theater | "SLSA level 3", "ClamAV — 0 threats", "GitHub Verified" |
| Obfuscated `index.html` | base64 + XOR + `document.write` |

**Never run an installer or archive from a GitHub Pages "download" button.** Legitimate projects
are cloned, built from source, or installed from an official package registry.

---

*Validated 30 July 2026. Re-verify before relying on any entry — repos change, disappear, and
change hands.*
