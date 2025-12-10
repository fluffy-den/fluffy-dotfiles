#!/bin/bash

# Install script - creates symlinks from dotfiles to home directory

set -e

DOTFILES_DIR="$HOME/.dotfiles"

# Home directory files
for file in "$DOTFILES_DIR"/*; do
  if [ -f "$file" ]; then
    filename=$(basename "$file")
    # Skip git files and scripts
    if [[ "$filename" != ".git"* && "$filename" != "README.md" && "$filename" != "install.sh" && "$filename" != ".gitignore" ]]; then
      target="$HOME/.$filename"
      if [ -e "$target" ] && [ ! -L "$target" ]; then
        echo "Warning: $target exists and is not a symlink. Skipping."
      else
        ln -sf "$file" "$target"
        echo "Linked $filename"
      fi
    fi
  fi
done

# Config directories
for dir in "$DOTFILES_DIR/config"/*; do
  if [ -d "$dir" ]; then
    dirname=$(basename "$dir")
    target="$HOME/.config/$dirname"
    if [ -e "$target" ] && [ ! -L "$target" ]; then
      echo "Warning: $target exists and is not a symlink. Skipping."
    else
      ln -sf "$dir" "$target"
      echo "Linked config/$dirname"
    fi
  fi
done

echo "Installation complete!"
