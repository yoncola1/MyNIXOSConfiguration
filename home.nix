{ config, lib, pkgs, inputs, ... }:

let
  dotsDir = "${config.home.homeDirectory}/.local/share/caelestia";
  dotsConfig = name: "${dotsDir}/${name}";
in
{
  imports = [
    inputs.caelestia-shell.homeManagerModules.default
  ];

  home.username = "yoncola";
  home.homeDirectory = "/home/yoncola";
  home.stateVersion = "26.05";
  home.backupFileExtension = "backup";

  programs.caelestia = {
    enable = true;
    systemd.enable = false;
    cli.enable = true;
  };

  home.packages = with pkgs; [
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

  # Fish configuration is provided by the Caelestia dotfiles directory below.
  # Do not enable programs.fish here: Home Manager would also manage config.fish.

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
    "hypr".source = config.lib.file.mkOutOfStoreSymlink (dotsConfig "hypr");
    "fish".source = config.lib.file.mkOutOfStoreSymlink (dotsConfig "fish");
    "foot".source = config.lib.file.mkOutOfStoreSymlink (dotsConfig "foot");
    "fastfetch".source = config.lib.file.mkOutOfStoreSymlink (dotsConfig "fastfetch");
    "btop".source = config.lib.file.mkOutOfStoreSymlink (dotsConfig "btop");

    # Home Manager's micro module also creates .config/micro/settings.json.
    # Use one relative tree entry to avoid overlapping management of that path.
    "micro" = {
      source = config.lib.file.mkOutOfStoreSymlink (dotsConfig "micro");
      recursive = false;
    };

    "Thunar".source = config.lib.file.mkOutOfStoreSymlink (dotsConfig "thunar");
  };

  home.file.".config/starship.toml".source =
    config.lib.file.mkOutOfStoreSymlink (dotsConfig "starship.toml");

  home.sessionVariables.CAELESTIA_DOTS = dotsDir;
}
