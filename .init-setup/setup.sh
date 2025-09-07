#!/bin/bash

set -e

echo "==> Instalando pacotes do pac.txt com pacman..."
sudo pacman -Syu --noconfirm
sudo pacman -S --needed --noconfirm $(< pac.txt)

echo "==> Clonando dotfiles bare repo..."
git clone --bare https://github.com/dvanael/dotfiles.git $HOME/.cfg

function config {
   /usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME "$@"
}

echo "==> Tentando aplicar os dotfiles..."
mkdir -p .config-backup
config checkout || {
    echo "Arquivos conflitantes encontrados. Movendo para .config-backup/"
    config checkout 2>&1 | grep -E "^\s+\." | awk {'print $1'} | xargs -I{} mv {} .config-backup/{}
    config checkout
}
config config status.showUntrackedFiles no

echo "==> Instalando Oh My Zsh..."
export RUNZSH=no
export CHSH=no
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

echo "==> Clonando plugins do Zsh..."
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

chsh -s /bin/zsh

echo "==> Instalando yay (AUR helper)..."
sudo pacman -S --needed --noconfirm git base-devel
rm -rf yay
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si --noconfirm
cd ..
rm -rf yay

echo "==> Instalando pacotes do yay.txt com yay..."
yay -S --needed --noconfirm $(< yay.txt)

echo "✅ Setup finalizado com sucesso!"
