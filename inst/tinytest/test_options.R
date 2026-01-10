# Tests for fyi_options()

# fyi_options requires source files, so test structure only
df <- fyi_options("stats")
expect_true(is.data.frame(df))
expect_true("option" %in% names(df))
expect_true("file" %in% names(df))
expect_true("type" %in% names(df))

# stats is a base package without source accessible, so empty is expected
# Just verify no error occurs
