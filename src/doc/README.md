# GppUTest README.md
Scripts to help with creating TDD c++ projects with CppUTest

**gpputest** is a installable package for Red Hat-Based Linux distros (like: *Red Hat*, *Fedora*, *Centos* and *Rocky linux*).  The package has been tested on *Rocky Linux 8.6 (Green Obsidian)*

                    
Click [Online info](https://guttih.com/public/vault/repo/description/gpputest) get get more information about this package.

## Requirements
- [CppUTest]
- [lcov]
- [QT]
  
### Installing qt

You need to visit [qt download page] and download the qt installer. In order to make the installer run on a fresh Rocky linux 8.6 in needed to install these packages:

1. First I installed these packages
    ```
    sudo dnf install gpputest xcb-util-wm  libxcb-image xcb-util-image xcb-util-keysyms xcb-util-renderutil
    ```
2. Then I installed this package group
    ```
    sudo dnf groupinstall "Development Tools"
    ```
3. Finally I Ran the QT installer
    1. Download the installer from [qt download page]
    2. Make the downloaded installer runnable.
        - The installer will be named something like `qt-unified-linux-x64-4.4.0-online.run`
    3. Run the installer

## CPPUTest example project

A CppUTest skeleton project I created to use as a template to easily start a 
new Test driven development project in C++ using make

#### Requirements

In order to be able to build this project you need to have installed [CppUTest] and [lcov]
and you will probably need to install the development tools to use gcc and make.
```
sudo dnf groupinstall "Development Tools"
```

###### installing requirements

1. lcov (Code coverage)
    ```
    sudo dnf -y install lcov
    ```

2. CppUTest (Unit test framework)
    ```
    mkdir ~/repos
    cd ~/repos
    git clone https://github.com/cpputest/cpputest.git
    cd ~/repos/cpputest/cpputest_build
    autoreconf .. -i
    ../configure
    make
    make install

    ```

###### Getting this repository 

After creating a C++ TDD project with scripts `gpputest-newQtProject.sh` and `gpputest-install.sh`

- you can give the following make commands:
    - `make  test` : build and run the tests
    - `make  all` : build the app and run tests
    - `make allcov` : build the app and run tests and launch code coverage report in a web browser
    - `make  coverage` : create a code coverage report.
    - `make  clean` : remove all build-, object-, and code coverage files
    - `make  clean_coverage` : remove all code coverage files
    - `make main` : build the app which you can run with command  `./app`

#### references 
- [CppUTest] and the repository at [CppUTest repo]
- [lcov] and the repository at [lcov repo]
- [sparkpost blog getting-started-cpputest](https://www.sparkpost.com/blog/getting-started-cpputest/)

###### further to read
 - [Google test Code Coverage Report ](https://medium.com/@naveen.maltesh/generating-code-coverage-report-using-gnu-gcov-lcov-ee54a4de3f11)



[CppUTest]: https://cpputest.github.io/
[CppUTest repo]: https://github.com/cpputest/cpputest
[lcov]: http://ltp.sourceforge.net/coverage/lcov.php
[lcov repo]: https://github.com/linux-test-project/lcov
[QT]: https://www.qt.io
[QT download page]: https://www.qt.io/download