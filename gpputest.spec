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
install -m644 scripts/* %{buildroot}/usr/share/%{name}/scripts
install -m644 doc/* %{buildroot}/usr/share/%{name}/doc
install -m644 LICENSE %{buildroot}/usr/share/%{name}

%files 
%license LICENSE
/usr/share/%{name}/scripts/*
/usr/share/%{name}/doc/*
/usr/share/%{name}/LICENSE
%dir /usr/share/%{name}/scripts
%dir /usr/share/%{name}/doc
%dir /usr/share/%{name}

%post
echo
echo "Installed to /usr/share/%{name}"
echo -e '\033[01;37m'
echo "Available command are:"
find "/usr/share/gpputest/scripts" -type f  -exec echo {}  \;
echo -e '\033[0m'



%changelog
* Tue Jun 14 2022 guttih <guttih@gmail.com> - 1.0.0-1
- Initial build
