# fyi vs btw Comparison

## Token Size Comparison (fyi)

### Summary vs Full Docs

| Package | Summary Only | Full Docs (md) | Ratio |
|---------|-------------|----------------|-------|
| cornyverse | 148 tokens | ~400 | 2.7x |
| sttapi | 416 | 1,082 | 2.6x |
| ttsapi | 750 | 3,296 | 4.4x |
| gpuctl | 446 | 2,866 | 6.4x |
| diffuseR | 1,534 | 9,407 | 6.1x |
| xtxapi | 1,310 | 6,498 | 5.0x |
| chatteRbox | 1,959 | ~10,000 | 5.1x |

### Markdown vs Rd2txt (Full Docs)

| Package | Markdown | Rd2txt | Savings |
|---------|----------|--------|---------|
| sttapi | 1,082 | 1,466 | 26% |
| ttsapi | 3,296 | 4,396 | 25% |
| gpuctl | 2,866 | 4,041 | 29% |
| diffuseR | 9,407 | 11,642 | 19% |
| xtxapi | 6,498 | 8,719 | 25% |

**Notes:**
- Token estimates based on ~4 chars/token
- Summary includes: exports table, internals table, options table, topic list
- Full docs (markdown) is now the default, with 19-29% savings over Rd2txt

## fyi vs btw Output Quality

### fyi (using rd2md - pure R)

**Pros:**
- No dependencies (base R only)
- Clean markdown output with proper headers
- Includes internal functions and options scanning
- Summary mode is compact and useful
- 19-29% more token-efficient than Rd2txt

**Cons:**
- May not handle all edge cases in complex Rd markup

### btw (using Rd2HTML + pandoc)

**Pros:**
- Clean markdown output with proper headers
- Code blocks properly formatted
- Better for LLM consumption

**Cons:**
- Requires pandoc (system dependency)
- More R dependencies (S7, cli, withr, etc.)
- Designed for chat interfaces, not static context files
- No options scanning or internals listing

## Example Output Comparison

### fyi output (rd2md - new default)
```markdown
### Transcribe Audio

#### Description
Transcribe an audio file to text...

#### Arguments
- **`file`**: Path to the audio file to transcribe.
- **`model`**: Model name to use for transcription...
```

### btw output
```markdown
## `help(package = "sttapi", "transcribe")`
### Transcribe Audio

#### Description
Transcribe an audio file to text...

#### Arguments
##### `file`
Path to the audio file to transcribe.
```

### fyi output (Rd2txt - legacy, format="text")
```
_T_r_a_n_s_c_r_i_b_e _A_u_d_i_o

_D_e_s_c_r_i_p_t_i_o_n:

     Transcribe an audio file to text...

_A_r_g_u_m_e_n_t_s:

    file: Path to the audio file to transcribe.
```

## Recommendations

1. **fyi summary mode** (docs=FALSE) for maximum efficiency:
   - Compact (~400-2000 tokens per package)
   - Shows function signatures which is usually enough

2. **fyi full docs** (docs=TRUE) when you need details:
   - Clean markdown output (default)
   - 19-29% more efficient than Rd2txt
   - No external dependencies

3. **btw** if you need interactive chat integration:
   - Requires pandoc and more R dependencies
   - Missing internals/options scanning
