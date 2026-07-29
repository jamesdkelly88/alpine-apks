# Alpine APKs

Alpine package repository, built by Github Actions and hosted on Github Pages

- [Alpine APKs](#alpine-apks)
  - [Usage](#usage)
    - [Automated](#automated)
    - [Manual](#manual)
    - [Versioning](#versioning)
  - [Packages](#packages)
    - [Installing](#installing)


## Usage

### Automated

Deployed via GitHub actions:

1. **Publish** will create the packages and indexes, then commit them to the `gh-pages` branch
2. **pages-build-deployment** bre triggered on commit to publish the packages and indexes to [GitHub Pages](https://jamesdkelly88.github.io/alpine-apks/)


### Manual

1. Clone this repository
2. Run an Alpine Linux Docker container as a build environment (replace the version number as required):
    ```sh
    docker run --rm -it -v $(pwd):/source alpine:3.24
    ```
3. Run the following commands inside the Docker container
    ```sh
    # Setup environment as root
    apk add alpine-sdk lua-aports sudo
    # Create runner user - must match your UID, which can be checked with `echo $UID`
    adduser -u 1001 -D runner
    addgroup runner abuild
    echo 'runner ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers
    mkdir /output
    chown runner:users /output
    # Switch to runner
    su runner
    cd /source
    # Create temporary keys
    abuild-keygen -a -i -n
    # Build repository
    buildrepo -p -a . -d /output/v3.24 postgresql
    # Build a single package
    cd /source/postgresql/postgresql18-age
    abuild -r -P /output/v3.24
    # Check output
    ls -lR /output
    ```
4. Check the output folder is as expected
5. Exit the Docker container
6. Changes should be committed to the `main` branch so they are reproduced by automation. Don't commit manual changes to `gh-pages` unless you are cleaning up mistakes.

### Versioning

- `pkgname` should include the PostgreSQL major version if required e.g. `postgresql18-age`
- `pkgver` should be the version of the software being packaged
- `pkgrel` should be `0`, unless a significant change is made to the `APKBUILD` file without incrementing `pkgver`
- `_pgver` should be the PostgreSQL major version to build against
- Release descriptors are suffixes starting with an underscore
  - **Pre**-releases have a suffix starting `_alpha`,`_beta`,`_pre` or `_rc` e.g. `postgresql19_beta2`
  - **Post**-releases have a suffix starting `_cvs`,`_svn`,`_git`,`_hg` or `_p` e.g `openssh-10.3_p1`

[Policy documentation](https://wiki.alpinelinux.org/wiki/APKBUILD_Reference#pkgver)

## Packages

- postgresql18-age
- postgresql-pg_tle

### Installing

1. Download public key
    ```sh
    cd /etc/apk/keys
    sudo wget https://jamesdkelly88.github.io/alpine-apks/jamesdkelly88.rsa.pub
    ```
2. Add to repository list (set version as required)
    ```sh
    echo "https://jamesdkelly88.github.io/alpine-apks/v3.24/postgresql" | sudo tee -a /etc/apk/repositories
    sudo apk update
    ```
3. Install package(s)
    ```sh
    sudo apk add postgresql18-age
    ```