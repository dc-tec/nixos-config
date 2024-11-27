{ nixpkgs, self }:
let
  forAllSystems = nixpkgs.lib.genAttrs [
    "x86_64-linux"
    "aarch64-darwin"
  ];

  mkDocs = forAllSystems (system: let
    pkgs = nixpkgs.legacyPackages.${system};
  in pkgs.stdenv.mkDerivation {
    name = "nixos-configuration-docs";
    src = ../.;
    
    nativeBuildInputs = with pkgs; [
      mdbook
      nixpkgs-fmt      # For formatting Nix code blocks
    ];
    
    outputs = [ "out" ];
    
    buildPhase = ''
      # Create build directory in Nix store output
      mkdir -p $out/book
      
      # Create docs structure with additional categories
      mkdir -p docs/src/{introduction,guides,generated/{core,development,graphical,wsl,darwin,machines}}
      
      cd docs
      
      # Create book.toml
      cat > book.toml << EOF
      [book]
      authors = ["Roel de Cort"]
      language = "en"
      multilingual = false
      src = "src"
      title = "NixOS Configuration Documentation"

      [output.html]
      git-repository-url = "https://github.com/dc-tec/nixos-config"
      git-repository-icon = "fa-github"
      edit-url-template = "https://github.com/dc-tec/nixos-config/edit/main/{path}"
      EOF
      
      # Create custom documentation structure
      cat > src/SUMMARY.md << EOF
      # Summary

      [Introduction](introduction/index.md)
      
      # User Guide
      - [Getting Started](guides/getting-started.md)
      - [Installation](guides/installation.md)
      
      # Core System
      - [System Configuration](generated/core/_index.md)
      - [Connectivity](generated/core/connectivity.md)
      - [Home Manager](generated/core/home-manager.md)
      - [Nix Configuration](generated/core/nix.md)
      - [Shells](generated/core/shells.md)
      - [Secrets Management (SOPS)](generated/core/sops.md)
      - [Storage](generated/core/storage.md)
      - [System](generated/core/system.md)
      - [Users](generated/core/users.md)
      - [Utilities](generated/core/utils.md)

      # Development Tools
      - [Overview](generated/development/_index.md)
      - [Infrastructure Tools](generated/development/_infra.md)
        - [Ansible](generated/development/ansible.md)
        - [AWS CLI](generated/development/aws-cli.md)
        - [Azure CLI](generated/development/azure-cli.md)
        - [HashiCorp Suite](generated/development/hashicorp.md)
        - [Packer](generated/development/packer.md)
      - [Programming Languages](generated/development/_languages.md)
        - [Go](generated/development/go.md)
        - [Python](generated/development/python.md)
        - [PowerShell](generated/development/powershell.md)
      - [Development Environment](generated/development/_environment.md)
        - [Git](generated/development/git.md)
        - [VS Code Server](generated/development/vscode-server.md)
        - [Virtualization](generated/development/virtualisation.md)
        - [YAML Tools](generated/development/yaml.md)

      # Desktop Environment
      - [Overview](generated/graphical/_index.md)
      - [Core Desktop](generated/graphical/desktop.md)
      - [Applications](generated/graphical/applications.md)
      - [Audio](generated/graphical/sound.md)
      - [Terminal](generated/graphical/terminal.md)
      - [Theming](generated/graphical/theme.md)
      - [XDG](generated/graphical/xdg.md)

      # Platform-Specific
      - [WSL Configuration](generated/wsl/_index.md)
        - [Services](generated/wsl/services.md)
        - [Users](generated/wsl/users.md)
        - [Development](generated/wsl/development.md)
      - [Darwin/MacOS](generated/darwin/_index.md)
        - [Home](generated/darwin/home.md)
        - [Homebrew](generated/darwin/homebrew.md)
        - [Nix Setup](generated/darwin/nix.md)
        - [System](generated/darwin/system.md)

      # Machine Configurations
      - [Overview](generated/machines/_index.md)
      - [Chad](generated/machines/chad.md)
      - [Darwin](generated/machines/darwin.md)
      - [Ghost](generated/machines/ghost.md)
      - [Legion](generated/machines/legion.md)
      EOF
      
      # Create placeholder files for custom documentation
      cat > src/introduction/index.md << EOF
      # Introduction
      
      Welcome to the NixOS Configuration documentation. This guide covers the setup,
      configuration, and usage of our NixOS system configurations.
      EOF
      
      cat > src/guides/getting-started.md << EOF
      # Getting Started
      
      This guide will help you get started with using and customizing these NixOS configurations.
      EOF
      
      cat > src/guides/installation.md << EOF
      # Installation Guide
      
      Step-by-step instructions for installing and configuring your NixOS system.
      EOF

      # Create index files for each section
      for section in core development graphical wsl darwin; do
        cat > src/generated/$section/_index.md << EOF
      # ''${section^} Modules Overview
      
      This section contains documentation for all ''${section} related modules.
      EOF
      done

      # Generate module documentation
      ${pkgs.writeScript "generate-modules-doc" ''
        #!${pkgs.runtimeShell}
        
        generate_module_docs() {
          local module_path=$1
          local output_path=$2
          local module_name=$3
          
          # Create module page
          echo "# $module_name" > "$output_path"
          
          # Add README content if it exists
          if [ -f "$module_path/README.md" ]; then
            echo "## Overview" >> "$output_path"
            cat "$module_path/README.md" >> "$output_path"
          fi
          
          # Add Implementation section with code snippets
          echo "## Implementation" >> "$output_path"
          
          # Add default.nix if it exists
          if [ -f "$module_path/default.nix" ]; then
            echo "### default.nix" >> "$output_path"
            echo '```nix' >> "$output_path"
            cat "$module_path/default.nix" >> "$output_path"
            echo '```' >> "$output_path"
          fi
          
          # Process subdirectories first
          for subdir in "$module_path"/*; do
            if [ -d "$subdir" ]; then
              local subdir_name=$(basename "$subdir")
              echo "### $subdir_name" >> "$output_path"
              
              # Add README if it exists
              if [ -f "$subdir/README.md" ]; then
                cat "$subdir/README.md" >> "$output_path"
              fi
              
              # Add all .nix files in the subdirectory
              for nix_file in "$subdir"/*.nix; do
                if [ -f "$nix_file" ]; then
                  echo "#### $(basename "$nix_file")" >> "$output_path"
                  echo '```nix' >> "$output_path"
                  cat "$nix_file" >> "$output_path"
                  echo '```' >> "$output_path"
                fi
              done
            fi
          done
          
          # Add remaining .nix files in the root directory
          for nix_file in "$module_path"/*.nix; do
            if [ -f "$nix_file" ] && [ "$(basename "$nix_file")" != "default.nix" ]; then
              echo "### $(basename "$nix_file")" >> "$output_path"
              echo '```nix' >> "$output_path"
              cat "$nix_file" >> "$output_path"
              echo '```' >> "$output_path"
            fi
          done
        }
        
        # Generate documentation for each module type
        for module_type in core development graphical wsl darwin; do
          for module in ../modules/$module_type/*; do
            if [ -d "$module" ]; then
              name=$(basename "$module")
              generate_module_docs "$module" "src/generated/$module_type/$name.md" "$(tr '[:lower:]' '[:upper:]' <<< ${name:0:1})${name:1}"
            fi
          done
        done
        
        # Generate machine configurations documentation
        for machine in ../machines/*; do
          if [ -d "$machine" ]; then
            name=$(basename "$machine")
            output_file="src/generated/machines/$name.md"
            echo "# $name Configuration" > "$output_file"
            
            # Add README content if it exists
            if [ -f "$machine/README.md" ]; then
              echo "## Setup Instructions" >> "$output_file"
              cat "$machine/README.md" >> "$output_file"
            fi
            
            # Add Hardware Configuration
            if [ -f "$machine/hardware.nix" ]; then
              echo "## Hardware Configuration" >> "$output_file"
              echo '```nix' >> "$output_file"
              cat "$machine/hardware.nix" >> "$output_file"
              echo '```' >> "$output_file"
            fi
            
            # Add System Configuration
            if [ -f "$machine/default.nix" ]; then
              echo "## System Configuration" >> "$output_file"
              echo '```nix' >> "$output_file"
              cat "$machine/default.nix" >> "$output_file"
              echo '```' >> "$output_file"
            fi
            
            # Add any additional .nix files
            for nix_file in "$machine"/*.nix; do
              if [ -f "$nix_file" ] && [ "$(basename "$nix_file")" != "default.nix" ] && [ "$(basename "$nix_file")" != "hardware.nix" ]; then
                echo "## $(basename "$nix_file" .nix)" >> "$output_file"
                echo '```nix' >> "$output_file"
                cat "$nix_file" >> "$output_file"
                echo '```' >> "$output_file"
              fi
            done
          fi
        done
      ''}

      # Build the book
      mdbook build --dest-dir $out/book
    '';
    
    dontInstall = true;
  });

  serve-docs = forAllSystems (system: let
    pkgs = nixpkgs.legacyPackages.${system};
    docs = mkDocs.${system};  # Reference the docs build for this system
  in pkgs.writeShellScriptBin "serve-docs" ''
    echo "Starting server at http://localhost:8000"
    cd "${docs}/book" && ${pkgs.python3}/bin/python3 -m http.server 8000
  '');

in {
  inherit mkDocs serve-docs;
  
  apps = forAllSystems (system: {
    serve-docs = {
      type = "app";
      program = "${serve-docs.${system}}/bin/serve-docs";
    };
  });
}
