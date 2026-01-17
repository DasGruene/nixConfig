sudo nix-store --optimize
sudo nix-collect-garbage --delete-older-than 7d
sudo rm /run/booted-system
sudo nix-collect-garbage --delete-older-than 7d

