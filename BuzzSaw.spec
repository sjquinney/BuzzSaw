Name:           @LCFG_FULLNAME@
Summary:        @LCFG_ABSTRACT@
Version:        @LCFG_VERSION@
Release:        @LCFG_RELEASE@
Packager:       @LCFG_AUTHOR@
License:        @LCFG_LICENSE@
Group:          LCFG/Utilities
Source:         @LCFG_TARNAME@
BuildArch:	noarch
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)

Requires:       perl(:MODULE_COMPAT_%(eval "`%{__perl} -V:version`"; echo $version))
BuildRequires:  perl >= 1:5.6.1
BuildRequires:  perl(Module::Build), perl(Test::More) >= 0.87
BuildRequires:  perl(DBIx::Class), perl(DBD::Pg)
BuildRequires:  perl(DateTime), perl(DateTime::Format::Pg)
BuildRequires:  perl(IO::Uncompress::Bunzip2), perl(IO::Uncompress::Gunzip)
BuildRequires:  perl(Digest::SHA)
BuildRequires:  perl(File::Find::Rule)
BuildRequires:  perl(Moose)
BuildRequires:  perl(MooseX::Types), perl(MooseX::Log::Log4perl)
BuildRequires:  perl(MooseX::SimpleConfig), perl(MooseX::App::Cmd)
BuildRequires:  perl(Readonly)
BuildRequires:  perl(UNIVERSAL::require)
BuildRequires:  perl(YAML::Syck)

# These are Moose roles so don't get automatically identified.
Requires:       perl(MooseX::Log::Log4perl), perl(MooseX::SimpleConfig)
Requires:       perl(MooseX::Getopt), perl(MooseX::App::Cmd)
# DBIx::Class loads these dynamically
Requires:       perl(DBD::Pg), perl(DateTime::Format::Pg)

%description
@LCFG_ABSTRACT@

%prep
%setup -q -n @LCFG_NAME@-%{version}

%build
%{__perl} Build.PL installdirs=vendor
./Build

%install
rm -rf $RPM_BUILD_ROOT

./Build install destdir=$RPM_BUILD_ROOT create_packlist=0
find $RPM_BUILD_ROOT -depth -type d -exec rmdir {} 2>/dev/null \;

%{_fixperms} $RPM_BUILD_ROOT/*

%check
./Build test

%files
%defattr(-,root,root)
%doc ChangeLog
%doc %{_mandir}/man1/*
%doc %{_mandir}/man3/*
%{perl_vendorlib}/BuzzSaw
%{perl_vendorlib}/App/*
%{_bindir}/*
/usr/share/buzzsaw/

%clean
rm -rf $RPM_BUILD_ROOT

%changelog
@LCFG_CHANGELOG@
