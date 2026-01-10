# Tests for fyi_exports()

# Test with a known package
df <- fyi_exports("stats")
expect_true(is.data.frame(df))
expect_true("name" %in% names(df))
expect_true("args" %in% names(df))
expect_true(nrow(df) > 0)

# Test that common stats functions are found
expect_true("lm" %in% df$name)
expect_true("t.test" %in% df$name)

# Test pattern filtering
df_filtered <- fyi_exports("stats", pattern = "^lm")
expect_true(nrow(df_filtered) < nrow(df))
expect_true(all(grepl("^lm", df_filtered$name)))

# Test non-existent package
expect_error(fyi_exports("nonexistent_package_12345"))
