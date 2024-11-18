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
    source = ./rofi;
    recursive = true;
  };

  ".vim/desert256.vim" = { source = ./vim/desert256.vim; };

  ".vimrc" = { source = ./vim/vimrc; };

  # ".gitignore" = { source = ./git/gitignore; };

  # ".gitconfig" = { source = ./git/gitconfig; };

  ".Xdefaults" = { source = ./X/Xdefaults; };

  ".Xresources" = { source = ./X/Xresources; };

  ".urxvt/ext" = {
    source = ./urxvt/ext;
    recursive = true;
  };

  ".config/ev-cmd.toml" = { source = ./ev-cmd/ev-cmd.toml; };
}
