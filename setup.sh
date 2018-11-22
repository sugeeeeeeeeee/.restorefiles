#!/usr/bin/env bash

function main() {
  case "$1" in
    "install")
      plistchange
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

function plistchange() {
  echo "[INFO]plist Change"
  read -e -p "Please enter the HOSTNAME:" HOSTNAME
  # GeneralSetting
  sudo scutil --set ComputerName $HOSTNAME && \
    sudo scutil --set LocalHostName $HOSTNAME
  sudo pmset -a standbydelay 86400
  sudo nvram SystemAudioVolume=" "
  sudo systemsetup -setrestartfreeze on
  sudo systemsetup -setcomputersleep Off > /dev/null
  defaults write com.apple.finder AppleShowAllFiles -bool YES
  defaults write NSGlobalDomain AppleShowScrollBars -string "Always"
  defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
  defaults write com.apple.CrashReporter DialogType -string "none"
  defaults write com.apple.BluetoothAudioAgent "Apple Bitpool Min (editable)" -int 40
  defaults write -globalDomain com.apple.mouse.scaling -float 3.0
  defaults write com.apple.screensaver askForPassword -int 1
  defaults write com.apple.screensaver askForPasswordDelay -int 0
  defaults write com.apple.screencapture type -string "png"
  defaults write com.apple.LaunchServices LSQuarantine -bool false
  defaults write com.apple.menuextra.clock 'DateFormat' -string 'EEE H:mm'

  # Dock
  defaults write com.apple.dock mineffect -string "scale"
  defaults write com.apple.dock show-process-indicators -bool true
  defaults write com.apple.dock static-only -bool true
  defaults write com.apple.dock launchanim -bool false
  defaults write com.apple.dock persistent-apps -array
  defaults write com.apple.dashboard mcx-disabled -bool true

  # Finder
  defaults write com.apple.finder DisableAllAnimations -bool true
  defaults write com.apple.finder AppleShowAllFiles -bool true
  defaults write com.apple.finder ShowStatusBar -bool true
  defaults write com.apple.finder ShowPathbar -bool true
  defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"
  defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"
  defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
  defaults write NSGlobalDomain com.apple.springing.enabled -bool true
  defaults write NSGlobalDomain com.apple.springing.delay -float 0
  defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
  defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true
  defaults write com.apple.frameworks.diskimages skip-verify -bool true
  defaults write com.apple.frameworks.diskimages skip-verify-locked -bool true
  defaults write com.apple.frameworks.diskimages skip-verify-remote -bool true
  defaults write com.apple.frameworks.diskimages auto-open-ro-root -bool true
  defaults write com.apple.frameworks.diskimages auto-open-rw-root -bool true
  defaults write com.apple.finder OpenWindowForNewRemovableDisk -bool true
  defaults write com.apple.finder WarnOnEmptyTrash -bool false
  chflags nohidden ~/Library
  sudo chflags nohidden /Volumes
}

function install() {
  cd ~
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
  cp -p ~/.restorefiles/octave/.octaverc ~
  cp -p ~/.restorefiles/gnuplot/.gnuplot ~

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
  cd /Users/$HOSTNAME/Pictures
  WALLPAPERFOLDERID=$(gdrive list --query 'fullText contains "wallpaper" and trashed = false' | egrep  "dir" | awk '{print $1}')
  sleep 10
  for WALLPAPERID in $(gdrive list --query "'$WALLPAPERFOLDERID' in parents" | egrep -v "((dir)|(Type))" | awk '{print $1}')
  do
    sleep 10
    gdrive download $WALLPAPERID
  done
  cd ~

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
