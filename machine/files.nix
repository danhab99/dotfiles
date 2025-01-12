{ }:
let
  config = dir: name: {
    source = ../config/${name};
    recursive = dir;
  };
  configFile = config false;
  # configDir = config true;
  github = { repo, rev }: {
    source = builtins.fetchGit {
      shallow = true;
      url = "https://github.com/${repo}";
      inherit rev;
    };
    recursive = true;
  };
in {
  ".config/rofi" = github {
    repo = "adi1090x/rofi.git";
    rev = "86e6875d9e89ea3cf95c450cef6497d52afceefe";
  };

  ".urxvt/ext" = github {
    repo = "simmel/urxvt-resize-font.git";
    rev = "b5935806f159594f516da9b4c88bf1f3e5225cfd";
  };

  ".config/i3blocks-contrib" = github {
    repo = "vivien/i3blocks-contrib.git";
    rev = "9d66d81da8d521941a349da26457f4965fd6fcbd";
  };

  ".config/i3blocks.conf" = configFile "i3blocks/i3blocks.conf";
  ".vim/desert256.vim" = configFile "vim/desert256.vim";
  ".vimrc" = configFile "./vim/vimrc";
  ".Xdefaults" = configFile "./X/Xdefaults";
  ".Xresources" = configFile "./X/Xresources";
}
