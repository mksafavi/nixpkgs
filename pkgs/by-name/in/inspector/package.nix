{
  lib,
  stdenv,
  fetchFromGitHub,
  meson,
  ninja,
  gettext,
  wrapGAppsHook4,
  desktop-file-utils,
  gobject-introspection,
  libadwaita,
  python3Packages,
  pciutils,
}:

#stdenv.mkDerivation rec {
python3Packages.buildPythonApplication rec {
  pname = "inspector";
  version = "0.2.0";
  format = "other";

  src = fetchFromGitHub {
    owner = "Nokse22";
    repo = "inspector";
    rev = "v${version}";
    hash = "sha256-tjQCF2Tyv7/NWgrwHu+JPpnLECfDmQS77EVLBt+cRTs=";
  };

  nativeBuildInputs = [
    meson
    ninja
    gettext
    wrapGAppsHook4
    desktop-file-utils
    gobject-introspection
  ];

  buildInputs = [
    libadwaita
  ];

  dependencies = [
    python3Packages.pygobject3
    pciutils
  ];

  strictDeps = true;

  meta = with lib; {
    homepage = "https://github.com/Nokse22/inspector";
    description = "A Gtk4 Libadwaita wrapper for various system info cli commands";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
    mainProgram = "inspector";
    maintainers = with maintainers; [ mksafavi ];
  };
}
