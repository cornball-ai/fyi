# Tests for main fyi() function

# Test basic output (no docs)
output <- fyi("stats", docs = FALSE)
expect_true(is.character(output))
expect_true(grepl("# fyi: stats", output))
expect_true(grepl("## Exported Functions", output))
expect_true(grepl("## Internal Functions", output))
expect_true(grepl("## Documentation Topics", output))

# Test with docs = TRUE
output_with_docs <- fyi("stats", docs = TRUE)
expect_true(nchar(output_with_docs) > nchar(output))

# Test selective sections
output_exports_only <- fyi("stats", exports = TRUE, internals = FALSE,
                           options = FALSE, docs = FALSE)
expect_true(grepl("## Exported Functions", output_exports_only))
expect_false(grepl("## Internal Functions", output_exports_only))
