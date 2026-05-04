# Visualise registration results

Visualise registration results

## Usage

``` r
# S3 method for class 'res_greatR'
plot(
  x,
  type = c("result", "original"),
  genes_list = NULL,
  show_rep_mean = FALSE,
  ncol = NULL,
  title = NULL,
  ...
)

# S3 method for class 'dist_greatR'
plot(
  x,
  type = c("result", "original"),
  match_timepoints = TRUE,
  title = NULL,
  ...
)

# S3 method for class 'summary.res_greatR'
plot(
  x,
  type = c("all", "registered"),
  type_dist = c("histogram", "density"),
  genes_list = NULL,
  bins = 30,
  alpha = NA,
  scatterplot_size = c(4, 3),
  title = NULL,
  ...
)
```

## Arguments

- x:

  Input object.

  - For `plot.res_greatR()`: registration results, output of the
    [`register()`](https://ruthkr.github.io/greatR/reference/register.md)
    registration process.

  - For `plot.summary.res_greatR()`: registration results summary,
    output of
    [`summary()`](https://ruthkr.github.io/greatR/reference/summary.md).

  - For `plot.dist_greatR()`: pairwise distances between reference and
    query time points, output of
    [`calculate_distance()`](https://ruthkr.github.io/greatR/reference/calculate_distance.md).

- type:

  Type of plot.

  - For both `plot.res_greatR()` and `plot.dist_greatR()`: whether to
    use registration "result" (default) or "original" time points.

  - For `plot.summary.res_greatR()`: whether to show "all" genes
    (default) or only "registered" ones.

- genes_list:

  Optional vector indicating the `gene_id` values to be plotted.

- show_rep_mean:

  Whether to show `replicate` mean values.

- ncol:

  Number of columns in the plot grid. By default this is calculated
  automatically.

- title:

  Optional plot title.

- ...:

  Arguments to be passed to methods (ignored).

- match_timepoints:

  If `TRUE`, will match query time points to reference time points.

- type_dist:

  Type of marginal distribution. Can be either "histogram" (default), or
  "density".

- bins:

  Number of bins to use when `type_dist` = "histogram". By default, 30.

- alpha:

  Optional opacity of the points in the scatterplot.

- scatterplot_size:

  Vector `c(width, height)` specifying the ratio of width and height of
  the scatterplot with respect to stretch and shift distribution plots.

## Value

- For `plot.res_greatR()`: plot of genes of interest after registration
  process (`type = "result"`) or showing original time points
  (`type = "original"`).

- For `plot.dist_greatR()`: distance heatmap of gene expression profiles
  over time between reference and query.

- For `plot.summary.res_greatR()`: TODO.
