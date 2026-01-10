# Tests for documentation functions

# Test fyi_help_topics
topics <- fyi_help_topics("stats")
expect_true(is.character(topics))
expect_true(length(topics) > 0)
expect_true("lm" %in% topics)

# Test fyi_help - basic functionality
txt <- fyi_help("lm", "stats")
expect_true(is.character(txt))
expect_true(nchar(txt) > 100)  # Should have substantial content

# Test fyi_help - non-existent topic
expect_error(fyi_help("nonexistent_topic_12345", "stats"))

# Test fyi_docs - all docs
docs <- fyi_docs("stats")
expect_true(is.character(docs))
expect_true(nchar(docs) > 1000)  # Should have substantial content

# Test fyi_docs - specific topics
docs_subset <- fyi_docs("stats", topics = c("lm", "glm"))
expect_true(is.character(docs_subset))
expect_true(nchar(docs_subset) < nchar(docs))  # Should be smaller than full docs
