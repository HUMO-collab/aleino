# Security Audit — AI Video + Voice Stack

**Date:** 30 July 2026
**Scope:** The six GitHub repositories and the TTS/voice vendors recommended in the source
"Free AI Video + Voice Stack For Beginners" document.
**Method:** GitHub API existence and metadata checks, source-tree inspection, static decoding of
obfuscated content, license file verification, vendor legitimacy research.
**Result:** 2 malicious, 1 nonexistent, 3 genuine (2 with material caveats).

No payload was downloaded and no obfuscated code was executed at any point. All analysis of the
malicious pages was performed statically.

---

## Summary

| # | Asset | Exists | Code | License | Verdict |
|---|---|---|---|---|---|
| 1 | `saharmor/gemini-multimodal-playground` | Yes | Yes | Apache-2.0 ✅ | Safe |
| 2 | `naqashafzal/AI-Content-Studio` | Yes | Yes | **Missing** ⚠️ | Safe, license gap |
| 3 | `lcy362/agnes-video-generator` | Yes | Yes | MIT ✅ | Works; cloud, not local |
| 4 | `lcy362/vimax-agnes` | **No** | — | — | Fabricated |
| 5 | `NicholasCone/agnes-ai-video-suite` | Yes | **No** | Claimed only | 🚨 Malicious |
| 6 | `wordghost1234/agnes-ai-storyboard-studio` | Yes | **No** | Claimed only | 🚨 Malicious |

---

## Finding 1 — Two repositories are malware distribution pages

**Severity: Critical.** These are the two the source document ranked most highly, describing one as
a *"polished open-source suite"* and *"top open-source generator for 2026."*

### Metadata anomalies

| | `agnes-ai-video-suite` | `agnes-ai-storyboard-studio` |
|---|---|---|
| Owner | NicholasCone | wordghost1234 |
| Created | 2026-06-28 13:04 UTC | 2026-06-28 19:19 UTC |
| Language | HTML | HTML |
| Stars | 155 | 154 |
| Forks | **0** | **1** |
| Topics | 13 tags | **the same 13 tags** |

Two "independent" projects created six hours apart, with near-identical star counts, effectively no
forks, and byte-identical topic lists. A video generation suite written in HTML with zero forks is
not a real project. This is one campaign wearing two names.

### The source tree contains no software

The complete file listing for both repositories:

```
.github/
README.md
button.svg
index.html
preview.svg
```

No Python, no JavaScript modules, no `requirements.txt`, no Dockerfile, no tests. The READMEs
describe elaborate multimodal pipelines, GPU requirements, and Docker deployment. None of it exists.

### The READMEs describe differently-named products

`agnes-ai-video-suite`'s README does not describe a product called "Agnes AI Video Suite." It
describes **"EchoSync: Multimodal AI Storyboard & Video Prototyper."** `agnes-ai-storyboard-studio`'s
README describes **"AuraSynth."**

The prose is fluent, plausible, and machine-generated — the repo name is an SEO surface targeting
searches for a real product ("Agnes AI"), while the README is filler. Note the direct contradiction
inside the same README: *"No API keys, no cloud registration, no hidden fees"* and *"Everything runs
locally. No data leaves your machine"* — alongside a **Download** button rather than a clone command.

### `index.html` is obfuscated

Both `index.html` files (~25 KB) contain no markup — only a self-executing obfuscation wrapper:

```javascript
(function(){var k=atob('b7GB0DmH988Y/gb6BGmabmLG+Dfp5bmd+F5zCDSFqDE='),
             d=atob('U5DFn3rTrp9d3m6OaQWkZF6ujFqFxdX8...');
/* XOR d against repeating key k, then document.write() the result */
```

A base64-encoded key XOR'd against a base64-encoded payload, written straight into the document.
There is no legitimate reason for a project landing page to hide its own HTML. The purpose is to
defeat casual inspection and automated scanning.

### Decoded payload

Decoding statically (base64 → repeating-key XOR, no execution) yields a **counterfeit GitHub
interface** for a fictional organisation called "e-core", which auto-downloads
`ecore-project.zip`:

> `NicholasCone • archive / ecore-project.zip • Secure Download`
> `⚡ GitHub Actions • secure pipeline  ✓ TLS 1.3 | SBOM verified  🔒 signed by: ecore/security`
> `📦 114.8 MB (compressed)  🛡️ ClamAV + 5 engines (0 threats)`
> `🔐 End-to-end encryption (AES-256)  📜 SLSA level 3`
> `✓ GitHub Verified • Provenance`
> `⚙️ INITIALIZING PACKAGING ~12s left`
> `✨ Your archive will start automatically after final validation.`

Every trust signal is fabricated. Observations:

- **The star counts in the payload contradict the real repository.** The fake page claims 422 stars
  and 80 forks; the actual repo has 155 stars and 0 forks. The other claims 858/19 against a real
  154/1. The attacker inflated the numbers for the victim who has already stopped checking.
- **A fake antivirus verdict** ("ClamAV + 5 engines, 0 threats") is placed exactly where a
  hesitating user would look for reassurance.
- **The fake progress bar and "~12s left"** exist to make the automatic download feel like the
  natural end of a legitimate build process.
- **`.zip` at ~115–145 MB** is characteristic of info-stealer bundles padded past the size limit of
  common online scanning services.

This is the standard fake-software delivery chain: SEO-optimised GitHub repo → obfuscated
GitHub Pages lure → archive hosted on a throwaway domain.

### Indicators of compromise

Block these. Do not visit them.

```
mcglynger.com                                    — payload host (via agnes-ai-video-suite)
unlocktool.click                                 — payload host (via agnes-ai-storyboard-studio)
nicholascone.github.io/agnes-ai-video-suite/     — lure page
wordghost1234.github.io/agnes-ai-storyboard-studio/ — lure page
github.com/NicholasCone/agnes-ai-video-suite     — lure repo
github.com/wordghost1234/agnes-ai-storyboard-studio — lure repo
ecore-project.zip                                — payload filename
"e-core" / "ecore/security"                      — fictitious signing identity
```

**If either archive was already downloaded or run:** treat the machine as compromised. Assume
browser-stored passwords, session cookies, crypto wallets, and API keys were exfiltrated. Rotate
credentials from a *different* device, revoke active sessions, and rebuild rather than clean.

Both repositories should be reported to GitHub via **Report abuse → Malware or exploits**.

---

## Finding 2 — One repository does not exist

**Severity: Informational, but diagnostic.**

`lcy362/vimax-agnes` returns `total_count: 0` from the GitHub search API. It was presented in the
source document with specific technical detail — *"self-hosted generators using Agnes v2.0 and
image 2.1 flash APIs"*, *"agentic pipeline: idea → story → character references → scenes → final
video."*

Confidently described features for a repository that has never existed is the signature of
generated text. The `[2]` and `[5]` citation markers throughout the source document create an
appearance of sourcing that the content does not support. **Treat the entire original document as
unverified**, including any part of it not covered by this audit.

---

## Finding 3 — `AI-Content-Studio` has no license file

**Severity: Medium — legal, not technical.**

The repository is genuine: 699 stars, 167 forks, real Python, active development, created
September 2025. Its README states:

> `## 📄 License`
> `This project is licensed under the **MIT License** – see [LICENSE](LICENSE).`

That link is broken. Verified:

```
main/LICENSE     → 404
main/LICENSE.md  → 404
main/LICENSE.txt → 404
```

Under default copyright, code published without a license grant reserves all rights to the author —
regardless of what the README says. In practice a stated intent to license under MIT is strong
evidence of intent and the risk is low, but it is not the same as a grant, and it is not something
to build client billing on top of.

**Action:** open an issue requesting the `LICENSE` file be added. It is a one-line fix for the
maintainer and it resolves the ambiguity permanently.

**Also note:** it requires a Google Gemini API key and uses Gemini TTS. Content and prompts are
processed by Google. It is not an offline pipeline.

---

## Finding 4 — `agnes-video-generator` is cloud-dependent, not self-hosted

**Severity: Medium — accuracy and client-commitment risk.**

The repository is legitimate. MIT license present and valid, 197 stars, 46 forks, real Python
(`server.py`, `requirements.txt`, `pytest.ini`, `start.sh`), Docker and npm install paths.

The vendor is also legitimate. Agnes AI is a Singapore-based platform by Sapiens AI offering an
OpenAI-compatible multimodal API with a free tier. Independent reviews report variable output
quality but no indication of fraud.

The problem is the framing in the source document, which described this as **"self-hosted"** and
**"no GPU needed on your side"** in the same breath. Both statements are individually true and
jointly misleading. The repo's own README is candid about it:

> *"All AI compute runs in the cloud — a regular laptop is all you need."*
> Requires a free API key from `platform.agnes-ai.com`.

You self-host the orchestration layer. Generation happens on Agnes's infrastructure, which means
**every prompt, script, and client asset is transmitted to a third party.**

**Consequences to plan for:**

- Unsuitable for work under NDA or confidentiality terms without disclosure and client consent.
- The source document's suggested *"privacy-first voice services"* positioning cannot be honestly
  applied to any deliverable produced through this pipeline.
- A free tier is a commercial decision that can be withdrawn, rate-limited, or repriced. Do not
  sign a fixed-price retainer whose margin depends on it staying free.
- Review Agnes AI's data-retention and training-use terms before sending client material.

---

## Finding 5 — ElevenLabs free tier prohibits the recommended use

**Severity: Medium — license compliance.**

The source document recommended the ElevenLabs free tier for *"narration for videos (YouTube,
explainers, ads)"* and client-facing voice agents.

The free plan grants **no commercial usage rights** and requires ElevenLabs attribution.
Commercial use — monetised YouTube, client work, advertising, app integration — requires at
minimum the paid Starter tier. Attribution does not unlock commercial rights on the free plan.

Following the original recommendation would place a business in breach from its first delivery,
with the client inheriting the exposure.

**Alternative:** run TTS locally with **Piper** or **Coqui TTS**. Both are genuinely free for
commercial use, have no per-character cost, and keep audio on your own hardware — which also makes
the "privacy-first" positioning defensible in a way the cloud pipeline cannot be.

---

## Verification commands

Reproduce any of the above:

```bash
# Existence and metadata
curl -s "https://api.github.com/search/repositories?q=repo:OWNER/NAME"

# License presence — do not trust the README
curl -sI "https://raw.githubusercontent.com/OWNER/NAME/main/LICENSE"

# Obfuscation check
curl -s "https://raw.githubusercontent.com/OWNER/NAME/main/index.html" | grep -c "atob("
```

Or use the bundled script, which wraps all of these:

```bash
./scripts/vet-repo.sh owner/repo
```

---

## Conclusion

Half the recommended repositories were unusable and two were actively dangerous. The failure mode
worth internalising is that **the malicious repos looked better than the real ones** — cleaner
READMEs, more confident claims, professional presentation, healthy-looking star counts. Presentation
quality is not a security signal. Star count alone is not either; stars are cheap to buy, while
forks and real commit history are not.

The strategy in the original document is workable. Its sourcing was not, and no part of it should be
trusted without independent verification.
