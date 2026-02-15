{ config, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  # --- SISTEMA E BOOT ---
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  
  time.timeZone = "America/Sao_Paulo";
  i18n.defaultLocale = "pt_BR.UTF-8";
  console.keyMap = "br-abnt2";
  
  services.xserver.xkb = {
    layout = "br";
    variant = "";
  };

  # --- REDE ---
  networking.hostName = "nixos-pc";
  networking.networkmanager.enable = true;

  # --- HARDWARE (AMD GPU) ---
  nixpkgs.config.allowUnfree = true;
  
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      libvdpau-va-gl
      libva-vdpau-driver # <-- CORRIGIDO AQUI (Substituiu o vaapiVdpau)
      rocmPackages.clr.icd 
    ];
  };
  services.xserver.videoDrivers = [ "amdgpu" ];

  # --- ÁUDIO (Pipewire) ---
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # --- USUÁRIO ---
  # Troque 'ambys' pelo nome que você usa se for diferente
  users.users.ambys = { 
    isNormalUser = true;
    description = "Ambys";
    extraGroups = [ "networkmanager" "wheel" "video" "audio" "input" ];
    initialPassword = "nixos"; 
  };

  # --- INTERFACE (Niri + SDDM) ---
  programs.niri.enable = true;
  
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true; 
  };

  # Agente de autenticação
  systemd.user.services.polkit-gnome-authentication-agent-1 = {
    description = "polkit-gnome-authentication-agent-1";
    wantedBy = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
  };

  # --- FONTES ---
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-color-emoji
    nerd-fonts.jetbrains-mono 
  ];

  # --- GAMING E PERFORMANCE ---
  programs.gamemode.enable = true;
  programs.gamescope.enable = true;
  programs.steam = {
    enable = true;
    gamescopeSession.enable = true;
  };

  # --- SOFTWARES E FERRAMENTAS ---
  services.flatpak.enable = true;
  
  environment.systemPackages = with pkgs; [
    alacritty
    wl-clipboard
    libnotify
    pavucontrol
    xwaylandvideobridge
    polkit_gnome 
    
    firefox
    vlc
    git
    
    mangohud
    protonup-qt
  ];

  # Deixe em 24.11 para evitar problemas, a menos que você queira testar a instável
  system.stateVersion = "24.11"; 
}
