# gpputest Development

My notes about developing this repository

## Requirements
In order to use these rpm dev tools you will need to install these packages

```
dnf -y install rpmdevtools rpmlint tree createrepo
```
## Further reading
 - https://rpm.org/documentation.html
 - https://docs.fedoraproject.org/en-US/package-maintainers/Packaging_Tutorial_GNU_Hello/
 - http://ftp.rpm.org/max-rpm/s1-rpm-inside-scripts.html


## Steps to create a new rpm package automatically
```
build/build.sh
```
## Steps to create a new rpm package manually

1. Prepare the files you want to distribute
    - Change directory into root of this repository in these instruction we will assume the repository has been cloned to the `~/repos/gpputest` directory
        ```
        cd ~/repos/gpputest
        ```

    - Copy the source files to a new directory 
        ```
        mkdir -p ~/gpputest-1.0.0 && cp -R src/* ~/gpputest-1.0.0 && tree  ~/gpputest-1.0.0
        ```
    - Build a tar file 
        ```
        tar -czvf ~/gpputest-1.0.0.tar.gz ~/gpputest-1.0.0
        ```


1. Create a RPM directory tree structure with one of this command:
    - In home directory `~/rpmbuild`.
        ```
        rpmdev-setuptree
        ```
2. Create a spec file for the package and edit, and copy it into `~/rpmbuild`
    - Create and edit the spec
        ```
        rpmdev-newspec gpputest
        vi gpputest.spec
        ```
3. Copy files to rpmbuild tree
    ```
    cp ~/gpputest-1.0.0.tar.gz ~/rpmbuild/SOURCES/
    cp gpputest.spec ~/rpmbuild/SPECS/
    ```
4. Test if spec file is ok
    ```
    rpmlint ~/rpmbuild/SPECS/gpputest.spec
    ```
    If an *W: invalid-url Source0:* error occurs, just create that path on your server and try again
5. Build the package
    ```
    rpmbuild -bb -vv ~/rpmbuild/SPECS/$PACKAGE.spec

    ```

6. Deploy the package to the web server
    ```
    scp ~/rpmbuild/SOURCES/* username@guttih.com:/var/www/web-guttih/public/vault/repo/assets/release;

    ```

## Other notes
    - **Clear chase** ``

## Installing the cpputest by building source

Get the [cpputest repo ](https://github.com/cpputest/cpputest)

1. Clone git repo and install required packages
    ```
    sudo dnf install xcb-util-wm  xcb-util-image xcb-util-keysyms xcb-util-renderutil
   mkdir -p ~/repos
   cd ~/repos
   git clone  https://github.com/cpputest/cpputest.git
   cd cpputest
    ```
2. 
    ```
    echo stuff
    
    ```