MODE=$1

function track() {
  ORIGINAL_LOCATION=$1
  DOTFILES_LOCATION=$2/_$(basename $ORIGINAL_LOCATION)_

  case $MODE in
    "update")
      echo "Backing up $ORIGINAL_LOCATION to $DOTFILES_LOCATION"
      mkdir -p ./$(dirname $DOTFILES_LOCATION)
      rclone copy --exclude-from .dotfilesignore -P $ORIGINAL_LOCATION $DOTFILES_LOCATION
      ;;
    "install")
      echo "Putting $DOTFILES_LOCATION in $ORIGINAL_LOCATION"
      mkdir -p ./$(dirname $DOTFILES_LOCATION)
      rclone copy -P $DOTFILES_LOCATION/* ${INSTALL_ORIGIN:=/}/$ORIGINAL_LOCATION
      ;;
    "list")
      echo "Tracking $ORIGINAL_LOCATION in $DOTFILES_LOCATION"
  esac
}

case $MODE in
  "update")
    echo "Saving package list"
    yay -Qqe > pkglist.yay
    ;;
  "install")
    git pull origin master
    echo "Putting $DOTFILES_LOCATION in $ORIGINAL_LOCATION"
    yay -S --needed - < pkglist.yay
    ;;
esac

track $HOME/.config/coc/extensions/package.json config/coc
track $HOME/.config/g600 $HOST/config/g600
track $HOME/.config/dunst config/dunst
track $HOME/.config/i3 config/i3
track $HOME/.config/rofi config/rofi
track $HOME/.oh-my-zsh zsh/oh-my-zsh
track $HOME/.zshrc zsh
track $HOME/.screenlayout $HOST/screenlayout
track $HOME/.urxvt/ext urxvt
track $HOME/.vim/coc-settings.json vim
track $HOME/.vim/desert256.vim vim
track $HOME/.vimrc vim
track $HOME/.bash_aliases bash
track $HOME/.bash_paths bash
track $HOME/.bash_profile bash
track $HOME/.bashrc bash
track $HOME/.gitignore git
track $HOME/.gitconfig git
track $HOME/.xbindkeys $HOST/X
track $HOME/.Xdefaults $HOST/X
track $HOME/.Xresources $HOST/X

case $MODE in
  "update")
    git add .
    git commit -a -m "$(date)"
    git push origin master
    ;;
esac
