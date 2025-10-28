# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  personal = import ./secrets/personal.nix;
  lib = pkgs.lib;
  nixvim = import (builtins.fetchGit {
    url = "https://github.com/nix-community/nixvim";
    ref = "nixos-25.05";
  });
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      <home-manager/nixos>
    ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = personal.timeZone;

  # Select internationalisation properties.
  i18n.defaultLocale = personal.defaultLocale;

  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  services.xserver.enable = true;

  # SDDM for login
  services.displayManager.sddm = {
    wayland.enable = true;
    enable = true;
    package = pkgs.kdePackages.sddm;
    theme = "sddm-astronaut-theme";
    extraPackages = with pkgs; [
      kdePackages.qtsvg
      kdePackages.qtmultimedia
      kdePackages.qtvirtualkeyboard
      sddm-astronaut
    ];
  };
  # services.desktopManager.plasma6.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

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
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  services.flatpak.enable = true;

  services.avahi = {
    enable = true;
    nssmdns4 = true;
  };

  security.pam.services.sddm.enableKwallet = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users = {
  } // {
    "${personal.localUser.userName}" = {
      isNormalUser = true;
      description = personal.localUser.description;
      extraGroups = [ "networkmanager" "wheel" ];
      packages = with pkgs; [
        kdePackages.kate
      #  thunderbird
      ];
    };
  };

  home-manager.backupFileExtension = "hm-bak2";

  home-manager.users.rrh = { pkgs, ... }: {
    nixpkgs.config.allowUnfree = true;

    imports = [ nixvim.homeModules.nixvim ];

    home.packages = with pkgs; [
      dotnetCorePackages.sdk_9_0
      libreoffice
      spotify
      jetbrains-toolbox
      libGL
      libpulseaudio
      libuuid
      libxkbcommon
      icu
      zlib

      gcc

      jdt-language-server
      fsautocomplete
      omnisharp-roslyn

      bibata-cursors
      wofi
      flat-remix-gtk
      adwaita-icon-theme
      waybar
      mako

      go_1_24
      nodejs_24
      python314

      busybox
      procps
      grimblast
      feh
      nnn
      mpv
      tree

      (pkgs.callPackage ./cogniflight-socket.nix { })
    ];

    home.pointerCursor = {
      gtk.enable = true;
# x11.enable = true;
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Classic";
      size = 16;
    };

    gtk = {
      enable = true;

      theme = {
        package = pkgs.flat-remix-gtk;
        name = "Flat-Remix-GTK-Grey-Darkest";
      };

      iconTheme = {
        package = pkgs.adwaita-icon-theme;
        name = "Adwaita";
      };
    };

    programs.obs-studio.enable = true;
    programs.kitty.enable = true;
    wayland.windowManager.hyprland = {
      # Enable hyprland
      enable = true;

      # Tell it to use the NixOS module
      package = null;
      portalPackage = null;

      # Maybe fix systemd
      systemd = {
        variables = ["--all"];
      };

      settings = {
        "$mod" = "SUPER";
        bind =
          [
            # Basics
            "$mod, F, exec, firefox" # Win+F firefox
            "$mod, Return, exec, kitty" # Win+Enter terminal
            "$mod, code:9, exit" # Win+Escape logs out immediately
            "$mod SHIFT, Q, closewindow, activewindow" # Win+Shift+Q closes the active window
            "$mod, D, exec, wofi --show drun" # Win+D opens app search
            "$mod, F1, exec, kitty -e nmtui" # Win+F1 opens Wi-Fi terminal
            "$mod, E, exec, kitty -e nnn" # File explorer

            # No clue what this does
            ", Print, exec, grimblast copy area"

            ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_SINK@ 5%+"
            ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_SINK@ 5%-"
            ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_SINK@ toggle"

            # Hopping between windows
            "$mod, H, movefocus, l"
            "$mod, L, movefocus, r"
            "$mod, K, movefocus, u"
            "$mod, J, movefocus, d"

            # Moving windows
            "$mod SHIFT, H, swapwindow, l"
            "$mod SHIFT, L, swapwindow, r"
            "$mod SHIFT, J, swapwindow, d"
            "$mod SHIFT, K, swapwindow, u"

          ]
          ++ (
              # workspaces
              # binds $mod + [shift +] {1..9} to [move to] workspace {1..9}
              builtins.concatLists (builtins.genList (i:
                  let ws = i + 1;
                  in [
                    "$mod, code:1${toString i}, workspace, ${toString ws}"
                    "$mod SHIFT, code:1${toString i}, movetoworkspace, ${toString ws}"
                  ]
                  )
                9)
             );

          general = {
            monitor = ",preferred,auto,1";
          };

          "exec-once" = [
            "waybar"
            "mako"
            "${pkgs.writeShellScript "start-wallpaper" ''
              VID_DIR="$HOME/wallpaper-videos"
              if [ -d "$VID_DIR" ]; then
                mpvpaper -pf -o "no-audio loop-playlist shuffle" '*' "$VID_DIR/"
              fi
                ''}"
          ];

          input = {
            accel_profile = "flat";
            sensitivity = "0.0";
          };
      };
    };

    home.sessionVariables = {
      LD_LIBRARY_PATH = "${lib.makeLibraryPath (with pkgs; [
        libGL
        libpulseaudio
        libuuid
        libxkbcommon
        icu
        zlib
      ])}";
    };

    programs.nixvim = {
      enable = true;

      colorschemes.tokyonight.enable = true;

      plugins = {
        lualine.enable = true;
        treesitter.enable = true;
        telescope.enable = true;
        web-devicons.enable = true;

        cmp = {
          enable = true;
          settings = {
            mapping = {
              "<CR>" = "cmp.mapping.confirm({ select = true })";
              "<C-Space>" = "cmp.mapping.complete()";
              "<Tab>" = ''
                cmp.mapping(function(fallback)
                  if cmp.visible() then
                    cmp.select_next_item()
                  else
                    fallback()
                  end
                end, {"i", "s"})
                '';
              "<S-Tab>" = ''
                cmp.mapping(function(fallback)
                  if cmp.visible() then
                    cmp.select_prev_item()
                  else
                    fallback()
                  end
                end, {"i", "s"})
                '';
            };
            sources = [
            { name = "nvim_lsp"; }
            { name = "buffer"; }
            { name = "path"; }
            ];
          };
        };

        cmp-buffer.enable = true;
        cmp-path.enable = true;
        cmp-nvim-lsp.enable = true;

        lsp = {
          enable = true;

          servers = {
            gopls.enable = true;
            pyright.enable = true;
            bashls.enable = true;
          };
        };
      };

      opts = {
        number = true;
        relativenumber = true;
        expandtab = true;
        shiftwidth = 2;
      };

      extraConfigLua = ''
        vim.g.mapleader = " "
        vim.keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<cr>")

        vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, { noremap = true, silent = true })

        vim.api.nvim_create_autocmd("BufWritePre", {
          pattern = "*.go",
          callback = function()
            local params = vim.lsp.util.make_range_params()
            params.context = {only = {"source.organizeImports"}}
            -- buf_request_sync defaults to a 1000ms timeout. Depending on your
            -- machine and codebase, you may want longer. Add an additional
            -- argument after params if you find that you have to write the file
            -- twice for changes to be saved.
            -- E.g., vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, 3000)
            local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params)
            for cid, res in pairs(result or {}) do
              for _, r in pairs(res.result or {}) do
                if r.edit then
                  local enc = (vim.lsp.get_client_by_id(cid) or {}).offset_encoding or "utf-16"
                  vim.lsp.util.apply_workspace_edit(r.edit, enc)
                end
              end
            end
            vim.lsp.buf.format({async = false})
          end
        })
        '';
    };


    # programs.neovim = {
      # enable = true;
      # defaultEditor = true;
      # viAlias = true;
      # vimAlias = true;
      # extraPackages = with pkgs; [
        # wl-clipboard
        # dotnetCorePackages.sdk_9_0
        # nil
      # ];
    # };

    programs.tmux.enable = true;
    programs.bash = {
      enable = true;
      bashrcExtra = ''
        parse_git_branch() {
          local output=$(git branch --show-current 2>/dev/null)
          if [[ -n "$output" ]]; then
            echo -n " $output"
            git diff --quiet || echo -n "*"
            echo -n " "
          fi
        }
        export PS1="\[\e[1;32m\][\u@\h:\w]\[\e[33m\]\$(parse_git_branch)\[\e[1;32m\]$ \[\e[0m\]"
      '';
    };

    # home.file.".config/nvim/init.lua".source = ./dotfiles/nvim/init.lua;
    # home.file.".config/nvim/lua".source = ./dotfiles/nvim/lua;
    home.file.".config/waybar".source = ./dotfiles/waybar;
    home.file.".config/mako".source = ./dotfiles/mako;
    home.file.".config/tmux".source = ./dotfiles/tmux;

    programs.git = {
      enable = true;
      userName = personal.git.userName;
      userEmail = personal.git.userEmail;

      extraConfig = {
        init.defaultBranch = "main";
        url."git@github.com:".insteadOf = "https://github.com/";
        core.sshCommand = "ssh -i ~/.ssh/id_ed25519";
      };
    };

    home.stateVersion = "25.05";
  };

  virtualisation.docker = {
    enable = true;
    enableOnBoot = true; # starts the daemon at boot
    liveRestore = false; # containers stop when daemon stops
  };

  # Install firefox.
  programs.firefox.enable = true;


  programs.hyprland.enable = true;
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    kitty
    ffmpeg
    jdk24

    sddm-astronaut
    (callPackage ./claude-code/claude-code.nix {})
    mpvpaper
    avahi
  ];

  fonts.packages = with pkgs; [
    google-fonts
  ];

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

}
