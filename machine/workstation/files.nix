{ }:
let src = name: ../../config/${name};
in {
  ".config/g600" = {
    source = src "g600";
    recursive = true;
  };

  ".config/i3" = {
    source = src "i3";
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
    source = src "rofi";
    recursive = true;
  };

  ".vim/desert256.vim" = { source = src "vim/desert256.vim"; };

  ".vimrc" = { source = src "./vim/vimrc"; };

  ".Xdefaults" = { source = src "./X/Xdefaults"; };

  ".Xresources" = { source = src "./X/Xresources"; };

  ".urxvt/ext" = {
    source = src "urxvt/ext";
    recursive = true;
  };

  ".config/ev-cmd.toml" = { source = src "ev-cmd/ev-cmd.toml"; };
}
