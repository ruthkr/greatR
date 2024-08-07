#' Calculate distance between sample data before and after registration
#'
#' \code{calculate_distance()} is a function that allows users to calculate
#' pairwise distances between samples from different time points to
#' investigate the similarity of progression before or after registration.
#'
#' @param results Result of registration process using [register()].
#' @param type Whether to calculate distance considering only "registered" genes (default) or "all" genes.
#' @param genes_list Optional vector indicating the \code{gene_id} values to be considered.
#'
#' @return This function returns a \code{dist_greatR} object containing two data frames:
#'
#' \item{registered}{pairwise distance between scaled reference and query expressions using registered time points.}
#' \item{original}{pairwise distance between scaled reference and query expressions using original time points.}
#'
#' @export
calculate_distance <- function(results, type = c("registered", "all"), genes_list = NULL) {
  # Suppress "no visible binding for global variable" note
  gene_id <- NULL
  gene_ref <- NULL
  gene_query <- NULL
  accession <- NULL
  timepoint <- NULL
  timepoint_reg <- NULL
  timepoint_ref <- NULL
  timepoint_query <- NULL
  expression_value <- NULL
  exp_ref <- NULL
  exp_query <- NULL

  # Validate parameters
  type <- match.arg(type)

  # Retrieve data from results
  data <- results$data
  reference <- attr(data, "ref")
  query <- attr(data, "query")

  # Parse data
  if (type == "registered") {
    reg_genes <- results$model_comparison[results$model_comparison$registered, gene_id]
    data <- data[data$gene_id %in% reg_genes, ]
  }

  # Select genes to be considered
  if (any(!is.null(genes_list))) {
    if (!inherits(genes_list, "character")) {
      stop(
        cli::format_error(c(
          "{.var genes_list} must be a {.cls character} vector.",
          "x" = "You supplied vectors with {.cls {class(genes_list)}} values."
        )),
        call. = FALSE
      )
    }

    data <- data[data$gene_id %in% genes_list]
  }

  # Split data into referene and query
  data <- unique(data[, .(expression_value = mean(expression_value)), by = .(gene_id, accession, timepoint, timepoint_reg)])
  data_query <- data[data$accession == query][, .(gene_query = gene_id, accession, timepoint_query = timepoint, timepoint_reg, exp_query = expression_value)]
  data_ref <- data[data$accession == reference][, .(gene_ref = gene_id, accession, timepoint_ref = timepoint, timepoint_reg, exp_ref = expression_value)]

  # Impute query expression values
  data_query_imputed <- impute_query_exp_value(data_query[, .(gene_query, timepoint_reg, exp_query)])

  # Cross join all reference and query time points
  timepoint_cj_result <- get_timepoint_comb_data(
    data_ref[, .(gene_ref, timepoint_ref, exp_ref)],
    data_query_imputed
  )[order(gene_id, timepoint_query)]

  timepoint_cj_original <- get_timepoint_comb_data(
    data_ref[, .(gene_ref, timepoint_ref, exp_ref)],
    data_query[, .(gene_query, timepoint_query, exp_query)]
  )

  # Rename timepoints
  timepoint_cj_result$timepoint_ref <- gsub("^ref_", paste0(reference, " "), timepoint_cj_result$timepoint_ref)
  timepoint_cj_result$timepoint_ref <- gsub("^query_", paste0(query, " "), timepoint_cj_result$timepoint_ref)
  timepoint_cj_result$timepoint_query <- gsub("^ref_", paste0(reference, " "), timepoint_cj_result$timepoint_query)
  timepoint_cj_result$timepoint_query <- gsub("^query_", paste0(query, " "), timepoint_cj_result$timepoint_query)

  timepoint_cj_original$timepoint_ref <- gsub("^ref_", paste0(reference, " "), timepoint_cj_original$timepoint_ref)
  timepoint_cj_original$timepoint_ref <- gsub("^query_", paste0(query, " "), timepoint_cj_original$timepoint_ref)
  timepoint_cj_original$timepoint_query <- gsub("^ref_", paste0(reference, " "), timepoint_cj_original$timepoint_query)
  timepoint_cj_original$timepoint_query <- gsub("^query_", paste0(query, " "), timepoint_cj_original$timepoint_query)

  # Calculate mean square distances
  dist_result <- timepoint_cj_result[, .(distance = mean((exp_ref - exp_query)^2)), by = .(timepoint_ref, timepoint_query)][timepoint_query >= 0]
  dist_original <- timepoint_cj_original[, .(distance = mean((exp_ref - exp_query)^2)), by = .(timepoint_ref, timepoint_query)][timepoint_query >= 0]

  # Add accession values as data attributes
  data.table::setattr(dist_result, "ref", reference)
  data.table::setattr(dist_result, "query", query)
  data.table::setattr(dist_original, "ref", reference)
  data.table::setattr(dist_original, "query", query)

  # Results object
  results_list <- list(
    result = dist_result,
    original = dist_original
  )

  return(new_dist_greatR(results_list))
}

#' Impute query expression values from query fitted spline
#'
#' @noRd
impute_query_exp_value_from_spline <- function(data_query) {
  # Suppress "no visible binding for global variable" note
  gene_query <- NULL
  timepoint_reg <- NULL
  timepoint_query <- NULL
  exp_query <- NULL

  # The imputed query time points to estimate expression values for
  timepoint_ranges_query <- data_query[, .(min_t = ceiling(min(timepoint_reg)), max_t = floor(max(timepoint_reg))), by = "gene_query"]

  imputed_query_timepoints <- data.table::rbindlist(
    Map(
      function(x, min_t, max_t) {
        data.table::data.table(
          gene_query = rep(x, max_t - min_t + 1),
          timepoint_query = seq(min_t, max_t)
        )
      }, timepoint_ranges_query$gene_query, timepoint_ranges_query$min_t, timepoint_ranges_query$max_t
    )
  )

  # Fit using cubic splines with K+3 params for each gene
  genes <- unique(data_query$gene_query)

  fits <- lapply(
    genes,
    function(gene) {
      fit_spline_model(
        data_query[data_query$gene_query == gene],
        x = "timepoint_reg",
        y = "exp_query"
      )
    }
  )
  names(fits) <- genes

  # Predict query expression values
  preds_query <- lapply(
    genes,
    function(gene) {
      data <- unique(imputed_query_timepoints[imputed_query_timepoints$gene_query == gene][, .(timepoint_reg = timepoint_query)])
      data[, .(gene_query = gene, timepoint_query = timepoint_reg, exp_query = stats::predict(fits[gene][[1]], newdata = data))]
    }
  )

  # Left join to imputed timepoints
  data_query_imputed <- merge(
    imputed_query_timepoints,
    data.table::rbindlist(preds_query),
    by = c("gene_query", "timepoint_query")
  )

  return(data_query_imputed)
}

#' Impute query expression values from query timepoints
#'
#' @noRd
impute_query_exp_value <- function(data_query) {
  # Suppress "no visible binding for global variable" note
  gene_query <- NULL
  timepoint_reg <- NULL
  timepoint_query <- NULL
  exp_query <- NULL

  # Interpolate using approxfun
  genes <- unique(data_query$gene_query)

  imputed_list <- lapply(
    genes,
    function(gene) {
        data <- data_query[data_query$gene_query == gene]

        timepoint_range <- data[, .(min_t = ceiling(min(timepoint_reg)), max_t = floor(max(timepoint_reg)))]
        timepoint_range_seq <- timepoint_range$min_t:timepoint_range$max_t

        interp_data <- data.table::data.table(
          gene_query = gene,
          timepoint_query = timepoint_range_seq,
          exp_query = approxfun(data$timepoint_reg, data$exp_query)(timepoint_range_seq)
        )

        return(interp_data)
    }
  )

  # Bind results
  data_query_imputed <- data.table::rbindlist(imputed_list)

  return(data_query_imputed)
}

#' Cross join all reference and query time points and expression values
#'
#' @noRd
get_timepoint_comb_data <- function(data_ref, data_query, cross_join_all = FALSE) {
  # Suppress "no visible binding for global variable" note
  gene_id <- NULL
  gene_ref <- NULL
  gene_query <- NULL
  timepoint <- NULL
  timepoint_ref <- NULL
  timepoint_query <- NULL
  expression_value <- NULL
  exp_ref <- NULL
  exp_query <- NULL

  # Rename timepoints
  data_ref <- data_ref[, timepoint_ref := paste0("ref_", timepoint_ref)]
  data_query <- data_query[, timepoint_query := paste0("query_", timepoint_query)]

  # Parse data
  if (cross_join_all) {
    data_ref_parsed <- rbind(
      data_ref[, .(gene_ref, timepoint_ref, exp_ref)],
      data_query[, .(gene_ref = gene_query, timepoint_ref = timepoint_query, exp_ref = exp_query)]
    )
    data_query_parsed <- rbind(
      data_query[, .(gene_query, timepoint_query, exp_query)],
      data_ref[, .(gene_query = gene_ref, timepoint_query = timepoint_ref, exp_query = exp_ref)]
    )
  } else {
    data_ref_parsed <- data_ref
    data_query_parsed <- data_query
  }

  # Perform cross join
  genes <- unique(data_query_parsed$gene_query)

  comb <- lapply(
    genes,
    function(gene) {
      cross_join(
        unique(data_ref_parsed[data_ref_parsed$gene_ref == gene]),
        unique(data_query_parsed[data_query_parsed$gene_query == gene])
      )
    }
  )

  comb <- data.table::rbindlist(comb)

  # Select relevant columns
  comb <- comb[, .(gene_id = gene_ref, timepoint_ref, timepoint_query, exp_ref, exp_query)]

  return(comb)
}

new_dist_greatR <- function(x) {
  structure(x, class = c("dist_greatR", class(x)))
}

#' @export
print.dist_greatR <- function(x, ...) {
  print(x[seq_along(x)])
  return(invisible(x))
}
