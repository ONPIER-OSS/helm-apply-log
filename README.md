# Helm apply log

This plugin can be used as a post renderer to append a `ConfigMap` with some information about the release.
It contains the following data:

- Author
- SHA
- Branch
- CI (When CI env variable is set)
- Status (It's "dirty" when there are uncommitted changes, otherwise - "clean")

## Installation
Download the public key from the release artifacts and import it.
```shell
# -- For the version v0.3.1
$ export VERSION=0.3.1
$ curl -LO https://github.com/ONPIER-OSS/helm-apply-log/releases/download/v${VERSION}/pubkey.asc
$ gpg --import pubkey.asc
```

Create keyring file. (Helm uses this file by default to verify the plugin)
```shell
$ gpg --export >~/.gnupg/pubring.gpg;
```


Install the plugin:
```shell
$ helm plugin install --verify "https://github.com/ONPIER-OSS/helm-apply-log/releases/download/v${VERSION}/apply-log-${VERSION}.tgz"
```

## Release a new version

To release a new version, bump the version in the `plugin.yaml` file and open a pull request. Simply run the `release.sh` after merging you pull request.

```shell
$ ./release.sh
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
