#! /bin/bash

function main() {
  case "$1" in
    "install")
      install
      ;;
    "clean")
      clean
      ;;
    *)
      echo "$0: illegal command \"$1\" "
      usage
      ;;
  esac
}

function usage() {
  echo "Usage: $0 [COMMANDS]"
  echo ""
  echo "Argument:"
  echo "help   : Show this message"
  echo "install: Install .dotfiles"
  echo "clean  : Remove temporary files"
}

function install() {
  echo "[START]SETUP START!!"
  cd ~
  echo "[INFO]CHANGE HOSTNAME"
  read -e -p "Please enter the HOSTNAME:" HOSTNAME
  sudo scutil --set ComputerName $HOSTNAME && \
    sudo scutil --set LocalHostName $HOSTNAME
  defaults write com.apple.finder AppleShowAllFiles -bool YES

  echo "[INFO]APP INSTALL"
  brew tap Homebrew/bundle
  brew install gdrive && \
    gdrive list && \
    BREWFILEID="$(gdrive list | grep Brewfile | awk '{print $1}')"
  gdrive download $BREWFILEID --force --path ~
  brew bundle --file=~/Brewfile && \
    rm -f Brewfile
  curl http://magicprefs.com/MagicPrefs.app.zip -o /tmp/MagicPrefs.app.zip && \
    unzip /tmp/MagicPrefs.app.zip -d /Applications && \
    rm -rf /tmp/MagicPrefs.app.zip

  echo "[INFO].DOTFILES COPY"
  cp -p ~/.restorefiles/tmux/.tmux.conf ~
  cp -p ~/.restorefiles/zsh/.zshrc ~
  cp -p ~/.restorefiles/vim/.vimrc ~

  echo "[INFO]COLORSCHEME DOWNLOAD"
  mkdir ~/scheme && \
    curl https://raw.githubusercontent.com/Arc0re/Iceberg-iTerm2/master/iceberg.itermcolors -o ~/scheme/iceberg.itermcolors
  mkdir -p ~/.vim/color && \
    cd $_ && \
    curl https://raw.githubusercontent.com/cocopon/iceberg.vim/master/colors/iceberg.vim -o ~/.vim/color/iceberg.vim
  cd ~

  echo "[INFO]FONT DOWNLOAD"
  git clone https://github.com/powerline/fonts.git --depth=1 && \
    cd fonts && \
    ./install.sh && \
    cd ../ && \
    rm -rf fonts && \
    cd ~

  echo "[INFO]POWERLINE-GO DOWNLOAD"
  curl https://github.com/justjanne/powerline-go/releases/download/v1.11.0/powerline-go-darwin-amd64 -o /usr/local/bin/powerline-go && \
    chmod +x /usr/local/bin/powerline-go

  echo "[INFO].SSH DOWNLOAD"
  SSHID="$(gdrive list --query 'fullText contains ".ssh" and trashed = false' | grep dir | awk '{print $1}')"
  gdrive download $SSHID --force --recursive --path ~ && \
    chmod 700 ~/.ssh && \
    chmod 600 ~/.ssh/*

  echo "[INFO]WALLPAPER DOWNLOAD"
  WALLPAPERID="$(gdrive list --query 'fullText contains "wallpaper" and trashed = false' | grep dir | awk '{print $1}')"
  gdrive download $WALLPAPERID --recursive --path ~ && \
    mv ~/danbo/* /Users/$HOSTNAME/Pictures && \
    rm -rf ~/danbo

  echo "[INFO]OCTAVE INSTALL"
  brew install gnuplot --with-aquaterm --with-x11 &&\
  brew install octave

  echo "[END]NORMALLY END!!"
}

if [ $# -eq 0 ]; then
  usage
  exit 1
else
  main $1
  exit 0
fi
