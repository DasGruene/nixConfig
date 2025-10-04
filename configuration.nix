# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:


let
    nixvim = import (builtins.fetchGit {
        url = "https://github.com/nix-community/nixvim";
        ref = "nixos-25.05";
    });
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      nixvim.nixosModules.nixvim
    ];
  
  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 10;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;
  networking.firewall.allowedTCPPorts = [ 57621 ]; # spotify sync with mobile devices on local network
  networking.firewall.allowedUDPPorts = [ 5353 ]; # spotify sync with other devices ex: google cast, sonos etc, on local network
  # Set your time zone.
  time.timeZone = "Europe/Copenhagen";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "da_DK.UTF-8";
    LC_IDENTIFICATION = "da_DK.UTF-8";
    LC_MEASUREMENT = "da_DK.UTF-8";
    LC_MONETARY = "da_DK.UTF-8";
    LC_NAME = "da_DK.UTF-8";
    LC_NUMERIC = "da_DK.UTF-8";
    LC_PAPER = "da_DK.UTF-8";
    LC_TELEPHONE = "da_DK.UTF-8";
    LC_TIME = "da_DK.UTF-8";
  };

  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  services.xserver.enable = true;
  
  programs.nm-applet.enable = true;
  
  #Hyprland stuff
  services.hypridle.enable = true;
  programs.hyprland = {
    enable = true;
    withUWSM = true; # recommended for most users
    xwayland.enable = true;
  };

  environment.sessionVariables = {
    WLR_NO_HARDWARE_CURSORS = "1";
    TERMINAL = "ghostty"; #makes nvim and vim open in ghostty if called through the runner
    #NIXOS_OZONE_WL = "1";
  };


  hardware = {
      graphics.enable = true;
      graphics.enable32Bit = true;
      graphics.extraPackages = with pkgs; [ 
        vpl-gpu-rt  
        nvidia-vaapi-driver
      ];
  };

  # Load nvidia driver for Xorg and Wayland
  services.xserver.videoDrivers = ["nvidia"];

  hardware.nvidia = {

    # Modesetting is required.
    modesetting.enable = true;

    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    # Enable this if you have graphical corruption issues or application crashes after waking
    # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead 
    # of just the bare essentials.
    powerManagement.enable = false;

    # Fine-grained power management. Turns off GPU when not in use.
    # Experimental and only works on modern Nvidia GPUs (Turing or newer).
    powerManagement.finegrained = false;

    # Use the NVidia open source kernel module (not to be confused with the
    # independent third-party "nouveau" open source driver).
    # Support is limited to the Turing and later architectures. Full list of 
    # supported GPUs is at: 
    # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus 
    # Only available from driver 515.43.04+
    open = false;

    # Enable the Nvidia settings menu,
	# accessible via `nvidia-settings`.
    nvidiaSettings = false;

    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    package = config.boot.kernelPackages.nvidiaPackages.stable;

    prime = {
	sync.enable = true;

	nvidiaBusId = "PCI:0:1:0";
	intelBusId = "PCI:0:2:0";
	};
  };

  boot.blacklistedKernelModules = [ "nouveau" ];

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.theme = "where-is-my-sddm-theme";
  services.displayManager.sddm.wayland.enable = true;
#  services.desktopManager.plasma6.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "dk";
    variant = "winkeys";
  };

  # Configure console keymap
  console.keyMap = "dk-latin1";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;
  
  #virrual machine stuff:
  programs.virt-manager.enable = true;
  users.groups.libvirtd.members = ["your_username"];
  virtualisation.spiceUSBRedirection.enable = true;
  virtualisation.libvirtd = {
    enable = true;
    qemu.vhostUserPackages = with pkgs; [ virtiofsd ];
  };
  
  services.udisks2.enable = true; #auto maount usbs
  boot.supportedFilesystems = [ "ntfs" ]; # allow winodws format storages devices

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.user = {
    isNormalUser = true;
    description = "user";
    extraGroups = [ "networkmanager" "wheel" "libvirtd" "docker"];
    packages = with pkgs; [
      kdePackages.kate
    #  thunderbird
    ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  programs.direnv.enable = true;
  virtualisation.docker.enable = true;


  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim
    vimPlugins.vim-wayland-clipboard
    git
    docker-compose
    ghostty
    fish
    zellij
    discord
    obsidian
    libreoffice-still
    librewolf
    chromium
    prusa-slicer
    spotify
    unzip
    qmk
    pavucontrol #audio
    kitty # default terminal hyprland
    waybar # bar for hyprland
    font-awesome # font used by waybar
    rofi-wayland #program runner hyprland
    lshw # used to get graphic card info
    macchina # fetches system info
    fastfetch
    qdirstat # disk analyser
    networkmanagerapplet #network ui
    imagemagick #to adjust image sizes
    hyprpaper #wallpaper
    alsa-utils #sound util UI
    xfce.thunar-archive-plugin #archive addon to thunar
    weston # used by sddm
    where-is-my-sddm-theme
    wineWowPackages.stable

    # support 32-bit only
    wine

    # support 64-bit only
    (wine.override { wineBuild = "wine64"; })

    # support 64-bit only
    wine64

    # wine-staging (version with experimental features)
    wineWowPackages.staging

    # winetricks (all versions)
    winetricks

    # native wayland support (unstable)
    wineWowPackages.waylandFull
    (vscode-with-extensions.override {
      vscode = vscode;
      vscodeExtensions = with vscode-extensions; [
        #puplisher.extension
	bbenoist.nix
        ms-python.python
        ms-pyright.pyright
        njpwerner.autodocstring
	vscodevim.vim
	yzhang.markdown-all-in-one
	mkhl.direnv
      ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
## Link to info: https://raw.githubusercontent.com/nix-community/nix-vscode-extensions/refs/heads/master/data/cache/vscode-marketplace-latest.json
        {
          name = "elixir-ls";
          publisher = "JakeBecker";
          version = "0.28.0";
          sha256 = "sha256-pHLAA7i2HJC523lPotUy5Zwa3BTSTurC2BA+eevdH38=";
        }
	{
          name = "python-extension-pack";
          publisher = "LeoJhonSong";
          version = "3.0.0";
          sha256 = "sha256-SfA+i2BD7xlELLmC8/mThZFwI0n86+/HnUZWNW5rb1s=";
        }
        {
          name = "ts-error-translator";
          publisher = "mattpocock";
          version = "0.10.1";
          sha256 = "sha256-WBdtRFaGKUmsriwUgNRToaqGJ6sdzrvOMs/fhEQFmws=";
        }
	{
          name = "remote-containers";
          publisher = "ms-vscode-remote";
          version = "0.424.0";
          sha256 = "sha256-BI7zZVSebatslFUkynr3eY3pRigbDBcpNG1JAOBGrBE=";
        }
      ]; 
    })
  ];


  programs.nixvim.enable = true;
  programs.nixvim.defaultEditor = true;
  programs.nixvim = {
    colorschemes = {
        onedark.enable = true;
    };
    globals = {
      # Set <space> as the leader key
      # See `:help mapleader`
      mapleader = " ";
      maplocalleader = " ";

      # Set to true if you have a Nerd Font installed and selected in the terminal
      have_nerd_font = true;
    };
    #  See `:help 'clipboard'`
    clipboard = {
      providers = {
        wl-copy.enable = true; # For Wayland
        xsel.enable = true; # For X11
      };

      # Sync clipboard between OS and Neovim
      #  Remove this option if you want your OS clipboard to remain independent.
      register = "unnamedplus";
    };
    plugins = {
      neo-tree = {
        enable = true;
	extraOptions = {
	  window = {
            position = "right";
          };
	  filesystem = {
            filtered_items = {
              visible = true;
            };
          };
	};
      };
      lsp = {
        enable = true;
        servers = {
          basedpyright.enable = true;
	  bashls.enable = true;
	  elixirls.enable = true;
	  nixd.enable = true;
	  pylsp.enable = true;
	  clangd.enable = true;
        };
      };
    };
    autoCmd = [
      	{ 
	  #makes neovim remember last cursor position when reopening files
	  event = ["BufReadPost"];
          pattern = ["*"];
	  callback = { 
	    __raw = ''
	      function()
                local last_position = vim.fn.line("'\"")
                if last_position > 0 and last_position <= vim.fn.line("$") then
                  vim.cmd("normal! g'\"")
                end
              end '';
	  }; 
    	}
      ];
    opts = {
      relativenumber = true;
      number = true;
      # if performing an operation that would fail due to unsaved changes in the buffer (like `:q`),
      # instead raise a dialog asking if you wish to save the current file(s)
      # See `:help 'confirm'`
      confirm = true;
      # Enable mouse mode, can be useful for resizing splits for example!
      mouse = "a";

      # Don't show the mode, since it's already in the statusline
      showmode = false;

      # Enable break indent
      breakindent = true;

      # Save undo history
      undofile = true;

      # Case-insensitive searching UNLESS \C or one or more capital letters in the search term
      ignorecase = true;
      smartcase = true;

      # Keep signcolumn on by default
      signcolumn = "yes";

      # Preview substitutions live, as you type!
      inccommand = "split";

      # Show which line your cursor is on
      cursorline = true;

      # Minimal number of screen lines to keep above and below the cursor.
      scrolloff = 10;

      # See `:help hlsearch`
      hlsearch = true;
    };
    keymaps = [
      {
        mode = "n";
        key = "<leader>e";
        action = "<cmd>Neotree toggle<CR>";
        options = {
          desc = "Open/close Neotree";
	  noremap = true;
          silent = true;
        };
      }
      {
        mode = "n";
        key = "<C-h>";
        action = "<C-w><C-h>";
        options = {
          desc = "Move focus to the left window";
        };
      }
      {
        mode = "n";
        key = "<C-l>";
        action = "<C-w><C-l>";
        options = {
          desc = "Move focus to the right window";
        };
      }
      {
        mode = "n";
        key = "<C-j>";
        action = "<C-w><C-j>";
        options = {
          desc = "Move focus to the lower window";
        };
      }
      {
        mode = "n";
        key = "<C-k>";
        action = "<C-w><C-k>";
        options = {
          desc = "Move focus to the upper window";
        };
      }
    ];
  }; 

  

  programs.thunar.enable = true;
  programs.xfconf.enable = true;
  xdg.mime.enable = true;
  xdg.mime.defaultApplications = {
        "inode/directory" = "thunar.desktop";
        "application/x-gnome-saved-search" = "thunar.desktop";
  };
  
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];

  xdg.portal = { 
    enable = true;
    xdgOpenUsePortal = true;
    
    config.common.default = [
      "hyprland"
      #"gtk"
    ];

    # systemctl --user status xdg-desktop-portal-hyprland.service
    extraPortals = [ 
      pkgs.xdg-desktop-portal-hyprland
      #pkgs.xdg-desktop-portal-gtk
    ];
  };

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
  }; 

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?
  
  #auto clean of nixos
  nix.gc = {
    automatic = true;
    randomizedDelaySec = "14m";
    options = "--delete-older-than 10d";
  };

  system.autoUpgrade.enable = true;
  nix.settings.max-jobs = 8;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
