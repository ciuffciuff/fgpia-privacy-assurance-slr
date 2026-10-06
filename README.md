# Privacy assurance in the machine learning lifecycle: a risk-based extension of CRISP-ML(Q)

Data package of the systematic literature review (SLR) that grounds **FGP-IA**, a risk-based privacy assurance framework structured as an extension of CRISP-ML(Q).

Authors: César A. C. Moreira, Ícaro Marcelino, Willyan Silva, Simone Borges Simão Monteiro, Viviane Vasconcellos Ferreira Grubisic.
Graduate Program in Applied Computing (PPCA), University of Brasília — course *Garantia da Qualidade de Processos Cibernéticos* (GQPC), 2026.2.

## Review at a glance

| Stage | Result |
|---|---|
| Databases | Scopus, Web of Science, IEEE Xplore (search run on 27 Sep 2026; confirmed as definitive on 6 Oct 2026) |
| Records identified / after deduplication | 14,362 / 9,398 |
| Title/abstract screening | 29 retained, 9,369 excluded; Cohen's kappa = 0.935 |
| Full text, database records | 29 sought, 4 not retrieved (EC4, access denied), 25 included |
| Bidirectional snowballing (OpenAlex) | 1,022 unique candidates, 17 screened by abstract, 9 sought, 4 not retrieved (EC4), 5 assessed, 4 included |
| **Studies included** | **29** (25 + 4) |
| Privacy activities extracted | 270, of which 72 (27%) with an explicit verification criterion |

Guidelines: Kitchenham & Charters (2007); reporting: PRISMA 2020. The protocol was not publicly registered (PRISMA 2020 item 24a).

## Repository structure

| Folder | Content |
|---|---|
| `protocol/` | Research questions, PICOC and search strategy (`protocol.md`), eligibility criteria, quality criteria, extraction form (Portuguese) |
| `search/` | PRISMA 2020 flow counts and calibration control set (8 of 8 retrieved) |
| `screening/` | Reviewer agreement table, exclusions by criterion, title-based pre-classification of the two highest signal bands |
| `snowballing/` | Round summary, abstract screening of the 17 candidates, full-text decisions on the 9 sought |
| `extraction/` | Extraction of the 29 studies (`studies.csv`, `activities.csv`, `reported_gaps.csv`, `quality_appraisal.csv`, consolidated `.xlsx`), overview table and BibTeX of included studies |
| `synthesis/` | Coverage matrix by CRISP-ML(Q) phase, gap taxonomy (G1–G5), contribution of each study to FGP-IA |
| `framework/` | FGP-IA v1: 14 activities with acceptance criteria and artifacts; traceability to LGPD, ISO/IEC 27701:2019, NIST AI RMF, gaps and studies |
| `scripts/` | `snowballing_openalex.R` (backward/forward citation chasing) and `kappa.R` (agreement calculation) |

## Codes used

- **Phases** (CRISP-ML(Q)): F1 business and data understanding · F2 data engineering · F3 ML model engineering · F4 model evaluation · F5 deployment · F6 monitoring and maintenance · TRANSV cross-cutting.
- **Criteria**: IC1–IC5 (inclusion), EC1–EC5 (exclusion); see `protocol/eligibility_criteria.csv`.
- **Quality**: QA1–QA5 scored 1 / 0.5 / 0; see `protocol/quality_criteria.csv`.
- **Gaps**: G1–G5; see `synthesis/gap_taxonomy.csv`.
- **Study IDs**: S01–S25 from database searches; S26–S29 from snowballing.

Free-text fields of the extraction (`extraction/*.csv`) are in Portuguese, the working language of the review team; codes, headers and synthesis tables are in English.

## Reproducing the numbers

```r
# Agreement at title/abstract screening
source("scripts/kappa.R")

# Share of activities with a verification criterion per phase
act <- read.csv("extraction/activities.csv")
mean(act$has_criterion)   # 0.267 (72 of 270)
```

`synthesis/coverage_matrix.csv` is computed directly from `extraction/activities.csv` (an activity can belong to more than one phase).

## Use of generative AI

See `AI_USE.md`.

## How to cite

See `CITATION.cff`. Data and tables: CC BY 4.0. Scripts: MIT License.
