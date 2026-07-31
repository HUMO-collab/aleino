# Publishing this as its own repository

This folder is a complete, self-contained repository. It lives inside `aleino` only because the
GitHub App token available to this session cannot create repositories:

```
POST https://api.github.com/user/repos → 403 Resource not accessible by integration
```

That is a permissions limit on the automation, not on your account. Creating the repo yourself
takes about a minute.

**Publish this repository as public.** The audit contains no client names, no credentials, and
no internal system detail — it is generic security research, and it is the public evidence behind
the "we audit every component before it touches your stack" claim in client proposals. A private
copy proves nothing to anyone.

The completed sweep of live client stacks is a *different* document and stays private in
`templates/deliverables/` — it names clients and the location of a live credential. Do not move
it here.

## Option A — with the `gh` CLI

```bash
cd free-source
git init && git add . && git commit -m "Free Source: security-validated AI video + voice stack"
gh repo create free-source --public --source=. --remote=origin --push
```

## Option B — via the web UI

1. Create a new empty repository at <https://github.com/new>, named `free-source`,
   visibility **Public**.
   Do **not** initialise it with a README, license, or `.gitignore`.
2. Then:

```bash
cd free-source
git init && git add . && git commit -m "Free Source: security-validated AI video + voice stack"
git branch -M main
git remote add origin git@github.com:HUMO-collab/free-source.git
git push -u origin main
```

## Afterwards

Remove the copy from `aleino` so there is one source of truth:

```bash
git rm -r free-source && git commit -m "Move free-source into its own repository"
```

## Repository name

Published as `free-source` — GitHub does not permit spaces in repository names, so "Free Source"
becomes `free-source`. The display title in `README.md` reads "Free Source". If you want a
different slug, change it in the commands above.
