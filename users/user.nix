{ name
, extraGroups ? { }
, shell ? (pkgs: pkgs.zsh)
, sessionVariables ? (pkgs: { })
}:
{ pkgs, lib, config, ... }:
let
  cfg = config.users.${name};
in
{
  options.users.${name} = {
    enable = lib.mkEnableOption name;
  };

  config = lib.mkIf cfg.enable
    {
      users.users.${name} = {
        inherit extraGroups;
        shell = shell pkgs;
        isNormalUser = true;
        description = "dan";
      };

      home-manager.users.${name} = {
        home.username = name;
        home.homeDirectory = "/home/${name}";

        fonts.fontconfig = {
          enable = true;
          defaultFonts = {
            monospace = [ "fira-code" ];
            sansSerif = [ "fira-code" ];
            serif = [ "fira-code" ];
          };
        };

        home.sessionVariables = sessionVariables pkgs;

        # This value determines the Home Manager release that your configuration is
        # compatible with. This helps avoid breakage when a new Home Manager release
        # introduces backwards incompatible changes.
        #
        # You should not change this value, even if you update Home Manager. If you do
        # want to update the value, then make sure to first check the Home Manager
        # release notes.
        home.stateVersion = "24.05"; # Please read the comment before changing.
      };
    };
}
