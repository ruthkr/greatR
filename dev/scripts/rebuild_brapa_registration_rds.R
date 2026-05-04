# Rebuild inst/extdata/brapa_arabidopsis_registration.rds
#
# From the R console (set working directory inside the package, e.g. project root):
#   source("dev/scripts/rebuild_brapa_registration_rds.R")
#
# From a terminal (any working directory):
#   Rscript path/to/greatR/dev/scripts/rebuild_brapa_registration_rds.R
#
# Requires: here, pkgload. Uses rprojroot (via here) to find the package root, then here::here().

if (!requireNamespace("here", quietly = TRUE)) {
  stop("Install package 'here' (e.g. install.packages(\"here\"))", call. = FALSE)
}
if (!requireNamespace("pkgload", quietly = TRUE)) {
  stop("Install package 'pkgload' (e.g. install.packages(\"pkgload\"))", call. = FALSE)
}

# Package root: directory of this file when run via Rscript --file=..., else getwd() (source()).
file_args <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
script <- if (length(file_args)) {
  sub("^--file=", "", file_args[length(file_args)])
} else {
  ""
}
path_for_root <- if (nzchar(script) && file.exists(script)) {
  dirname(normalizePath(script, winslash = "/", mustWork = TRUE))
} else {
  getwd()
}
setwd(rprojroot::find_root(rprojroot::is_r_package, path = path_for_root))

here::i_am("dev/scripts/rebuild_brapa_registration_rds.R")

csv <- here::here("inst", "extdata", "brapa_arabidopsis_data.csv")
stopifnot(
  file.exists(here::here("DESCRIPTION")),
  file.exists(csv)
)

suppressPackageStartupMessages({
  pkgload::load_all(here::here(), export_all = FALSE)
  library(data.table)
})

b_rapa_data <- fread(csv)

registration_results <- register(
  b_rapa_data,
  reference = "Ro18",
  query = "Col0",
  scaling_method = "z-score"
)

out <- here::here("inst", "extdata", "brapa_arabidopsis_registration.rds")
saveRDS(registration_results, out, version = 2)
message("Wrote ", normalizePath(out, winslash = "/", mustWork = TRUE))
