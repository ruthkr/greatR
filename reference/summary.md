# Summarise registration results

Summarise registration results

## Usage

``` r
# S3 method for class 'res_greatR'
summary(object, ...)
```

## Arguments

- object:

  Registration results, output of the
  [`register()`](https://ruthkr.github.io/greatR/reference/register.md)
  registration process.

- ...:

  Arguments to be passed to methods (ignored).

## Value

This function returns a list containing:

- summary:

  table containing the summary of the registration results.

- registered_genes:

  vector of gene accessions which were successfully registered.

- non_registered_genes:

  vector of non-registered gene accessions.

- reg_params:

  table containing distribution of registration parameters.
