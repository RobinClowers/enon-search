# Enron Search

This is a fairly simple full text search engine with prefix based indexing. For
fun, it uses the real Enron email correspondence, which was made public during
the trial.

## Development

Use bin scripts either directly, or using direnv save typing.

- test: runs rspec with .env.test environment
- specs: alias for test, doesn't conflict with gnu test
- process: run the indexer with a default limit of 10k files
- search: searches the index for a partial or exact match of the query
