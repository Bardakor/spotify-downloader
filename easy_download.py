#!/usr/bin/env python3
"""
Easy SpotDL Downloader Script
A simple script to download music from Spotify using spotdl.
"""

import subprocess
import sys
import os
from pathlib import Path

def run_spotdl(args):
    """Run spotdl command with the provided arguments."""
    cmd = ["spotdl"] + args
    try:
        result = subprocess.run(cmd, capture_output=True, text=True)
        print(result.stdout)
        if result.stderr:
            print("Error:", result.stderr)
        return result.returncode == 0
    except Exception as e:
        print(f"Error running command: {e}")
        return False

def download_single_track(url, output_dir="downloads"):
    """Download a single track from Spotify."""
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)
    
    args = [url, "--output", f"{output_dir}/{{artists}} - {{title}}.{{output-ext}}"]
    print(f"Downloading track: {url}")
    return run_spotdl(args)

def download_playlist(url, output_dir="downloads"):
    """Download an entire playlist from Spotify."""
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)
    
    args = [url, "--output", f"{output_dir}/{{list-name}}/{{artists}} - {{title}}.{{output-ext}}"]
    print(f"Downloading playlist: {url}")
    print(f"Files will be saved to: {output_dir}/[Playlist Name]/")
    return run_spotdl(args)

def download_album(url, output_dir="downloads"):
    """Download an entire album from Spotify."""
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)
    
    args = [url, "--output", f"{output_dir}/{{album-artist}} - {{album}}/{{track-number}} - {{artists}} - {{title}}.{{output-ext}}"]
    print(f"Downloading album: {url}")
    return run_spotdl(args)

def search_and_download(query, output_dir="downloads"):
    """Search for and download music by query."""
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)
    
    args = [query, "--output", f"{output_dir}/{{artists}} - {{title}}.{{output-ext}}"]
    print(f"Searching and downloading: {query}")
    return run_spotdl(args)

def main():
    """Main function to handle command line arguments."""
    if len(sys.argv) < 2:
        print("SpotDL Easy Downloader")
        print("Usage:")
        print("  python easy_download.py <spotify_url>")
        print("  python easy_download.py track <spotify_track_url>")
        print("  python easy_download.py playlist <spotify_playlist_url>") 
        print("  python easy_download.py album <spotify_album_url>")
        print("  python easy_download.py search '<search_query>'")
        print("\nExamples:")
        print("  python easy_download.py https://open.spotify.com/track/4iV5W9uYEdYUVa79Axb7Rh")
        print("  python easy_download.py track https://open.spotify.com/track/4iV5W9uYEdYUVa79Axb7Rh")
        print("  python easy_download.py playlist https://open.spotify.com/playlist/37i9dQZF1DXcBWIGoYBM5M")
        print("  python easy_download.py album https://open.spotify.com/album/1DFixLWuPkv3KT3TnV35m3")
        print("  python easy_download.py search 'artist:Ed Sheeran track:Shape of You'")
        return
    
    command = sys.argv[1].lower()
    
    if command.startswith("https://open.spotify.com/"):
        # Direct URL provided
        url = command
        if "/track/" in url:
            download_single_track(url)
        elif "/playlist/" in url:
            download_playlist(url)
        elif "/album/" in url:
            download_album(url)
        else:
            print("Unsupported Spotify URL type")
    
    elif command == "track" and len(sys.argv) > 2:
        download_single_track(sys.argv[2])
    
    elif command == "playlist" and len(sys.argv) > 2:
        download_playlist(sys.argv[2])
    
    elif command == "album" and len(sys.argv) > 2:
        download_album(sys.argv[2])
    
    elif command == "search" and len(sys.argv) > 2:
        search_and_download(sys.argv[2])
    
    else:
        print("Invalid command. Use --help for usage information.")

if __name__ == "__main__":
    main() 