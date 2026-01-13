# fyi vs btw Comparison

## Token Size Comparison (fyi)

| Package | Summary Only | Full Docs | Ratio |
|---------|-------------|-----------|-------|
| cornyverse | 148 tokens | 564 | 3.8x |
| sttapi | 416 | 1,811 | 4.4x |
| ttsapi | 750 | 4,992 | 6.7x |
| gpuctl | 446 | 4,326 | 9.7x |
| diffuseR | 1,534 | 12,860 | 8.4x |
| xtxapi | 1,310 | 9,744 | 7.4x |
| chatteRbox | 1,959 | 13,537 | 6.9x |

**Notes:**
- Token estimates based on ~4 chars/token
- Summary includes: exports table, internals table, options table, topic list
- Full docs adds: complete Rd2txt output for all help pages

## fyi vs btw Output Quality

### fyi (using tools::Rd2txt)

**Pros:**
- No dependencies (base R only)
- Includes internal functions and options scanning
- Summary mode is compact and useful

**Cons:**
- Full docs have ugly ASCII formatting: `_T_r_a_n_s_c_r_i_b_e_` for bold
- Rd markup like `\describe{}` not converted properly
- Wastes tokens on formatting noise

### btw (using custom Rd→markdown conversion)

**Pros:**
- Clean markdown output with proper headers
- Code blocks properly formatted
- Better for LLM consumption

**Cons:**
- More dependencies (S7, cli, etc.)
- Designed for chat interfaces, not static context files
- No options scanning or internals listing

## Example Output Comparison

### btw output (clean markdown)
```markdown
## `help(package = "sttapi", "transcribe")`
### Transcribe Audio

#### Description
Transcribe an audio file to text...

#### Arguments
##### `file`
Path to the audio file to transcribe.
```

### fyi output (Rd2txt)
```
_T_r_a_n_s_c_r_i_b_e _A_u_d_i_o

_D_e_s_c_r_i_p_t_i_o_n:

     Transcribe an audio file to text...

_A_r_g_u_m_e_n_t_s:

    file: Path to the audio file to transcribe.
```

## Recommendations

1. **fyi summary mode** (docs=FALSE) is the best balance:
   - Compact (~400-2000 tokens per package)
   - Shows function signatures which is usually enough
   - No formatting noise

2. **fyi full docs** wastes tokens on Rd2txt formatting

3. **btw** produces cleaner docs but:
   - Requires more dependencies
   - Missing internals/options which are useful for development

4. **Potential improvement for fyi:**
   - Add Rd→markdown conversion like btw does
   - Would give clean output without extra dependencies
