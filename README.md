# RNA-seq Analysis

This repository contains a structured Quarto-based RNA-seq guide focused on building interpretive clarity before advanced modeling workflows.

The guide emphasizes reasoning, statistical structure, and responsible biological interpretation.

---

## What This Guide Covers

- Study design and metadata integrity  
- Count matrix structure and validation  
- Mean–variance behavior of RNA-seq data  
- Normalization logic for exploratory analysis  
- PCA and clustering for global structure assessment  
- Separation of statistical output from biological claims  

The emphasis is on understanding *why* each step exists and how decisions propagate through the workflow.

---

## What This Guide Does Not Cover

This repository does not include full production differential expression pipelines.

Advanced count-based modeling workflows, dispersion estimation, shrinkage, enrichment analysis, and reporting pipelines are addressed separately.

---

## Structure

The guide is organized as a Quarto book:

1. Preface and Setup  
2. Study Design and Metadata  
3. Data Intake and Quality Control  
4. Quantification and Count Matrix Concepts  
5. Normalization and Exploratory Analysis  
6. From Results to Biological Claims  

---

## Reproducibility

This repository includes:

- A small synthetic demo dataset  
- Scripts for dataset generation  
- Version-controlled Quarto source files  
- A rendered `docs/` directory for GitHub Pages deployment  

To regenerate the demo dataset from the project root:

```bash
Rscript scripts/R/generate-demo-data.R
```

To render the book locally:

```bash
quarto render
```

---

## Deployment

The site is deployed via GitHub Pages using a GitHub Actions workflow.

Rendered output lives in the `docs/` directory and is automatically published to:

https://rnaseq.complexdatainsights.com

---

## Philosophy

RNA-seq analysis is not a sequence of commands.

It is a reasoning chain:

Design → Structure → Modeling → Effect Size → Context → Claim

This guide focuses on building that reasoning discipline before introducing advanced modeling workflows.
