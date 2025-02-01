{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    ollama
  ];

  services.ollama = {
    enabe = true;
  };
}
