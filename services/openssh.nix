{ ... }:

{
  services.openssh = {
    enable = true;
    allowSFTP = true;
    authorizedKeysInHomedir = true;
    settings.PasswordAuthentication = false;
  };
}
