{ }:
let src = name: ../config/${name};
in {
  ".config/i3blocks.conf" = {
    source = src "i3blocks/i3blocks.conf";
  };

  ".config/picom.conf" = {
    source = src "picom/picom.conf";
  };

  ".config/rofi" = {
    source = builtins.fetchGit {
      shallow = true;
      url = "https://github.com/adi1090x/rofi.git";
      rev = "86e6875d9e89ea3cf95c450cef6497d52afceefe";
    };
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

  ".config/i3blocks-contrib" = {
    source = builtins.fetchGit {
      url = "https://github.com/vivien/i3blocks-contrib.git";
      rev = "9d66d81da8d521941a349da26457f4965fd6fcbd";
      shallow = true;
    };
    recursive = true;
  };
}
