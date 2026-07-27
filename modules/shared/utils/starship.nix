{
  config,
  lib,
  pkgs,
  ...
}:
let
  vcsContext = pkgs.writeShellScript "starship-vcs-context" ''
    set -eu

    context=""
    remotes=""

    append() {
      if [ -n "$context" ]; then
        context="$context · $1"
      else
        context="$1"
      fi
    }

    if root="$(${pkgs.jujutsu}/bin/jj --ignore-working-copy root 2>/dev/null)"; then
      jj_context="$(${pkgs.jujutsu}/bin/jj --ignore-working-copy --repository "$root" log \
        --no-graph \
        --revision @ \
        --template 'change_id.shortest(8) ++ " " ++ bookmarks.join(",") ++ if(conflict, " !", "") ++ "\n"' \
        2>/dev/null | ${pkgs.gnused}/bin/sed -e 's/[[:space:]]*$//')"

      if [ -n "$jj_context" ]; then
        append "jj:$jj_context"
      fi

      remotes="$(${pkgs.jujutsu}/bin/jj --ignore-working-copy --repository "$root" git remote list 2>/dev/null || true)"
    elif root="$(${pkgs.git}/bin/git rev-parse --show-toplevel 2>/dev/null)"; then
      remotes="$(${pkgs.git}/bin/git -C "$root" remote --verbose 2>/dev/null || true)"
    else
      exit 1
    fi

    lower_remotes="$(printf '%s' "$remotes" | ${pkgs.coreutils}/bin/tr '[:upper:]' '[:lower:]')"
    case "$lower_remotes" in *github.com*) append "GH" ;; esac
    case "$lower_remotes" in *gitlab*) append "GL" ;; esac
    case "$lower_remotes" in *tangled.org*) append "TG" ;; esac
    case "$lower_remotes" in *rad://*) append "RAD" ;; esac

    if [ -z "$context" ]; then
      exit 1
    fi

    printf '%s\n' "$context"
  '';
in
{
  config = {
    home-manager.users.${config.dc-tec.user.name} = {
      programs.starship = {
        enable = true;
        enableZshIntegration = true;
        settings = {
          add_newline = false;
          command_timeout = 1000;
          character = {
            success_symbol = if config.dc-tec.isDarwin then "[ ❯](bold green)" else "[󱄅 ❯](bold green)";
            error_symbol = if config.dc-tec.isDarwin then "[ ❯](bold red)" else "[󱄅 ❯](bold red)";
          };

          format = lib.concatStrings [
            "$directory"
            "\${custom.vcs_context}"
            "$git_branch"
            "$git_status"
            "$direnv"
            "$cmd_duration"
            "\n󱞪(2) $character"
          ];

          right_format = lib.concatStrings [
            "$hostname"
          ];

          git_branch = {
            always_show_remote = true;
            format = "on [$symbol$branch(:$remote_name/$remote_branch)]($style) ";
            ignore_branches = [ "HEAD" ];
            style = "bold mauve";
            symbol = " ";
          };

          custom.vcs_context = {
            command = "${vcsContext}";
            description = "Jujutsu change and configured forge remotes";
            format = "[$symbol$output]($style) ";
            shell = [
              "${pkgs.bash}/bin/bash"
              "--noprofile"
              "--norc"
            ];
            style = "bold lavender";
            symbol = "󰘬 ";
            when = true;
          };

          git_status = {
            conflicted = " \${count}x ";
            ahead = " \${count}x ";
            behind = " \${count}x ";
            diverged = "󱐎 \${count}x ";
            untracked = "\${count}x ";
            stashed = "󰆔 \${count}x ";
            modified = "󰴓\${count}x ";
            staged = "󰅕\${count}x ";
            renamed = "󰑕\${count}x ";
            deleted = " \${count}x ";
          };

          directory = {
            home_symbol = " ";
            read_only = " ";
          };

          terraform = {
            disabled = false;
            symbol = "󱁢 ";
            detect_folders = [
              ".terraform"
            ];
            detect_files = [
              "environment"
            ];
            format = "on workspace [$symbol$workspace]($style) ";
          };

          kubernetes = {
            disabled = false;
            symbol = "󱃾 ";
            format = "using context [$symbol$context]($style) ";
          };

          direnv = {
            disabled = false;
            symbol = "󱃼 ";
            format = "[$symbol]($style) ";
            style = "12";
          };

          hostname = {
            ssh_symbol = " ";
            format = "connected to [$ssh_symbol$hostname]($style) ";
          };

          line_break = {
            disabled = true;
          };
        };
      };
    };
  };
}
