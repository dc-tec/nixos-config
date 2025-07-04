{
  config,
  lib,
  ...
}:
{
  config = lib.mkIf config.dc-tec.gpg.enable {
    # Darwin-specific GPG configuration
    home-manager.users.${config.dc-tec.user.name} = {
      # Override GPG agent config for Darwin
      services.gpg-agent.extraConfig = lib.mkForce ''
        pinentry-program /opt/homebrew/bin/pinentry-mac
      '';
    };
  };
}
