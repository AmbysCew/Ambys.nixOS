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
      vaapiVdpau
      rocmPackages.clr.icd # Necessário para OpenCL (DaVinci Resolve)
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
  users.users.seu_usuario = { # <--- LEMBRE DE TROCAR PELO SEU NOME
    isNormalUser = true;
    description = "Seu Nome";
    extraGroups = [ "networkmanager" "wheel" "video" "audio" "input" ];
    initialPassword = "nixos"; 
  };

  # --- INTERFACE (Niri + SDDM) ---
  programs.niri.enable = true;
  
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true; # SDDM rodando em Wayland
  };

  # Agente de autenticação (Essencial para Noctalia e Niri)
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
    noto-fonts-emoji
    nerd-fonts.jetbrains-mono # Sintaxe atualizada para a versão 24.11
  ];

  # --- GAMING E PERFORMANCE ---
  programs.gamemode.enable = true;
  programs.gamescope.enable = true;
  programs.steam = {
    enable = true;
    gamescopeSession.enable = true; # Corrigido: deve estar dentro de programs.steam
  };

  # --- SOFTWARES E FERRAMENTAS ---
  services.flatpak.enable = true;
  
  environment.systemPackages = with pkgs; [
    # Essenciais Wayland/Niri
    alacritty
    wl-clipboard
    libnotify
    pavucontrol
    xwaylandvideobridge
    polkit_gnome # Adicionado aqui para garantir que o serviço systemd o encontre
    
    # Apps
    firefox
    vlc
    git
    
    # Gaming
    mangohud
    protonup-qt
  ];

  # Manter a versão estável correta
  system.stateVersion = "25.11"; 
}
