# https://github.com/notusknot/dotfiles-nix/blob/e64745a1541d8acd0b1ed548827bd5c59d2140ac/modules/template.nix
{ pkgs, lib, config, ... }:

lib.mkModule {
  name = "font";
  
  output = { ... }: {
    nixos = {
      fonts.packages = with pkgs.nerd-fonts; [
        # _0xproto
        # _3270
        agave
        anonymice
        arimo
        aurulent-sans-mono
        bigblue-terminal
        bitstream-vera-sans-mono
        blex-mono
        caskaydia-cove
        caskaydia-mono
        code-new-roman
        comic-shanns-mono
        commit-mono
        cousine
        d2coding
        daddy-time-mono
        dejavu-sans-mono
        departure-mono
        droid-sans-mono
        envy-code-r
        fantasque-sans-mono
        fira-code
        fira-mono
        geist-mono
        go-mono
        gohufont
        hack
        hasklug
        heavy-data
        hurmit
        im-writing
        inconsolata
        inconsolata-go
        inconsolata-lgc
        intone-mono
        iosevka
        iosevka-term
        iosevka-term-slab
        jetbrains-mono
        lekton
        liberation
        lilex
        martian-mono
        meslo-lg
        monaspace
        monofur
        monoid
        mononoki
        mplus
        noto
        open-dyslexic
        overpass
        profont
        proggy-clean-tt
        recursive-mono
        roboto-mono
        sauce-code-pro
        shure-tech-mono
        space-mono
        symbols-only
        terminess-ttf
        tinos
        ubuntu
        ubuntu-mono
        ubuntu-sans
        victor-mono
        zed-mono
      ];
      # fonts.packages = builtins.attrNames pkgs.nerd-fonts;
    };
  };
}
