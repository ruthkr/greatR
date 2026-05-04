# Register or synchronize different expression profiles

`register()` is a function to register expression profiles a user wishes
to compare.

## Usage

``` r
register(
  input,
  stretches = NA,
  shifts = NA,
  reference,
  query,
  scaling_method = c("none", "z-score", "min-max"),
  overlapping_percent = 50,
  use_optimisation = TRUE,
  optimisation_method = c("lbfgsb", "nm", "sa"),
  optimisation_config = NULL,
  exp_sd = NA,
  num_cores = NA
)
```

## Arguments

- input:

  Input data frame containing all replicates of gene expression in each
  genotype at each time point.

- stretches:

  Candidate registration stretch factors to apply to query data, only
  required if `use_optimisation = FALSE`.

- shifts:

  Candidate registration shift values to apply to query data, only
  required if `use_optimisation = FALSE`.

- reference:

  Accession name of reference data.

- query:

  Accession name of query data.

- scaling_method:

  Scaling method applied to data prior to registration process. Either
  `none` (default), `z-score`, or `min-max`.

- overlapping_percent:

  Minimum percentage of overlapping time point range of the reference
  data. Shifts will be only considered if it leaves at least this
  percentage of overlapping time point range after applying the
  registration.

- use_optimisation:

  Whether to optimise registration parameters. By default, `TRUE`.

- optimisation_method:

  Optimisation method to use. Either `"lbfgsb"` for L-BFGS-B (default),
  `"nm"` for Nelder-Mead, or `"sa"` for Simulated Annealing.

- optimisation_config:

  Optional list with arguments to override the default optimisation
  configuration.

- exp_sd:

  Optional experimental standard deviation on the expression replicates.

- num_cores:

  Number of cores to use if the user wants to register genes
  asynchronously (in parallel) in the background on the same machine. By
  default, `NA`, the registration will be run without parallelisation.

## Value

This function returns a `res_greatR` object containing:

- data:

  a table containing the scaled input data and an additional
  `timepoint_reg` column after applying registration parameters to the
  query data.

- model_comparison:

  a table comparing the optimal registration function for each gene
  (based on `all_shifts_df` scores) to model with no registration
  applied.

- fun_args:

  a list of arguments used when calling the function.

## Examples

``` r
if (FALSE) { # \dontrun{
# Load a data frame from the sample data
data_path <- system.file("extdata/brapa_arabidopsis_data.csv", package = "greatR")
all_data <- utils::read.csv(data_path)

# Running the registration
registration_results <- register(
  input = all_data,
  reference = "Ro18",
  query = "Col0"
)
} # }
```
