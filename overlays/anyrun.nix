final: prev: {
  anyrun = prev.anyrun.overrideAttrs (_: rec {
    version = "25.9.0.pre-release.1-unstable-2025-08-19";

    src = prev.fetchFromGitHub {
      owner = "anyrun-org";
      repo = "anyrun";
      rev = "af1ffe4f17921825ff2a773995604dce2b2df3cd";
      hash = "sha256-PKxVhfjd2AlzTopuVEx5DJMC4R7LnM5NIoMmirKMsKI=";
    };

    cargoDeps = final.rustPlatform.fetchCargoVendor {
      inherit src;
      hash = "sha256-KpAnfytTtCJunhpk9exv8LYtF8mKDGFUUbsPP47M+Kk=";
    };
  });
}
