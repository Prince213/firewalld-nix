{
  autoconf,
  automake,
  docbook-xsl-nons,
  docbook_xml_dtd_42,
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
  kdePackages,
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
    docbook_xml_dtd_42
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

  postPatch = ''
    for file in config/firewall-{applet,config}.desktop.in \
      doc/xml/{firewalld.xml.in,firewalld.dbus.xml,firewall-offline-cmd.xml} \
      src/{firewall-offline-cmd.in,firewall/config/__init__.py.in}
    do
      substituteInPlace $file --replace-fail /usr "$out"
    done

    substituteInPlace src/firewall-applet.in \
      --replace-fail /usr "${kdePackages.systemsettings}"
  '';

  preConfigure = ''
    ./autogen.sh
  '';
}
