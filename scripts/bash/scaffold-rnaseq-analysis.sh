#!/usr/bin/env bash

set -e

PROJECT="rnaseq-analysis"

echo "Creating $PROJECT structure..."

mkdir -p $PROJECT/assets/css
mkdir -p $PROJECT/R
mkdir -p $PROJECT/data

cd $PROJECT

########################################
# _quarto.yml
########################################

cat > _quarto.yml << 'EOF'
project:
  type: book
  output-dir: docs

book:
  title: "RNA-seq Analysis"
  chapters:
    - index.qmd
    - 01-preface-and-setup.qmd
    - 02-study-design-and-metadata.qmd
    - 03-data-intake-and-qc.qmd
    - 04-quantification-and-count-matrix.qmd
    - 05-normalization-and-eda.qmd
    - 06-from-results-to-biological-claims.qmd

format:
  html:
    toc: true
    number-sections: false
    css: assets/css/cdi.css
EOF

########################################
# index.qmd
########################################

cat > index.qmd << 'EOF'
:::cdi-message
ID: RNASEQ-INDEX
Type: Gateway
Audience: Public
Theme: RNA-seq workflow and interpretation
:::

RNA-seq analysis is straightforward to execute.

Interpreting results in a defensible way is harder.

This guide walks through the reasoning chain that connects:
study design, data quality, normalization, modeling concepts, and calibrated biological claims.

:::next
Start → [Lesson 1: Preface and Setup](01-preface-and-setup.qmd)
:::
EOF

########################################
# Lesson template function
########################################

create_lesson() {
  FILE=$1
  ID=$2
  TITLE=$3

  cat > $FILE << EOF
:::cdi-message
ID: $ID
Type: Lesson
Audience: Public
Theme: RNA-seq interpretation
:::

# $TITLE

Content coming soon.

EOF
}

create_lesson "01-preface-and-setup.qmd" "RNASEQ-L01" "Lesson 1: Preface and Setup"
create_lesson "02-study-design-and-metadata.qmd" "RNASEQ-L02" "Lesson 2: Study Design and Metadata"
create_lesson "03-data-intake-and-qc.qmd" "RNASEQ-L03" "Lesson 3: Data Intake and QC"
create_lesson "04-quantification-and-count-matrix.qmd" "RNASEQ-L04" "Lesson 4: Quantification and Count Matrix Concepts"
create_lesson "05-normalization-and-eda.qmd" "RNASEQ-L05" "Lesson 5: Normalization and Exploratory Data Analysis"
create_lesson "06-from-results-to-biological-claims.qmd" "RNASEQ-L06" "Lesson 6: From Results to Biological Claims"

########################################
# Minimal CDI CSS
########################################

cat > assets/css/cdi.css << 'EOF'
body {
  font-family: system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
}

h1, h2, h3 {
  font-weight: 600;
}

.plot-title-centered {
  text-align: center;
}
EOF

########################################
# R helper: theme
########################################

cat > R/cdi-rnaseq-theme.R << 'EOF'
cdi_rnaseq_theme <- function(base_size = 12){
  ggplot2::theme_minimal(base_size = base_size) +
    ggplot2::theme(
      plot.title.position = "plot",
      plot.title = ggplot2::element_text(hjust = 0.5, face = "bold"),
      plot.subtitle = ggplot2::element_text(hjust = 0.5),
      panel.grid.minor = ggplot2::element_blank()
    )
}
EOF

########################################
# R helper: synthetic dataset
########################################

cat > R/cdi-rnaseq-simulate-data.R << 'EOF'
simulate_rnaseq_counts <- function(
  n_genes = 500,
  n_samples = 12,
  condition = rep(c("Control", "Treatment"), each = n_samples/2),
  seed = 123
){
  set.seed(seed)

  stopifnot(length(condition) == n_samples)

  lib_size <- round(stats::rlnorm(n_samples, meanlog = 15, sdlog = 0.3))
  size_factor <- lib_size / stats::median(lib_size)

  base_mu <- stats::rgamma(n_genes, shape = 2, rate = 0.1)
  dispersion <- stats::rgamma(n_genes, shape = 2, rate = 10)

  de_idx <- sample(seq_len(n_genes), size = round(0.1 * n_genes))
  lfc <- rep(0, n_genes)
  lfc[de_idx] <- stats::rnorm(length(de_idx), mean = 1, sd = 0.3)

  is_treatment <- condition == "Treatment"

  mu <- outer(base_mu, size_factor)
  mu[, is_treatment] <- mu[, is_treatment] * exp(lfc)

  counts <- matrix(0, nrow = n_genes, ncol = n_samples)

  for (g in seq_len(n_genes)){
    size <- 1 / dispersion[g]
    counts[g, ] <- stats::rnbinom(n_samples, size = size, mu = mu[g, ])
  }

  gene_id <- paste0("gene-", sprintf("%04d", seq_len(n_genes)))
  sample_id <- paste0("sample-", sprintf("%02d", seq_len(n_samples)))

  colnames(counts) <- sample_id
  rownames(counts) <- gene_id

  meta <- data.frame(
    sample_id = sample_id,
    condition = condition,
    library_size = lib_size,
    stringsAsFactors = FALSE
  )

  list(counts = counts, meta = meta, de_genes = gene_id[de_idx])
}
EOF

########################################
# data README
########################################

cat > data/README.md << 'EOF'
This folder stores small datasets used in the free RNA-seq guide.

Primary dataset is generated programmatically via:
R/cdi-rnaseq-simulate-data.R
EOF

echo "Scaffold created successfully."
echo "Next steps:"
echo "cd $PROJECT"
echo "quarto render"

