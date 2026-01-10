# fyi

For Your Information - R package introspection for LLMs.

## Purpose

Complements btw by exposing what it misses:
- Internal (non-exported) functions via `:::`
- Option names from `getOption()`/`options()` calls
- Package structure and dependencies

## Quick Start

```r
devtools::load_all(".")

# Get everything about a package
fyi("sttapi")

# Just internals
fyi_internals("sttapi")

# Just options
fyi_options("sttapi")
```

## Design

- Zero dependencies (base R only)
- Output is markdown, suitable for any LLM
- Works on installed packages or source directories

## Conventions

- Base R only (no tidyverse)
- tinytest for testing
