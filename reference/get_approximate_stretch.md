# Get approximate stretch factor

`get_approximate_stretch()` is a function to get a stretch factor
estimation given input data. This function will take the time point
ranges of both reference and query data and compare them to estimate the
stretch factor.

## Usage

``` r
get_approximate_stretch(data, reference = "ref", query = "query")
```

## Arguments

- data:

  Input data frame, either containing all replicates of gene expression
  or not.

- reference:

  Accession name of reference data.

- query:

  Accession name of query data.

## Value

This function returns an estimation of a stretch factor for registering
the data.
