{ config, lib, pkgs, inputs, ... }:

let
  dotsDir = "${config.home.homeDirectory}/.local/share/caelestia";
in
{
  imports = [
    inputs.caelestia-shell.homeManagerModules.default
  ];

  home.username = "yoncola";
  home.homeDirectory = "/home/yoncola";
  home.stateVersion = "26.05";

  programs.caelestia.enable = true;
  programs.caelestia.cli.enable = true;

  home.packages = with pkgs; [
    foot
    fish
    fastfetch
    btop
    micro
    thunar
    starship
    eza
    zoxide
    direnv
    wl-clipboard
    cliphist
    hyprpicker
    xdg-user-dirs
    trash-cli
    ripgrep
    bat
    lazygit
  ];

  programs.starship.enable = true;
  programs.btop.enable = true;
  programs.fastfetch.enable = true;
  programs.foot.enable = true;
  programs.micro.enable = true;

  xdg.enable = true;

  home.activation.cloneCaelestiaDots = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ ! -d "${dotsDir}/.git" ]; then
      $DRY_RUN_CMD mkdir -p "$(dirname "${dotsDir}")"
      $DRY_RUN_CMD ${pkgs.git}/bin/git clone \
        https://github.com/caelestia-dots/caelestia.git \
        "${dotsDir}"
    fi
  '';

  xdg.configFile = {
    "hypr".source = config.lib.file.mkOutOfStoreSymlink "${dotsDir}/hypr";
    "fish".source = config.lib.file.mkOutOfStoreSymlink "${dotsDir}/fish";
    "foot".source = config.lib.file.mkOutOfStoreSymlink "${dotsDir}/foot";
    "fastfetch".source = config.lib.file.mkOutOfStoreSymlink "${dotsDir}/fastfetch";
    "btop".source = config.lib.file.mkOutOfStoreSymlink "${dotsDir}/btop";
    "micro".source = config.lib.file.mkOutOfStoreSymlink "${dotsDir}/micro";
    "Thunar".source = config.lib.file.mkOutOfStoreSymlink "${dotsDir}/thunar";
  };

  home.file.".config/starship.toml".source =
    config.lib.file.mkOutOfStoreSymlink "${dotsDir}/starship.toml";

  home.sessionVariables = {
    CAELESTIA_DOTS = dotsDir;
  };
}
