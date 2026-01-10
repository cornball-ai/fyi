# Tests for fyi_internals()

# Test with a known package (stats has internals)
df <- fyi_internals("stats")
expect_true(is.data.frame(df))
expect_true("name" %in% names(df))
expect_true("args" %in% names(df))
# stats definitely has internal functions
expect_true(nrow(df) > 0)

# Test pattern filtering
df_dot <- fyi_internals("stats", pattern = "^\\.")
expect_true(all(grepl("^\\.", df_dot$name)))

# Test non-existent package
expect_error(fyi_internals("nonexistent_package_12345"))
