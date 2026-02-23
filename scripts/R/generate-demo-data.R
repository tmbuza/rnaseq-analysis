#!/usr/bin/env Rscript

# ------------------------------------------------------------
# RNA-seq Demo Data Generator
# Balanced 6 vs 6 design
# ------------------------------------------------------------

# Resolve script location so paths work from any working directory
args <- commandArgs(trailingOnly = FALSE)
file_arg <- grep("^--file=", args, value = TRUE)

if (length(file_arg) == 0) {
  stop("Cannot determine script path. Run with: Rscript scripts/R/generate-demo-data.R")
}

script_path <- sub("^--file=", "", file_arg)
script_dir  <- dirname(normalizePath(script_path))
project_dir <- normalizePath(file.path(script_dir, "..", ".."))

sim_path <- file.path(project_dir, "scripts", "R", "cdi-rnaseq-simulate-data.R")

if (!file.exists(sim_path)) {
  stop("Could not find simulator at: ", sim_path, "\nRun this script from the project repository.")
}

data_dir <- file.path(project_dir, "data")
dir.create(data_dir, showWarnings = FALSE, recursive = TRUE)

source(sim_path)

sim <- simulate_rnaseq_counts(
  n_genes = 500,
  n_samples = 12,
  condition = rep(c("Control", "Treatment"), each = 6),
  seed = 123
)

# -----------------------------
# Basic validation
# -----------------------------
if (is.null(sim$counts) || is.null(sim$meta) || is.null(sim$de_genes)) {
  stop("Simulator output is missing required elements: counts, meta, de_genes.")
}

if (ncol(sim$counts) != nrow(sim$meta)) {
  stop("Mismatch: ncol(counts) != nrow(meta).")
}

if (!all(colnames(sim$counts) %in% sim$meta$sample_id)) {
  stop("Mismatch: some count matrix sample IDs are not present in meta$sample_id.")
}

# -----------------------------
# Counts
# -----------------------------
counts_df <- data.frame(
  gene_id = rownames(sim$counts),
  sim$counts,
  check.names = FALSE
)

utils::write.csv(
  counts_df,
  file = file.path(data_dir, "demo-counts.csv"),
  row.names = FALSE
)

# -----------------------------
# Metadata
# -----------------------------
meta_df <- sim$meta

utils::write.csv(
  meta_df,
  file = file.path(data_dir, "demo-metadata.csv"),
  row.names = FALSE
)

# -----------------------------
# Truth (for teaching evaluation)
# -----------------------------
truth_df <- data.frame(
  gene_id = rownames(sim$counts),
  is_true_de = rownames(sim$counts) %in% sim$de_genes
)

utils::write.csv(
  truth_df,
  file = file.path(data_dir, "demo-truth.csv"),
  row.names = FALSE
)

# -----------------------------
# Data dictionary (optional but helpful)
# -----------------------------
dict_path <- file.path(data_dir, "demo-data-dictionary.md")
cat(
  "# Demo RNA-seq dataset\n\n",
  "Files:\n",
  "- `demo-counts.csv`: gene-level raw counts (rows = genes, columns = samples)\n",
  "- `demo-metadata.csv`: sample metadata (`sample_id`, `condition`, `library_size`)\n",
  "- `demo-truth.csv`: teaching label indicating which genes were simulated as truly differential\n\n",
  "Notes:\n",
  "- This dataset is synthetic and intended for learning and demonstration.\n",
  "- Design is balanced: 6 Control and 6 Treatment samples.\n",
  file = dict_path
)

cat("Demo dataset generated successfully.\n")
cat("Files written to: ", data_dir, "\n", sep = "")