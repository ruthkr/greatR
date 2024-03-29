% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/summary.R
\name{summary}
\alias{summary}
\alias{summary.res_greatR}
\title{Summarise registration results}
\usage{
\method{summary}{res_greatR}(object, ...)
}
\arguments{
\item{object}{Registration results, output of the \code{\link[=register]{register()}} registration process.}

\item{...}{Arguments to be passed to methods (ignored).}
}
\value{
This function returns a list containing:

\item{summary}{table containing the summary of the registration results.}
\item{registered_genes}{vector of gene accessions which were successfully registered.}
\item{non_registered_genes}{vector of non-registered gene accessions.}
\item{reg_params}{table containing distribution of registration parameters.}
}
\description{
Summarise registration results
}
