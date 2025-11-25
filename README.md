# Helm apply log

This plugin can be used as a post renderrer to append a `ConfigMap` with some information about the release.
It contains the following data:

- Author
- SHA
- Branch
- CI (When CI env variable is set)
- Status (It's "dirty" when there are uncommitted changes, otherwise - "clean")
