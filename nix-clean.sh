sudo nix-store --optimize -v
sudo nix-collect-garbage --delete-older-than 7d
sudo rm /run/booted-system
