Summary: Bash Library for Indolent Programmers
Name: blip
Version: 0.01
Release: 1%{?dist}
License: MIT
Group: Development/Library
BuildArch: noarch
Source0: %{name}-%{version}.tar.gz
URL: https://nicolaw.uk/blip
Packager: Nicola Worthington <nicolaw@tfb.net>

%description
Common functions library for Bash 4.

%clean
rm -rf --one-file-system --preserve-root "%{buildroot}"

%prep
%setup -q

%install
make install DESTDIR="%{buildroot}" prefix=/usr

%files
/usr/lib/blip.bash
/usr/share/man/man1/blip.1.gz

