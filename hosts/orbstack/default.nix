{ pkgs, modulesPath, ... }:
{
  imports = [
    "${modulesPath}/virtualisation/lxc-container.nix"
    ./home.nix
    ./orbstack.nix
  ];

  networking.hostName = "orbstack";
  nixpkgs.hostPlatform = "aarch64-linux";

  # Random stuff I want on orbie-arm
  environment.systemPackages = with pkgs; [
    ghostty.terminfo
  ];

  security.sudo.wheelNeedsPassword = false;
  users.users.marvin = {
    uid = 502;
    linger = true;
    extraGroups = [
      "wheel"
      "orbstack"
    ];

    # simulate isNormalUser, but with an arbitrary UID
    isSystemUser = true;
    group = "users";
    createHome = true;
    home = "/home/marvin";
    homeMode = "700";
    useDefaultShell = true;
  };

  # This being `true` leads to a few nasty bugs, change at your own risk!
  users.mutableUsers = false;

  # dbus-broker has known startup failures on aarch64 LXC (nixpkgs #302771).
  # Classic dbus also avoids broker→dbus transition hangs during rebuild switch.
  services.dbus.implementation = "dbus";

  time.timeZone = "America/New_York";

  networking = {
    dhcpcd.enable = false;
    useDHCP = false;
    useHostResolvConf = false;
  };

  systemd.network = {
    enable = true;
    networks."50-eth0" = {
      matchConfig.Name = "eth0";
      networkConfig = {
        DHCP = "ipv4";
        IPv6AcceptRA = true;
      };
      linkConfig.RequiredForOnline = "routable";
    };
  };

  # Extra certificates from OrbStack.
  security.pki.certificates = [
    ''
            -----BEGIN CERTIFICATE-----
      MIICDDCCAbKgAwIBAgIQeC3EqXiMUdKA1R9zLRE57TAKBggqhkjOPQQDAjBmMR0w
      GwYDVQQKExRPcmJTdGFjayBEZXZlbG9wbWVudDEeMBwGA1UECwwVQ29udGFpbmVy
      cyAmIFNlcnZpY2VzMSUwIwYDVQQDExxPcmJTdGFjayBEZXZlbG9wbWVudCBSb290
      IENBMB4XDTI2MDUwNTIxNTUzMVoXDTM2MDUwNTIxNTUzMVowZjEdMBsGA1UEChMU
      T3JiU3RhY2sgRGV2ZWxvcG1lbnQxHjAcBgNVBAsMFUNvbnRhaW5lcnMgJiBTZXJ2
      aWNlczElMCMGA1UEAxMcT3JiU3RhY2sgRGV2ZWxvcG1lbnQgUm9vdCBDQTBZMBMG
      ByqGSM49AgEGCCqGSM49AwEHA0IABCdsdOBJ9OR1+gQpgPt9JeyditWJUO+QIe/1
      stW5LvIYwUKMVwb/Acu+AaYZM6ZV87qlgVFvra/Npqme4nul7rGjQjBAMA4GA1Ud
      DwEB/wQEAwIBBjAPBgNVHRMBAf8EBTADAQH/MB0GA1UdDgQWBBRQgOIk6ZGD2zbg
      MU4a402GGEOTFTAKBggqhkjOPQQDAgNIADBFAiBA7pA1/BH0lkvG7QYWOVu4CEQJ
      AqFMZAjbOYWPgflgGAIhANRduVqK9wPklX4OGwLbnGbEX8q9bWmdyQrU/QcqrurA
      -----END CERTIFICATE-----

    ''
  ];

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.11";
}
