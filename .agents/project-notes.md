# Project Notes

- Repository: recipe site for "Koken met Bert".
- Current site setup uses MkDocs with `mkdocs.yml` at the repository root.
- Source Markdown lives under `docs/`; generated output goes to `site/` and is ignored by git.
- GitHub Pages workflow is `.github/workflows/pages.yml`.
- Pages is intended to deploy through GitHub Actions on pushes to `main`; GitHub repository Pages settings may still need `Source: GitHub Actions`.
- No separate publishing repository or `gh-pages` branch is needed.
- Local build commands:
  - `.\.venv\Scripts\python -m mkdocs build`
  - `.\.venv\Scripts\python -m mkdocs serve`
- Theme is standard MkDocs with green overrides in `docs/assets/stylesheets/site.css`.
- User explicitly asked not to touch bread recipe Markdown unless requested: "brood is ok, niet aankomen".
- PDF export scripts for bread should keep "printbare versie" links out of generated PDFs.
- Recipe images should live under `docs/assets/images/`.
