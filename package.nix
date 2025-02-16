{
  autoconf,
  automake,
  docbook-xsl-nons,
  fetchFromGitHub,
  glib,
  intltool,
  ipset,
  iptables,
  kmod,
  libxml2,
  libxslt,
  pkg-config,
  python3,
  stdenv,
  sysctl,
}:

stdenv.mkDerivation rec {
  pname = "firewalld";
  version = "2.3.0";

  src = fetchFromGitHub {
    owner = "firewalld";
    repo = "firewalld";
    rev = "v${version}";
    hash = "sha256-ubE1zMIOcdg2+mgXsk6brCZxS1XkvJYwVY3E+UXIIiU=";
  };

  nativeBuildInputs = [
    autoconf
    automake
    docbook-xsl-nons
    intltool
    ipset
    iptables
    kmod
    libxml2
    libxslt
    pkg-config
    python3
    sysctl
  ];

  buildInputs = [
    glib
    ipset
    iptables
    kmod
    python3
    sysctl
  ];

  patches = [
    ./respect-xml-catalog-files-var.patch
  ];

  preConfigure = ''
    ./autogen.sh
  '';
}
