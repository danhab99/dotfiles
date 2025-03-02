{ lib, config, ... }:

with lib;
let cfg = config.modules.zoxide;

in {
  options.modules.zoxide = { enable = mkEnableOption "zoxide"; };
  config = mkIf cfg.enable {
    programs.zoxide = {
      enable = true;
      enableZshIntegration = true;
    };
  };
}
