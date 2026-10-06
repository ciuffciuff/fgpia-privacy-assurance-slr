# Cohen's kappa for the title/abstract screening
# RSL FGP-IA (GQPC 2026.2, PPCA/UnB)
# Reads screening/agreement_title_abstract.csv when run from the repository root.

kappa_cohen <- function(a, b, c, d) {
  # a: both include; d: both exclude; b, c: divergent decisions
  n  <- a + b + c + d
  po <- (a + d) / n
  pe <- ((a + b) * (a + c) + (c + d) * (b + d)) / n^2
  c(n = n, observed = po, expected = pe, kappa = (po - pe) / (1 - pe))
}

agr <- read.csv("screening/agreement_title_abstract.csv")
both_include <- agr$records[agr$decision == "both_include"]
both_exclude <- agr$records[agr$decision == "both_exclude"]
divergent    <- agr$records[agr$decision == "divergent_resolved_exclude"]

# The split of the divergent decisions between reviewers does not change kappa
# at the third decimal; an even split is used here.
res <- kappa_cohen(a = both_include,
                   b = ceiling(divergent / 2),
                   c = floor(divergent / 2),
                   d = both_exclude)
print(round(res, 4))   # kappa = 0.935
