{ config, pkgs, inputs, lib, ... }:

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
  # Use the Nixpkgs default kernel instead of the very recent latest kernel;
  # this is a safer baseline for building the NVIDIA kernel module.
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.blacklistedKernelModules = [ "nouveau" ];
  boot.kernelParams = [
    "nvidia-drm.modeset=1"
    "nvidia-drm.fbdev=1"
  ];

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
  systemd.services.display-manager = {
    wants = [ "systemd-udev-settle.service" ];
    after = [ "systemd-udev-settle.service" ];
  };

  systemd.services.zapret-discord-youtube = {
    description = "Zapret Discord/YouTube DPI circumvention service";
    wantedBy = [ "multi-user.target" ];
    wants = [ "network-online.target" ];
    after = [ "network-online.target" "NetworkManager-wait-online.service" ];
    path = with pkgs; [
      bash
      coreutils
      curl
      git
      gawk
      gnugrep
      gnused
      iproute2
      nftables
      procps
      util-linux
    ];
    serviceConfig = {
      Type = "simple";
      User = "root";
      WorkingDirectory = "/home/yoncola/zapret-discord-youtube-linux";
      ExecStart = "${pkgs.bash}/bin/bash /home/yoncola/zapret-discord-youtube-linux/service.sh daemon";
      ExecStop = "${pkgs.bash}/bin/bash /home/yoncola/zapret-discord-youtube-linux/service.sh kill";
      Restart = "on-failure";
      RestartSec = 5;
    };
  };

  services.xserver.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  services.displayManager.sddm = {
    enable = true;
    package = pkgs.kdePackages.sddm;
    theme = "sddm-astronaut-theme";
    extraPackages = with pkgs; [
      kdePackages.qtmultimedia
      (sddm-astronaut.override {
        embeddedTheme = "purple_leaves";
      })
    ];
  };
  services.displayManager.sddm.wayland.enable = false;
  services.displayManager.sddm.settings.General.DisplayServer = "x11";
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
  programs.hyprland.withUWSM = false;
  programs.steam = {
    enable = true;
    gamescopeSession.enable = true;
  };
  programs.fish.enable = true;

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  hardware.nvidia = {
    open = true;
    modesetting.enable = true;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };
  
  networking.extraHosts = ''
    18.65.39.105 tr.rbxcdn.com
  '';


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
    pavucontrol
    opencode
    bibata-cursors
    flatpak
    libxcursor
    (sddm-astronaut.override {
      embeddedTheme = "purple_leaves";
    })
    (pkgs.writeTextDir "share/icons/default/index.theme" ''
      [Icon Theme]
      Inherits=Bibata-Modern-Classic
    '')
    inputs.freesmlauncher.packages.${pkgs.system}.freesmlauncher
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

  fileSystems."/mnt/disk" = {
    device = "/dev/disk/by-uuid/d5b8e95c-b27c-44c6-bb4d-3d8e5986fca4";
    fsType = "btrfs";
    options = [
      "defaults"
      "nofail"        # чтобы система загрузилась, если диск отсоединят
      "exec"          # обязательно для запуска игр/Proton с этого диска
      "compress=zstd" # стандартное сжатие btrfs из NixOS Wiki
    ];
  };

  # Удалять неиспользуемые store-пути, не принадлежащие живым поколениям.
  nix.settings.auto-optimise-store = true;

  system.stateVersion = "26.05";
}
