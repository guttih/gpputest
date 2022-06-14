# gpputest Development

My notes about developing this repository

## Requirements
In order to use these rpm dev tools you will need to install these packages

```
dnf -y install rpmdevtools rpmlint tree
```
## Further reading
 - https://rpm.org/documentation.html


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
        *Alternatively you can create at different location* `mkdir -p ~/gpputest/rpmbuild/{BUILD,RPMS,SOURCES,SPECS,SRPMS}`
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