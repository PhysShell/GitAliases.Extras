# git-aliases-extra

Custom PowerShell git aliases and tab completion helpers on top of `posh-git` and `git-aliases` with full tab completion support for aliased commands.

Mainly inspired by: https://github.com/zh30/zsh-shortcut-git

## Breaking Changes (2026-02-19)

- Renamed module: `GitAliases.Extras` -> `git-aliases-extra`
- Renamed manifest/script files:
  - `GitAliases.Extras.psd1` -> `git-aliases-extra.psd1`
  - `GitAliases.Extras.psm1` -> `git-aliases-extra.psm1`
- Renamed repository URL:
  - `https://github.com/PhysShell/GitAliases.Extras` -> `https://github.com/PhysShell/git-aliases-extra`

Migration steps:

```powershell
Remove-Module GitAliases.Extras -ErrorAction SilentlyContinue
Import-Module git-aliases-extra
```

## Module installation

Install from PowerShell Gallery:

```powershell
Install-Module git-aliases-extra -Scope CurrentUser
Import-Module git-aliases-extra
```

Install from source:

```powershell
git clone https://github.com/PhysShell/git-aliases-extra.git "$HOME\Documents\PowerShell\Modules\git-aliases-extra"
Import-Module git-aliases-extra
```

Install dependencies:

```powershell
Install-Module posh-git -Scope CurrentUser -Force
Install-Module git-aliases -Scope CurrentUser -Force
Install-Module git-aliases-extra -Scope CurrentUser -Force
```

## Alias discovery

Use `Get-Git-Aliases` to inspect available aliases and their definitions.

List all aliases:

```powershell
Get-Git-Aliases
```

Show one alias:

```powershell
Get-Git-Aliases grsh
```

List only aliases from `git-aliases`:

```powershell
Get-Git-Aliases -Base
```

List only aliases from `git-aliases-extra`:

```powershell
Get-Git-Aliases -Extras
```

`Get-Git-Aliases` includes aliases from both:
- `git-aliases`
- `git-aliases-extra`

Default output order:
- `extras` group first
- `base` group second
- alphabetical order inside each group

## Quality checks

Run both lint and tests:

```powershell
.\tools\ci.ps1
```

Run only lint:

```powershell
.\tools\ci.ps1 -LintOnly
```

Run only tests:

```powershell
.\tools\ci.ps1 -TestOnly
```

## Commit hooks

Install local git hooks:

```powershell
.\tools\install-hooks.ps1
```

Installed hooks:
- `pre-commit` (lightweight no-op)
- `commit-msg` (runs `tools/ci.ps1`)

Checks are skipped when:
- commit message contains `[skip precommit hook]` or `[skip pch]`
- there are no working tree changes (for example, `git commit --allow-empty ...`)

## Publishing

This repository includes:

- `.github/workflows/ci.yml` for lint + tests
- `.github/workflows/publish.yml` for PSGallery publishing

To publish from CI:

1. Add repository secret `PSGALLERY_API_KEY`.
2. Bump `ModuleVersion` in `git-aliases-extra.psd1`.
3. Push a tag `v<ModuleVersion>` (for example, `v0.1.0`) or run the publish workflow manually.

## What CI checks

- `PSScriptAnalyzer` linting with `PSScriptAnalyzerSettings.psd1`
- `Pester` tests in `tests\` (module + integration)
- GitHub Actions matrix on:
  - Windows PowerShell
  - PowerShell 7

## License

WTFPL. See `LICENSE`.
