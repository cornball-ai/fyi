# fyi

For Your Information - R package introspection for LLMs.

## What it does

`fyi` is a standalone alternative to [btw](https://github.com/jmbuhr/btw) that requires no dependencies. It provides everything an LLM needs to understand an R package:

- **Exported functions** - Public API with argument signatures
- **Internal functions** - Non-exported functions (accessed via `:::`), often the real workhorses
- **Option names** - Extracted from `getOption()` and `options()` calls in source code
- **Full documentation** - Help pages as text, ready for LLM consumption

Output is structured markdown suitable for any LLM.

## Installation

```r
# From GitHub
remotes::install_github("cornball-ai/fyi")
```

## Usage

```r
library(fyi)

# Get overview (exports, internals, options, doc topics)
fyi("sttapi")

# Get everything including full documentation
fyi("sttapi", docs = TRUE)

# Just the pieces you need
fyi_exports("sttapi")        # Public API
fyi_internals("sttapi")      # Hidden functions
fyi_options("sttapi")        # Option names
fyi_help_topics("sttapi")    # List doc topics
fyi_help("transcribe", "sttapi")  # Single help page
fyi_docs("sttapi")           # All documentation

# Filter with regex
fyi_internals("sttapi", pattern = "^\\.") # Functions starting with .

# Select specific docs
fyi_docs("sttapi", topics = c("transcribe", "set_stt_base"))
```

## Example Output

```
# fyi: sttapi

## Exported Functions (sttapi::)

| Function | Arguments |
|----------|-----------|
| `set_stt_base` | url |
| `set_stt_key` | key |
| `stt_health` |  |
| `transcribe` | file, model, language, response_format, backend |

## Internal Functions (sttapi:::)

| Function | Arguments |
|----------|-----------|
| `.check_api_health` | base_url |
| `.choose_backend` | backend |
| `.normalize_segments` | segments |
| `.time_to_seconds` | time_str |
...

## Options (sttapi)

| Option | File | Type |
|--------|------|------|
| `sttapi.api_base` | internal_backend.R | get |
| `sttapi.api_key` | internal_backend.R | get |
| `sttapi.backend` | internal_backend.R | get |
...

## Documentation Topics (4)

Use `fyi_help("topic", "sttapi")` or `fyi_docs("sttapi")` for full docs.

Topics: `set_stt_base`, `set_stt_key`, `stt_health`, `transcribe`
```

## Why "fyi"?

btw ("by the way") gives you the polite intro. fyi gives you the full story.

## License

MIT
