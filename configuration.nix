{ config, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  # --- BOOTLOADER (Single Boot) ---
  boot.loader = {
    efi.canTouchEfiVariables = true;
    grub = {
      enable = true;
      device = "nodev";
      efiSupport = true;
      # OSProber removido por não haver Dual Boot
    };
  };

  # --- HARDWARE & DRIVERS (AMD) ---
  hardware.graphics = {
    enable = true;
    enable32Bit = true; # Essencial para Steam
  };
  services.xserver.videoDrivers = [ "amdgpu" ];

  services.udev.extraRules = ''
  # Desativa o touchpad do DualSense como ponteiro de mouse
  ATTRS{name}=="Sony Interactive Entertainment DualSense Wireless Controller Touchpad", ENV{LIBINPUT_IGNORE_DEVICE}="1"
'';

  # --- REDE E LOCALIZAÇÃO ---
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;
  time.timeZone = "America/Sao_Paulo";
  i18n.defaultLocale = "pt_BR.UTF-8";

# --- MONTAGEM DO DISCO DE JOGOS ---
  fileSystems."/backups" = {
    device = "/dev/disk/by-uuid/196fb8f2-86db-43c9-8513-51fce285fd1c";
    fsType = "ext4";
    options = [ "defaults" "nofail" "user" ];
  };

  # --- INTERFACE GRÁFICA (KDE PLASMA 6) ---
  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  # --- TECLADO (ABNT2) ---
  services.xserver.xkb = {
    layout = "br";
    variant = "";
  };

console.keyMap = "br-abnt2";

services.printing.enable = true;

  # --- ÁUDIO (PIPEWIRE) ---
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # --- USUÁRIO ---
  users.users.ambys = {
    isNormalUser = true;
    description = "ambys";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [ kdePackages.kate ];
  };

# --- PROGRAMAS E GAMES ---
  nixpkgs.config.allowUnfree = true;
  
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };

  programs.nix-ld.enable = true;
  programs.gamemode.enable = true;

  programs.firefox.enable = true;
  programs.niri.enable = true;
  services.flatpak.enable = true;

  # Pacotes do sistema
  environment.systemPackages = with pkgs; [
    git
    vim
    vlc
    protonup-qt
    fastfetch
    kdePackages.partitionmanager
  # Criação 3D e 2D
    blender
    krita
  # Gravação de Vídeo
    gpu-screen-recorder
    gpu-screen-recorder-gtk
    obs-studio
  # Edição de Vídeo
    kdePackages.kdenlive
    audacity
    glaxnimate
    ffmpeg
    pavucontrol
  # Jogos
    heroic
    wineWowPackages.staging
    bottles
    winetricks
  # Lutris
    (lutris.override {
      extraPkgs = pkgs: [
        wineWowPackages.staging
        winetricks
        pixman
        libjpeg
        gnutls
        vulkan-loader
      ];
    })
  # Emuladores
    dolphin-emu
    pcsx2
    duckstation
    ppsspp-qt
    melonDS
    skyemu
    flycast
  ];

  environment.sessionVariables = {
    STEAM_EXTRA_COMPAT_TOOLS_PATHS = "/home/ambys/.steam/root/compatibilitytools.d";
  };

  system.stateVersion = "25.11"; 
}
