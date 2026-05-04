# Calculate distance between sample data before and after registration

`calculate_distance()` is a function that allows users to calculate
pairwise distances between samples from different time points to
investigate the similarity of progression before or after registration.

## Usage

``` r
calculate_distance(results, type = c("registered", "all"), genes_list = NULL)
```

## Arguments

- results:

  Result of registration process using
  [`register()`](https://ruthkr.github.io/greatR/reference/register.md).

- type:

  Whether to calculate distance considering only "registered" genes
  (default) or "all" genes.

- genes_list:

  Optional vector indicating the `gene_id` values to be considered.

## Value

This function returns a `dist_greatR` object containing two data frames:

- registered:

  pairwise distance between scaled reference and query expressions using
  registered time points.

- original:

  pairwise distance between scaled reference and query expressions using
  original time points.
