# Submission Notes

Submission notebooks are located at the files:

- Task 1: `UniswapAnalysis.ipynb`
- Task 2: `PegDeviation.ipynb`

## Data

Data downloaded was checked in and can be located in the `data` folder.

## Code

## Requirements

Requires `julia` and `poetry`. Install the codebase with `poetry install`.

To run the julia notebook, navigate to `Uniswap` and run `Pkg; instantiate`.
This should install dependencies required to run julia notebooks. If it does
fail, simply add IJulia to the local deps.

## Overview

After installation, you can start a local jupyter notebook lab via
`poetry run jupyter lab`, where you can see relevant notebooks.

Julia code is located in a package folder in `Uniswap` and is packaged as a julia
library. The code uses a useful non-linear optimization packge to generate pool
positions from initial conditions, useful in the analysis of uniswap positions
across different prices. The overall report can be found in the `UniswapAnalysis.ipynb`
file.

Data processing code is in `utils/` to download, clean, and merge necessary files for
task 2. It's notebook can be found at `PegDeviation.ipynb`.