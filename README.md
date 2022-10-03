# Docker image caddy-coraza

## Build the image

Run `build.sh` script without arguments to build this image.

```
$ ./build.sh
```

This script reads two environment variables: 
- CADDY_VER: Version of Caddy server to build.
- CRS_VER: Version of OWASP Core Rule Set to deploy.

If these variables are not set, the script will find the latest release tag in the GitHub repository for each dependency.
