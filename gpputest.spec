Name:           gpputest
Version:        1.0.0
Release:        1%{?dist}
Summary:        Scripts to help with creating TDD c++ projects with CppUTest

License:        MIT
URL:            https://guttih.com/public/vault/repo/description/%{name}
Source0:        https://guttih.com/public/vault/repo/assets/release/%{name}-%{version}.tar.gz

BuildArch:      noarch

Requires:       gcc
Requires:       make


%description
**GppUTest RPM package**
Contains scripts to help with creating a new c++ project which includes
unit tests allowing you to develop using a Test Driven Development (TDD).
Note, to be able to use these scripts cpputest needs to be installed.
      See https://cpputest.github.io/ for more details.

%prep
%autosetup

%build

%install
rm -rf $RPM_BUILD_ROOT
mkdir -p %{buildroot}/usr/share/%{name}/{scripts,doc}
install -m755 scripts/* %{buildroot}/usr/share/%{name}/scripts
install -m644 doc/* %{buildroot}/usr/share/%{name}/doc
install -m644 extras/* %{buildroot}/usr/share/%{name}/extras
install -m644 LICENSE %{buildroot}/usr/share/%{name}

%files 
%license LICENSE
/usr/share/%{name}/scripts/*
/usr/share/%{name}/doc/*
/usr/share/%{name}/extras/*
/usr/share/%{name}/LICENSE
%dir /usr/share/%{name}/scripts
%dir /usr/share/%{name}/doc
%dir /usr/share/%{name}/extras
%dir /usr/share/%{name}

%postun
case "$1" in
  0) # last one out put out the lights
    rm -f /usr/bin/gpputest-*.sh
  ;;
esac

%post
ln -s /usr/share/gpputest/scripts/gpputest-install.sh /usr/bin/gpputest-install.sh
ln -s /usr/share/gpputest/scripts/gpputest-new.sh /usr/bin/gpputest-new.sh
ln -s /usr/share/gpputest/scripts/gpputest-setupTest.sh /usr/bin/gpputest-setupTest.sh
echo
echo -e "Installed to /usr/share/%{name}\n"
echo "Available command are:"
echo -en '\033[01;37m'
find /usr/bin -name gpputest-*.sh  -printf "  %f\n"
echo -e '\033[0m'
echo -e "Package information: /usr/share/gpputest/doc/README.md\n"
echo -e 'Further information about this package at: https://guttih.com/public/vault/repo/description/gpputest'



%changelog
* Tue Jun 14 2022 guttih <guttih@gmail.com> - 1.0.0-1
- Initial build
