final: prev: {
  qemu = prev.qemu.overrideAttrs (_: rec {
    version = "10.1.0";
    src = prev.fetchurl {
      url = "https://download.qemu.org/qemu-10.1.0.tar.xz";
      hash = "sha256-4FFzSbUMpz6+wvqFsGBQ1cRjymXHOIM72PwfFfGAvlE=";
    };
  });
}
