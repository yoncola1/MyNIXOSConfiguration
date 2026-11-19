{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  boot.loader = {
    efi.canTouchEfiVariables = false;
    systemd-boot.enable = false;
    grub = {
      enable = true;
      device = "nodev";
      efiSupport = true;
      efiInstallAsRemovable = true;
      configurationLimit = 10;
    };
  };
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "nixos";
  networking.networkmanager.enable = true;
  time.timeZone = "Europe/Samara";

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "ru_RU.UTF-8";
    LC_IDENTIFICATION = "ru_RU.UTF-8";
    LC_MEASUREMENT = "ru_RU.UTF-8";
    LC_MONETARY = "ru_RU.UTF-8";
    LC_NAME = "ru_RU.UTF-8";
    LC_NUMERIC = "ru_RU.UTF-8";
    LC_PAPER = "ru_RU.UTF-8";
    LC_TELEPHONE = "ru_RU.UTF-8";
    LC_TIME = "ru_RU.UTF-8";
  };

  systemd.defaultUnit = "graphical.target";

  services.xserver.enable = true;
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = false;
  services.displayManager.sddm.settings.Theme = {
    CursorTheme = "Bibata-Modern-Classic";
    CursorSize = 24;
  };

  programs.dconf.enable = true;
  programs.dconf.profiles.user.databases = [
    {
      settings."org/gnome/desktop/interface" = {
        cursor-theme = "Bibata-Modern-Classic";
        cursor-size = lib.gvariant.mkInt32 24;
      };
    }
  ];

  programs.hyprland.enable = true;
  programs.hyprland.withUWSM = true;
  programs.steam.enable = true;
  programs.fish.enable = true;

  hardware.graphics.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;

  services.power-profiles-daemon.enable = true;
  services.dbus.enable = true;
  security.polkit.enable = true;

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.caskaydia-cove
    material-symbols
    rubik
    noto-fonts
    noto-fonts-color-emoji
  ];

  environment.systemPackages = with pkgs; [
    git
    curl
    jq
    foot
    fish
    fastfetch
    btop
    micro
    thunar
    starship
    wl-clipboard
    cliphist
    hyprpicker
    xdg-user-dirs
    trash-cli
    librewolf
    vesktop
    fastfetch
    opencode
    bibata-cursors
    libxcursor
    (pkgs.writeTextDir "share/icons/default/index.theme" ''
      [Icon Theme]
      Inherits=Bibata-Modern-Classic
    '')
  ];

  environment.pathsToLink = [ "/share/icons" ];

  environment.sessionVariables = {
    XCURSOR_THEME = "Bibata-Modern-Classic";
    XCURSOR_SIZE = "24";
    HYPRCURSOR_THEME = "Bibata-Modern-Classic";
    HYPRCURSOR_SIZE = "24";
  };

  users.users.yoncola = {
    isNormalUser = true;
    description = "yoncola";
    extraGroups = [ "networkmanager" "wheel" "audio" "video" ];
    shell = pkgs.fish;
  };

  nixpkgs.config.allowUnfree = true;

  # Периодически удалять старые поколения и собранные ими store-пути.
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  # Удалять неиспользуемые store-пути, не принадлежащие живым поколениям.
  nix.settings.auto-optimise-store = true;

  system.stateVersion = "26.05";
}
