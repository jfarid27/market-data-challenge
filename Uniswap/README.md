# Uniswap Solver Data for Julia

Includes packages to analyze and check Uniswap pool states, as well as computing state changes given various constraints.

## Requirements

Julia should be installed and available in the CLI.

## Installing/Environment

1. Switch to package mode in the terminal (type "]" in the Julia CLI) and activate the environment with `activate Uniswap`.
2. Install packages with `instantiate`.

## Usage

After package instantiation, you should be able to `include('./src/Uniswap.jl')` or import with `using Uniswap`.

## Testing

After instantiation, switch to package mode in the terminal and run `test`. 