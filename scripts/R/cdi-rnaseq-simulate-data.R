simulate_rnaseq_counts <- function(
  n_genes = 500,
  n_samples = 12,
  condition = rep(c("Control", "Treatment"), each = n_samples/2),
  seed = 123
){
  set.seed(seed)

  stopifnot(length(condition) == n_samples)

  # Library sizes
  lib_size <- round(stats::rlnorm(n_samples, meanlog = 15, sdlog = 0.3))
  size_factor <- lib_size / stats::median(lib_size)

  # Baseline expression per gene
  base_mu <- stats::rgamma(n_genes, shape = 2, rate = 0.1)  # positive, skewed
  dispersion <- stats::rgamma(n_genes, shape = 2, rate = 10) # moderate dispersion

  # Define DE genes
  de_idx <- sample(seq_len(n_genes), size = round(0.1 * n_genes))
  lfc <- rep(0, n_genes)
  lfc[de_idx] <- stats::rnorm(length(de_idx), mean = 1, sd = 0.3) # upregulated in Treatment

  is_treatment <- condition == "Treatment"

  # Mean matrix (gene x sample)
  mu <- outer(base_mu, size_factor)
  mu[, is_treatment] <- mu[, is_treatment] * exp(lfc)

  # Counts from negative binomial
  counts <- matrix(0, nrow = n_genes, ncol = n_samples)
  for (g in seq_len(n_genes)){
    # NB parameterization: size = 1/dispersion, mu = mu
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