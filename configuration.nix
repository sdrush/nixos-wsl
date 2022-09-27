{ lib, pkgs, config, modulesPath, ... }:

with lib;
let
  nixos-wsl = import ./nixos-wsl;
in
{
  imports = [
    "${modulesPath}/profiles/minimal.nix"
    nixos-wsl.nixosModules.wsl
    # Fetch the nix-ified VSCode Server
    (fetchTarball "https://github.com/msteen/nixos-vscode-server/tarball/master") 
  ];
  # Enable the nix-ified VSCode Server
  services.vscode-server.enable = true;

  nixpkgs.config.allowUnfree = true;
  system.stateVersion = "3";
  wsl = {
    enable = true;
    automountPath = "/mnt";
    defaultUser = "srush";
    startMenuLaunchers = true;

    # Enable integration with Docker Desktop (needs to be installed)
    # docker.enable = true;
  };

  # Enable nix flakes
  nix.package = pkgs.nixFlakes;
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';
  # Enable zsh at the system level and set it as default
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;

  # Set up our user
  users.users.srush = {
    isNormalUser = true;
    home = "/home/srush";
    description = "Shannon Rush";
    extraGroups = [ "wheel" ];
  };
  home-manager.users.srush = { pkgs, ... }: {
    home.packages = with pkgs; [
      fzf
      git
      google-cloud-sdk
      kubectl
      kubectx
      nodejs
      taskwarrior
      tmux
      vim
      wget
      zplug
      zsh
    ];
    programs.zsh.enable = true;
    programs.starship = {
      enable = true;
      enableZshIntegration = true;
      package = pkgs.starship;
      settings = { 
        # Don't print a new line at the start of the prompt
        add_newline = false;
        # Set up our kubernetes prompt
        kubernetes.format = "[$symbol$context\($namespace\)](dimmed green) ";
        kubernetes.disabled = false;
        kubernetes.context_aliases."dev.local.cluster.k8s" = "dev";

        # Set up our taskwarrior inbox count
        custom.task_inbox.description = "Task Inbox Count";
        custom.task_inbox.when = "[ 'task +in +PENDING count' == '0' ] && exit 1 || exit 0 ";
        custom.task_inbox.command = "task +in +PENDING count";
        custom.task_inbox.format = "$symbol[$output]($style) ";
        custom.task_inbox.shell = "['bash', '--noprofile', '--norc'] ";
        custom.task_inbox.symbol = "📥 ";
        custom.task_inbox.style = "bold fg:green";

        # Set up our gcloud prompt
        gcloud.format = "on [$symbol$account(\($project@$region\))]($style) ";
        gcloud.symbol = "☁️ ";
        gcloud.region_aliases.us-central1 = "usc1";
        gcloud.region_aliases.us-east1 = "use1";
        gcloud.region_aliases.us-east4 = "use4";
        gcloud.region_aliases.us-west1 = "usw1";
        gcloud.region_aliases.us-west2 = "usw2";
        gcloud.region_aliases.us-west3 = "usw3";
        gcloud.region_aliases.us-west4 = "usw4";
        gcloud.region_aliases.northamerica-northeast1 = "nane1";
        gcloud.region_aliases.southamerica-east1 = "sae1";
        gcloud.region_aliases.europe-north1 = "eun1";
        gcloud.region_aliases.europe-west1 = "euw1";
        gcloud.region_aliases.europe-west2 = "euw2";
        gcloud.region_aliases.europe-west3 = "euw3";
        gcloud.region_aliases.europe-west4 = "euw4";
        gcloud.region_aliases.europe-west6 = "euw6";
        gcloud.region_aliases.asia-south1 = "as1";
        gcloud.region_aliases.asia-southeast1 = "ase1";
        gcloud.region_aliases.asia-southeast2 = "ase2";
        gcloud.region_aliases.asia-east1 = "ae1";
        gcloud.region_aliases.asia-east2 = "ae2";
        gcloud.region_aliases.asia-northeast1 = "ane1";
        gcloud.region_aliases.asia-northeast2 = "ane2";
        gcloud.region_aliases.asia-northeast3 = "ane3";
      };
    };
  };
}
