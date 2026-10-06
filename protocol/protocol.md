# Review protocol

## Objective

Map how privacy and data protection are addressed in process models and development lifecycles of AI/ML solutions, build a coverage matrix relating lifecycle phases to privacy activities, derive a gap taxonomy traceable to primary studies, and ground a risk-based privacy assurance extension of CRISP-ML(Q) (FGP-IA).

## Research questions

- **RQ1 (process):** How do AI/ML process models and lifecycles address privacy and data protection?
- **RQ2 (coverage):** Which privacy activities are prescribed, with verification criteria and artifacts, and in which lifecycle phases?
- **RQ3 (gaps):** Which gaps does the literature report between regulatory privacy requirements and engineering tasks?
- **RQ4 (mechanisms):** Which tasks, acceptance criteria and artifacts can anchor a risk-based extension of CRISP-ML(Q)?

## PICOC

| Element | Terms |
|---|---|
| Population | machine learning, artificial intelligence, data science, data mining, deep learning |
| Intervention | privacy, data protection, privacy by design, personal data, privacy engineering, privacy assurance, PET(s), differential privacy, anonymization, pseudonymization, membership inference, threat model |
| Comparison | not applicable (mapping review) |
| Outcome | privacy activities, verification criteria, acceptance criteria, privacy artifacts, coverage, gaps, traceability |
| Context | process model, reference model, lifecycle, life cycle, methodology, development process, software process, CRISP-DM, CRISP-ML, MLOps, SEMMA |

## Search strings (v1.1)

**Scopus**
```
TITLE-ABS-KEY ( ( privac* OR "data protection" OR "personal data" OR anonymi* OR pseudonymi* OR LINDDUN OR DPIA
  OR "data protection impact assessment" OR "membership inference" )
AND ( "process model*" OR "reference model*" OR lifecycle OR "life cycle" OR methodolog* OR "development process"
  OR "software process" OR CRISP* OR MLOps OR SEMMA )
AND ( "machine learning" OR "artificial intelligence" OR "data science" OR "data mining" OR "deep learning" ) )
AND PUBYEAR > 2015
AND ( LIMIT-TO ( LANGUAGE , "English" ) OR LIMIT-TO ( LANGUAGE , "Portuguese" ) )
AND ( LIMIT-TO ( DOCTYPE , "ar" ) OR LIMIT-TO ( DOCTYPE , "cp" ) OR LIMIT-TO ( DOCTYPE , "re" ) )
```

**Web of Science**
```
TS = ( ( privac* OR "data protection" OR "personal data" OR anonymi* OR pseudonymi* OR LINDDUN OR DPIA
  OR "data protection impact assessment" OR "membership inference" )
AND ( "process model*" OR "reference model*" OR lifecycle OR "life cycle" OR methodolog* OR "development process"
  OR "software process" OR CRISP* OR MLOps OR SEMMA )
AND ( "machine learning" OR "artificial intelligence" OR "data science" OR "data mining" OR "deep learning" ) )
```

**IEEE Xplore**
```
("All Metadata":privacy OR "All Metadata":"data protection" OR "All Metadata":"personal data"
 OR "All Metadata":anonymization OR "All Metadata":pseudonymization OR "All Metadata":LINDDUN
 OR "All Metadata":"data protection impact assessment" OR "All Metadata":"membership inference")
AND ("All Metadata":"process model" OR "All Metadata":"life cycle" OR "All Metadata":lifecycle
 OR "All Metadata":methodology OR "All Metadata":"development process" OR "All Metadata":CRISP OR "All Metadata":MLOps)
AND ("All Metadata":"machine learning" OR "All Metadata":"artificial intelligence"
 OR "All Metadata":"data science" OR "All Metadata":"data mining")
```
The remaining v1.1 requirements (publication from 2016, language and document type) were applied through the database's own search filters. The ACM Digital Library, used in an initial run, was excluded on 30 Sep 2026 and its records removed before screening.

## Selection

- Records managed in Evidentia Review; deduplication by title, authors, year and DOI or source identifier (Scopus EID, WoS UT).
- Double, independent and blind title/abstract screening (C.C. and I.M.); third reviewer W.S.; acceptance threshold kappa >= 0.60 (pilot of 20 records otherwise). Obtained: kappa = 0.935.
- Full text assessed against IC1–IC5 and EC1–EC5; reports whose full text could not be accessed are excluded under EC4.
- Bidirectional snowballing (Wohlin, 2014) through OpenAlex, seeded with the 29 studies retained at title/abstract.

## Extraction and quality

Standardized form (`extraction_form_pt.md`). First extraction pass by C.C. supported by AI, verified by I.M., divergences arbitrated by W.S. Quality appraisal with QA1–QA5 (`quality_criteria.csv`); scores weight the synthesis and are not used for exclusion.
