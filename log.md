# Development log

Some notes from development.

## Chunk size performance

As expected, larger chunk size dramatically improves performance, because it
results in larger batches of file writes.

```bash
$ rm -rf index
$ time index --max-files 100_000 --chunk-size 100
real 11m54.516s
user 2m16.925s
sys 3m7.958s
```

```bash
$ rm -rf index
```

Note: this used nearly 10GB of RAM

```bash
$ time index --max-files 100_000 --chunk-size 100_000

real 3m40.394s
user 2m15.568s
sys 0m48.657s
```
