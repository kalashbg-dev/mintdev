#!/bin/bash

# Update Spotify GPG key if the repository is present
if [ -f /etc/apt/sources.list.d/spotify.list ]; then
  echo "Updating Spotify GPG key (Migration 1718359027)..."
  curl -sS https://download.spotify.com/debian/pubkey_7A3A762FAFD4A51F.gpg | sudo gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/spotify.gpg
  echo "deb [signed-by=/etc/apt/trusted.gpg.d/spotify.gpg] http://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list
fi
