{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # Apple `sed` makes C+P unverified shell scripts from stackoverflow hard
    gnused
  ];
}
