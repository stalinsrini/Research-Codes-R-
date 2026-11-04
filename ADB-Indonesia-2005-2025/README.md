# ADB Indonesia sovereign lending document collection (2005–2025)

Research code for locating and downloading Asian Development Bank (ADB) Reports and Recommendations of the President (RRP) and Project/Program Completion Reports (PCR) associated with a 96-project Indonesia sovereign loan inventory.

## Scope
- Country: Indonesia
- Period: 2005–2025 (verify approval-date inclusion separately)
- Sovereign loans only; exclude grants as financing observations
- Documents: RRP and PCR, where published

## Notebooks
1. `01_initial_document_downloader.ipynb`: initial discovery, review and download workflow.
2. `02_independent_discovery.ipynb`: experimental independent project-page discovery. ADB search endpoints produced redirect errors; do not interpret failed queries as absent documents.
3. `03_targeted_recovery.ipynb`: experimental direct-PDF pattern recovery and audit.
4. `04_legacy_pattern_recovery.ipynb`: additional historical filename-pattern tests; partial coverage only.

## Reproducibility and limitations
A successful HTTP response alone does not establish that a PDF belongs to the intended project or is the intended document type. Verify PDF title page, project number, report type, and financing modality. Some PCRs cover several program subprojects; recently approved loans may not have PCRs. The source inventory also includes some projects approved before 2005, so sample eligibility requires explicit validation.

The experimental notebooks do not guarantee complete coverage and must not be used to infer that unlocated documents are unpublished.

## Data policy
Downloaded PDFs, ZIP archives, temporary audit outputs and credentials are excluded from this code repository. Keep original source documents and research audits in separately managed storage.
