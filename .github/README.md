## Dev

Install [`Brewfile`](../Brewfile) tools and dependencies with [homebrew](https://brew.sh/):

```bash
brew bundle
```

## Publish new update

```
ditto -c -k --sequesterRsrc --keepParent <src_path_to_app> <zip_dest>
./bin/sign_update <zip_dest>.zip # Use output to update appcast.xml
```
