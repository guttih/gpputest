Name:           gpputest
Version:        1.0.0
Release:        1%{?dist}
Summary:        Scripts to help with creating TDD c++ projects with CppUTest

License:        MIT
URL:            https://guttih.com/public/vault/repo/description/%{name}
Source0:        https://guttih.com/public/vault/repo/assets/release/%{name}-%{version}.tar.gz

Requires:       cpputest

BuildArch:      noarch

%description
**GppUTest RPM package**
Contains scripts to help with creating a new c++ project which includes
unit tests allowing you to develop using a Test Driven Development (TDD).

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
%dir /usr/share/%{name}
/usr/share/%{name}/scripts/*
/usr/share/%{name}/doc/*
/usr/share/%{name}/LICENSE



%changelog
* Tue Jun 14 2022 guttih <guttih@gmail.com> - 1.0.0-1
- Initial build
