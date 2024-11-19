# postgresql.nix
{ config, pkgs, ... }:

{
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_15;
    
    # Enable network listening
    enableTCPIP = true;
    
    # Ensure databases exist
    ensureDatabases = [ "alice" ];
    
    # Authentication configuration
    authentication = pkgs.lib.mkOverride 10 ''
      # TYPE  DATABASE        USER            ADDRESS                 METHOD
      local   all             all                                     trust
      host    all             all             127.0.0.1/32           trust
      host    all             all             ::1/128                trust
    '';

    # Initial database setup
    initialScript = pkgs.writeText "postgres-init" ''
      CREATE DATABASE alice;
      GRANT ALL PRIVILEGES ON DATABASE alice TO alice;
      ALTER USER alice WITH SUPERUSER;
    '';
  };
}
