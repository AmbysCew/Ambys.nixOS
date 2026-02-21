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

  # --- REDE E LOCALIZAÇÃO ---
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;
  time.timeZone = "America/Sao_Paulo";
  i18n.defaultLocale = "pt_BR.UTF-8";

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

  programs.firefox.enable = true;
  programs.niri.enable = true;
  services.flatpak.enable = true;

  # Pacotes do sistema
  environment.systemPackages = with pkgs; [
    git
    vim
    protonup-qt
    fastfetch
  ];

  environment.sessionVariables = {
    STEAM_EXTRA_COMPAT_TOOLS_PATHS = "/home/ambys/.steam/root/compatibilitytools.d";
  };

  system.stateVersion = "25.11"; 
}
