{ config, pkgs, ... }:

let
  customized_sddm_astronaut = pkgs.sddm-astronaut.override {
    embeddedTheme = "hyprland_kath";
    #themeConfig = {
    #  Background = ./background.jpg;
    #};
  };
in
{
  services.displayManager.sddm = {
    enable = true;

    extraPackages = [
      customized_sddm_astronaut
    ];

    theme = "sddm-astronaut-theme";

    settings = {
      Theme = {
        Current = "sddm-astronaut-theme";
      };
    };
  };
}
