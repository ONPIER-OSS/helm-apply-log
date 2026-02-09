# Helm apply log

This plugin can be used as a post renderer to append a `ConfigMap` with some information about the release.
It contains the following data:

- Author
- SHA
- Branch
- CI (When CI env variable is set)
- Status (It's "dirty" when there are uncommitted changes, otherwise - "clean")

## Installation

Execute the following command:
```shell
# -- For the version v0.3.0
$ export VERSION=v0.3.0
$ helm plugin install "https://github.com/ONPIER-OSS/helm-apply-log/archive/refs/tags/${VERSION}.tar.gz"
```

## Release a new version

To release a new version, update the `plugin.yaml` file and simply create a new git tag in the repo. For example

```shell
$ git tag v0.4.0 -m "Some message"
```

Then you should be able to install the new version by the command written in the "Installation" section, don't forget to update the version in the export command.

Also, it makes sense to keep this README up-to-date with the current latest release

## How to use with helmfile

To use the plugin, you'll probably have to use the `gotmpl` helmfile.

The plugin can be enabled with the following code:

```gotmpl
helmDefaults:
  postRenderer: apply-log
  postRendererArgs:
    - "{{ `{{ .Release.Name }}` }}"
```

## Develop locally

To develop locally, you will have to remove the installed version of the plugin:

```shell
$ helm plugin uninstall apply-log
```

Then apply your changes and install the local version:

```shell
$ helm plugin install .
```

To test the changes (with helmfile), just run a diff with a newly installed version of the plugin
```shell
$ helmfile diff
```

You should see the expected changes in the apply-log configmaps
