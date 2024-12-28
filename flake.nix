{
  description = "Justin's nix config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-24.11-darwin";
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    tmux-sessionx.url = "github:omerxx/tmux-sessionx";
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    nix-darwin,
    home-manager,
    ...
  }: let
    user = "justin";
    system = "aarch64-darwin";
    configuration = {pkgs, ...}: {
      imports = [
        ./darwin/homebrew.nix
      ];

      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages = [
        pkgs.git
        pkgs.mas
        pkgs.sketchybar
      ];

      # Auto upgrade nix package and the daemon service.
      services.nix-daemon.enable = true;
      # nix.package = pkgs.nix;

      # services.kanata = {
      #   enable = true;
      #   config = builtins.readFile ./kanata/kanata.kbd;
      # };

      # Allow touch-id for sudo
      security.pam.enableSudoTouchIdAuth = true;

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Create /etc/zshrc that loads the nix-darwin environment.
      #programs.zsh.enable = true;  # default shell on catalina
      programs.fish.enable = true;

      # FIXME: This is needed to address bug where the $PATH is re-ordered by
      # the `path_helper` tool, prioritising Apple’s tools over the ones we’ve
      # installed with nix.
      #
      # This gist explains the issue in more detail: https://gist.github.com/Linerre/f11ad4a6a934dcf01ee8415c9457e7b2
      # There is also an issue open for nix-darwin: https://github.com/LnL7/nix-darwin/issues/122
      programs.fish.loginShellInit = let
        # We should probably use `config.environment.profiles`, as described in
        # https://github.com/LnL7/nix-darwin/issues/122#issuecomment-1659465635
        # but this takes into account the new XDG paths used when the nix
        # configuration has `use-xdg-base-directories` enabled. See:
        # https://github.com/LnL7/nix-darwin/issues/947 for more information.
        profiles = [
          "/etc/profiles/per-user/$USER" # Home manager packages
          "$HOME/.nix-profile"
          "(set -q XDG_STATE_HOME; and echo $XDG_STATE_HOME; or echo $HOME/.local/state)/nix/profile"
          "/run/current-system/sw"
          "/nix/var/nix/profiles/default"
        ];

        makeBinSearchPath =
          nixpkgs.lib.concatMapStringsSep " " (path: "${path}/bin");
      in ''
        # Fix path that was re-ordered by Apple's path_helper
        fish_add_path --move --prepend --path ${makeBinSearchPath profiles}
        set fish_user_paths $fish_user_paths
      '';

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 5;

      system.defaults = {
        dock = {
          autohide = true;
          autohide-delay = 0.1;
          autohide-time-modifier = 0.5;
          expose-animation-duration = 0.25;
          expose-group-by-app = true;
          launchanim = false;
          mineffect = "scale";
          minimize-to-application = true;
          mru-spaces = false;
          orientation = "bottom";
          persistent-apps = [
            "/System/Applications/Messages.app"
            "/Applications/Arc.app"
            "/Applications/Spark Desktop.app"
            "/Applications/Things3.app"
            "/Applications/Obsidian.app"
            "/Applications/Slack.app"
            "/System/Applications/Calendar.app"
            # "/Applications/Day One.app"
            # "/Applications/iTerm.app"
            "/Applications/Ghostty.app"
            "/Applications/ChatGPT.app"
            "/Applications/OpenSCAD.app"
          ];

          persistent-others = [
            "/Users/${user}/Desktop"
            "/Users/${user}/Downloads"
          ];

          # CustomUserPreferences = {
          #         # Sets Downloads folder with fan view in Dock
          #         "com.apple.dock" = {
          #             persistent-others = [
          #             {
          #                 "tile-data" = {
          #                     "file-data" = {
          #                     "_CFURLString" = "/Users/<youruser>/Downloads";
          #                     "_CFURLStringType" = 0;
          #                   };
          #                   "arrangement" = 2;  # sorting order
          #                   "displayas" = 1;    # 1 for fan display
          #                   "showas" = 1;       # 1 for stack view
          #                 };
          #                 "tile-type" = "directory-tile";
          #               }
          #             {
          #                 "tile-data" = {
          #                   "file-data" = {
          #                     "_CFURLString" = "/Applications";
          #                     "_CFURLStringType" = 0;
          #                   };
          #                 };
          #                 "tile-type" = "directory-tile";
          #               }
          #           ];
          #         };
          #       };
          #
          #   };

          show-process-indicators = true;
          show-recents = true;
          showhidden = true;

          slow-motion-allowed = false;

          static-only = false;

          tilesize = 42;
        };

        spaces.spans-displays = true;
      };

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = system;
      nixpkgs.config.allowUnfree = true;
      nixpkgs.overlays = [
        (import ./overlays/default.nix)
      ];

      environment.shells = [pkgs.fish];
      #environment.loginShell = pkgs.fish;

      users.users.${user} = {
        name = "${user}";
        home = "/Users/${user}";
        shell = pkgs.fish;
      };
    };
    homeconfig = {pkgs, ...}: {
      # this is internal compatibility configuration
      # for home-manager, don't change this!
      home.stateVersion = "24.05";
      # Let home-manager install and manage itself.
      programs.home-manager.enable = true;

      imports = [
        ./shell/tmux.nix
      ];

      # Enable carapace completions
      programs.carapace.enable = true;
      programs.carapace.enableFishIntegration = true;

      home.packages = with pkgs; [
        alejandra # nix formatter
        awscli2
        bat
        carapace
        clojure
        clojure-lsp
        coreutils
        difftastic
        direnv
        eza
        fd
        fzf
        gnused
        htop
        httpie
        jq
        just
        k9s
        kubectx
        kubelogin # for azure
        lazydocker
        lazygit
        leiningen
        nb
        neil
        neofetch
        neovim
        nerdfonts
        ripgrep
        starship
        thefuck
        tldr
        tree
        vault
        yazi
        zoxide
      ];

      home.sessionVariables = {
        EDITOR = "nvim";
        CARAPACE_BRIDGES = "fish,zsh,bash,inshellisense";
      };

      home.file."./.config/nvim/" = {
        source = ./nvim;
        recursive = true;
      };

      home.file."./.config/fish/" = {
        source = ./fish;
        recursive = true;
      };

      home.file."./.config/ghostty/" = {
        source = ./ghostty;
        recursive = true;
      };

      home.file."./.config/aerospace/" = {
        source = ./aerospace;
        recursive = true;
      };

      home.file."./.config/kanata/" = {
        source = ./kanata;
        recursive = true;
      };

      home.file."./.config/starship.toml" = {
        source = ./starship.toml;
      };

      home.file.".gitconfig" = {
        source = ./gitconfig;
      };

      home.file.".dircolors" = {
        source = ./dircolors;
      };
    };
  in {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#simple
    darwinConfigurations."greed" = nix-darwin.lib.darwinSystem {
      modules = [
        configuration
        (import ./modules/services/kanata.nix)
        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.verbose = true;
          home-manager.users.justin = homeconfig;
          home-manager.extraSpecialArgs = {
            inherit inputs;
          };
        }
      ];
      specialArgs = {
        inherit inputs;
      };
    };

    # Expose the package set, including overlays, for convenience.
    darwinPackages = self.darwinConfigurations."greed".pkgs;
  };
}
