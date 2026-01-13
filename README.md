# fyi

For Your Information - R package introspection for LLMs.

## Inspiration

fyi was inspired by [btw](https://github.com/posit-dev/btw), Posit's excellent toolkit for giving LLMs context about R packages.

Both packages solve the same problem (helping LLMs understand R packages) but use different mechanisms:

| Aspect | btw | fyi |
|--------|-----|-----|
| **Mechanism** | MCP tools (runtime calls) | Static files (pre-generated) |
| **How it works** | LLM calls a tool, server returns docs | LLM reads files from disk |
| **Best for** | Chat interfaces with tool calling | CLI agents with file access |
| **Dependencies** | pandoc, S7, cli, etc. | Base R only |

### Tools vs Skills

**Tools** (btw's approach): Functions the LLM can invoke at runtime. The LLM sends a request to an MCP server, which executes code and returns results. Powerful but requires a running server.

```
User: "How does speech() work?"
LLM: [calls btw_tool_docs_help_page("speech", "ttsapi")]
Server: [fetches Rd, converts, returns markdown]
LLM: "Here's how it works..."
```

**Skills** (fyi's approach): Instructions that teach the LLM to read pre-generated files. No server needed - just static files on disk.

```
User: "How does speech() work?"
LLM: [reads ~/.fyi/ttsapi/man-md/speech.md]
LLM: "Here's how it works..."
```

fyi is designed for CLI-based agents like Claude Code that can read files directly. If you're building a chat interface with MCP tool calling, check out btw!

## What it does

fyi provides everything an LLM needs to understand an R package:

- **Exported functions** - Public API with argument signatures
- **Internal functions** - Non-exported functions (accessed via `:::`), often the real workhorses
- **Option names** - Extracted from `getOption()` and `options()` calls in source code
- **Full documentation** - Help pages as markdown, ready for LLM consumption

Output is structured markdown optimized for LLM consumption (19-29% more token-efficient than Rd2txt).

## Installation

```r
# From GitHub
remotes::install_github("cornball-ai/fyi")
```

## Quick Start

```r
library(fyi)

# Generate docs for any package to ~/.fyi/
fyi_cache("dplyr")

# Now you have:
#   ~/.fyi/dplyr/fyi.md        - Summary (exports, internals, options)
#   ~/.fyi/dplyr/man-md/*.md   - Individual doc files
```

For large packages, use filtering:

```r
# torch has 700+ exports - filter to what you need
fyi_cache("torch", pattern = "^nn_")  # Just neural network modules
fyi_cache("torch", max_exports = 100, max_internals = 0)  # Limit counts
```

## Usage

### Unified Cache (~/.fyi/)

All package docs live in `~/.fyi/<package>/` for uniformity:

```r
# Generate cache for any package
fyi_cache("ggplot2")

# Force regeneration after package updates
fyi_cache("mypackage", force = TRUE)
```

### Interactive Exploration

```r
# Print to console
fyi("sttapi")
fyi("sttapi", docs = TRUE)  # Include full documentation

# Individual pieces
fyi_exports("sttapi")
fyi_internals("sttapi")
fyi_options("sttapi")
fyi_help("transcribe", "sttapi")
fyi_docs("sttapi")
```

### Filtering for Large Packages

```r
# Pattern filter
fyi("torch", pattern = "^nn_")
fyi_cache("torch", pattern = "^optim_")

# Limit counts
fyi("torch", max_exports = 50, max_internals = 0, max_topics = 50)

# Filter summary, keep all doc files
fyi_cache("torch", pattern = "^nn_", docs_pattern = NULL)
```

## Example Output

```markdown
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
| `.normalize_segments` | segments |
...

## Options (sttapi)

| Option | File | Type |
|--------|------|------|
| `sttapi.api_base` | internal_backend.R | get |
| `sttapi.api_key` | internal_backend.R | get |
...

## Documentation Topics (4)

For details, read `man-md/<topic>.md` or use `fyi_help("topic", "pkg")`.

Topics: `set_stt_base`, `set_stt_key`, `stt_health`, `transcribe`
```

## Function Reference

| Function | Purpose |
|----------|---------|
| `fyi_cache(pkg)` | Generate docs to ~/.fyi/pkg/ (main entry point) |
| `fyi(pkg)` | Print package overview to console |
| `fyi_exports(pkg)` | List exported functions |
| `fyi_internals(pkg)` | List internal functions |
| `fyi_options(pkg)` | List package options |
| `fyi_help(topic, pkg)` | Single help topic as markdown |
| `fyi_help_topics(pkg)` | List all help topics |
| `fyi_docs(pkg)` | All documentation as markdown |
| `use_fyi_md(pkg)` | Write fyi.md to custom path |
| `use_fyi_docs(pkg)` | Write man-md/*.md to custom path |

## Why "fyi"?

btw ("by the way") gives you the polite intro. fyi ("for your information") gives you the full briefing.

## License

MIT
