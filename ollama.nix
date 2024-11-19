# ollama.nix
{ config, pkgs, ... }:

{
  # Enable Docker (required for Ollama)
  virtualisation.docker.enable = true;

  # Create systemd service for Ollama
  systemd.services.ollama = {
    description = "Ollama Service";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    
    serviceConfig = {
      ExecStart = "${pkgs.ollama}/bin/ollama serve";
      Restart = "always";
      User = "alice";
      Group = "docker";
      
      # Security settings
      ProtectSystem = "full";
      PrivateTmp = true;
      NoNewPrivileges = true;
    };
  };

  # Enable the Ollama service
  systemd.services.ollama.enable = true;
}
