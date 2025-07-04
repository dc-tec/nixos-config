{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.dc-tec.gpg = {
    enable = lib.mkEnableOption "GPG key management with SOPS";
  };

  config = lib.mkIf config.dc-tec.gpg.enable {
    # Add GPG directory to persistent directories on Linux systems with persistence
    dc-tec.core.zfs = lib.mkIf (config.dc-tec.isLinux && config.dc-tec.persistence.enable) {
      homeDataLinks = [
        {
          directory = ".gnupg";
          mode = "0700";
        }
      ];
    };

    # Add GPG package for Linux systems (Darwin gets it from homebrew)
    environment.systemPackages = lib.optionals config.dc-tec.isLinux [
      pkgs.gnupg
    ];

    home-manager.users.${config.dc-tec.user.name} = {
      programs.gpg = {
        enable = true;
        settings = {
          trust-model = "tofu+pgp";
          default-key = config.dc-tec.user.gpgKey;
          armor = true;
          with-fingerprint = true;
          keyid-format = "0xlong";
          list-options = "show-uid-validity";
          verify-options = "show-uid-validity";
          personal-digest-preferences = "SHA512";
          cert-digest-algo = "SHA512";
          default-preference-list = "SHA512 SHA384 SHA256 SHA224 AES256 AES192 AES CAST5 ZLIB BZIP2 ZIP Uncompressed";
        };
      };

      services.gpg-agent = {
        enable = true;
        enableZshIntegration = true;
        pinentry.package = 
          if config.dc-tec.isDarwin then 
            null 
          else if config.dc-tec.graphical.enable or false then 
            pkgs.pinentry-gtk2 
          else 
            pkgs.pinentry-curses;
        extraConfig = lib.optionalString config.dc-tec.isDarwin ''
          pinentry-program /opt/homebrew/bin/pinentry-mac
        '' + lib.optionalString (config.dc-tec.isLinux && !(config.dc-tec.graphical.enable or false)) ''
          pinentry-program ${pkgs.pinentry-curses}/bin/pinentry-curses
        '';
      };

      # Create activation script to import GPG keys
      home.activation.importGpgKeys = ''
        if [ -f "/run/secrets/gpg/private_key" ] && [ -f "/run/secrets/gpg/public_key" ]; then
          # Use appropriate GPG path for the platform
          GPG_CMD="${if config.dc-tec.isDarwin then "/opt/homebrew/bin/gpg" else "${pkgs.gnupg}/bin/gpg"}"
          
          # Check if our key is already imported
          if ! $GPG_CMD --list-secret-keys "${config.dc-tec.user.gpgKey}" >/dev/null 2>&1; then
            echo "Importing GPG keys..."
            
            # Import public key first
            $GPG_CMD --import "/run/secrets/gpg/public_key" 2>/dev/null || true
            
            # Import private key
            $GPG_CMD --import "/run/secrets/gpg/private_key" 2>/dev/null || true
            
            # Import trust database if it exists
            if [ -f "/run/secrets/gpg/trust_db" ]; then
              $GPG_CMD --import-ownertrust "/run/secrets/gpg/trust_db" 2>/dev/null || true
            fi
            
            # Set ultimate trust for our key
            echo "${config.dc-tec.user.gpgKey}:6:" | $GPG_CMD --import-ownertrust 2>/dev/null || true
            
            # Start GPG agent if not running (use appropriate path)
            GPG_AGENT_CMD="${if config.dc-tec.isDarwin then "/opt/homebrew/bin/gpg-agent" else "${pkgs.gnupg}/bin/gpg-agent"}"
            $GPG_AGENT_CMD --daemon 2>/dev/null || true
            
            echo "GPG keys imported successfully"
          else
            echo "GPG keys already imported, skipping"
          fi
        else
          echo "GPG key files not found, skipping import"
        fi
      '';
    };
  };
} 