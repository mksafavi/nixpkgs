{
  lib,
  stdenv,
  fetchFromGitHub,
  pkg-config,
  gcc-arm-embedded,
  readline,
  bzip2,
  openssl,
  jansson,
  gd,
  whereami,
  lua,
  lz4,
  udevCheckHook,
  withGui ? true,
  wrapQtAppsHook,
  qtbase,
  withPython ? true,
  python3,
  withBlueshark ? false,
  bluez5,
  withGeneric ? false,
  withSmall ? false,
  withoutFunctions ? [ ],
  hardwarePlatform ? if withGeneric then "PM3GENERIC" else "PM3RDV4",
  hardwarePlatformExtras ? lib.optionalString withBlueshark "BTADDON",
  standalone ? "LF_SAMYRUN",
}:
assert withBlueshark -> stdenv.hostPlatform.isLinux;
stdenv.mkDerivation (finalAttrs: {
  pname = "proxmark3";
  version = "4.20469";

  src = fetchFromGitHub {
    owner = "RfidResearchGroup";
    repo = "proxmark3";
    rev = "v${finalAttrs.version}";
    hash = "sha256-Z87YCuNWQ66FTAq7qXUYKI25BEWrXD+YK0GczDmWc9A=";
  };

  patches = [
    # Don't check for DISPLAY env variable on Darwin. pm3 uses this to test if
    # XQuartz is installed, however it is not actually required for GUI features
    ./darwin-always-gui.patch
  ];

  postPatch = ''
    # Remove hardcoded paths on Darwin
    substituteInPlace Makefile.defs \
      --replace-fail "/usr/bin/ar" "ar" \
      --replace-fail "/usr/bin/ranlib" "ranlib"
    # Replace hardcoded path to libwhereami
    # Replace darwin sed syntax with gnused
    substituteInPlace client/Makefile \
      --replace-fail "/usr/include/whereami.h" "${whereami}/include/whereami.h" \
      --replace-fail "sed -E -i '''" "sed -i"
  '';

  nativeBuildInputs = [
    pkg-config
    gcc-arm-embedded
    udevCheckHook
  ]
  ++ lib.optional withGui wrapQtAppsHook;
  buildInputs = [
    readline
    bzip2
    openssl
    jansson
    gd
    lz4
    whereami
    lua
  ]
  ++ lib.optional withGui qtbase
  ++ lib.optional withPython python3
  ++ lib.optional withBlueshark bluez5;

  makeFlags = [
    "PREFIX=${placeholder "out"}"
    "UDEV_PREFIX=${placeholder "out"}/etc/udev/rules.d"
    "PLATFORM=${hardwarePlatform}"
    "PLATFORM_EXTRAS=${hardwarePlatformExtras}"
    "STANDALONE=${standalone}"
    "USE_BREW=0"
  ]
  ++ lib.optional withSmall "PLATFORM_SIZE=256"
  ++ map (x: "SKIP_${x}=1") withoutFunctions;
  enableParallelBuilding = true;

  doInstallCheck = true;

  meta = with lib; {
    description = "Client for proxmark3, powerful general purpose RFID tool";
    homepage = "https://github.com/RfidResearchGroup/proxmark3";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [
      nyanotech
      emilytrau
    ];
    platforms = platforms.unix;
    mainProgram = "pm3";
  };
})
