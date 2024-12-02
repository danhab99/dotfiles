{ }:

{
  ".config/g600" = {
    source = ./g600;
    recursive = true;
  };

  ".config/i3" = {
    source = ./i3;
    recursive = true;
  };

  # ".config/rofi" = {
  #   source = builtins.fetchGit {
  #     shallow = true;
  #     url = "https://github.com/adi1090x/rofi.git";
  #     rev = "86e6875d9e89ea3cf95c450cef6497d52afceefe";
  #   };
  #   recursive = true;
  # };

  ".config/rofi" = {
    source = ../../config/rofi;
    recursive = true;
  };

  ".vim/desert256.vim" = { source = ../../config/vim/desert256.vim; };

  ".vimrc" = { source = ../../config/vim/vimrc; };

  ".Xdefaults" = { source = ../../config/X/Xdefaults; };

  ".Xresources" = { source = ../../config/X/Xresources; };

  ".urxvt/ext" = {
    source = ./urxvt/ext;
    recursive = true;
  };

  ".config/ev-cmd.toml" = { source = ../../config/ev-cmd/ev-cmd.toml; };
}
