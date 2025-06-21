# Spotify Downloader Setup Guide

This repository contains the spotify-downloader setup with your configured Spotify credentials.

## Setup Summary

✅ **Repository Cloned**: Successfully cloned from `https://github.com/spotDL/spotify-downloader.git`  
✅ **Virtual Environment**: Created and activated (`venv/`)  
✅ **Dependencies**: Installed via Poetry  
✅ **Spotify Credentials**: Configured with your app credentials  
✅ **FFmpeg**: Available on system  
✅ **Configuration**: Created and tested  

## Your Spotify App Configuration

- **Client ID**: `1f61f6b391864e648596e732067f390c`
- **Client Secret**: `4196b060b0d6453386270006192519f3`  
- **Username**: `21au7w2fzjzf7wb3gfyecitca`
- **App Status**: Development mode

> **Note**: Your credentials are saved in `~/.spotdl/config.json` and will be used automatically.

## Quick Start

### 1. Activate the Environment
```bash
cd /Users/liam/Documents/Code/Random/spotify-downloader
source venv/bin/activate
```

### 2. Basic Usage

#### Download a Single Track
```bash
spotdl "https://open.spotify.com/track/4iV5W9uYEdYUVa79Axb7Rh"
```

#### Download a Playlist (into its own folder)
```bash
spotdl "https://open.spotify.com/playlist/37i9dQZF1DXcBWIGoYBM5M" --output "downloads/{list-name}/{artists} - {title}.{output-ext}"
```

#### Easy Playlist Download (dedicated script)
```bash
./download_playlist.sh "https://open.spotify.com/playlist/37i9dQZF1DXcBWIGoYBM5M"
```

#### Download an Album
```bash
spotdl "https://open.spotify.com/album/1DFixLWuPkv3KT3TnV35m3"
```

#### Search and Download
```bash
spotdl "artist:Ed Sheeran track:Shape of You"
```

### 3. Using the Easy Download Script

I've created a helper script that makes downloads even easier:

```bash
# Show help
python easy_download.py

# Download a track
python easy_download.py "https://open.spotify.com/track/4iV5W9uYEdYUVa79Axb7Rh"

# Download a playlist
python easy_download.py playlist "https://open.spotify.com/playlist/37i9dQZF1DXcBWIGoYBM5M"

# Download an album
python easy_download.py album "https://open.spotify.com/album/1DFixLWuPkv3KT3TnV35m3"

# Search and download
python easy_download.py search "artist:The Beatles track:Hey Jude"
```

## Configuration Details

Your configuration is stored in `~/.spotdl/config.json` with these key settings:

- **Format**: MP3 (128k bitrate)
- **Audio Source**: YouTube Music
- **Lyrics Sources**: Genius, AZLyrics, Musixmatch
- **Output Template**: `{artists} - {title}.{output-ext}`
- **Overwrite Mode**: Skip existing files

## Advanced Options

### Change Output Format
```bash
spotdl "spotify_url" --format flac
```

### Custom Output Directory
```bash
spotdl "spotify_url" --output "~/Music/{artists} - {title}.{output-ext}"
```

### Download with Lyrics
```bash
spotdl "spotify_url" --generate-lrc
```

### High Quality (256k bitrate)
```bash
spotdl "spotify_url" --bitrate 256k
```

### Download Your Saved Songs
```bash
spotdl saved
```

### Download All Your Playlists
```bash
spotdl all-user-playlists
```

## File Structure

```
spotify-downloader/
├── downloads/              # Downloaded files go here
├── easy_download.py       # Python helper script for downloads
├── download.sh            # Simple shell script for single tracks
├── download_playlist.sh   # Dedicated playlist downloader (creates folders)
├── venv/                  # Virtual environment
├── spotdl/                # Main application code
├── pyproject.toml         # Project dependencies
└── README_SETUP.md        # This file
```

## Available Output Variables

You can customize the output filename using these variables:

- `{title}` - Song title
- `{artists}` - All artists
- `{artist}` - Main artist
- `{album}` - Album name
- `{album-artist}` - Album artist
- `{track-number}` - Track number
- `{year}` - Release year
- `{genre}` - Genre
- `{list-name}` - Playlist name
- `{output-ext}` - File extension

## Troubleshooting

### If downloads fail:
1. Check your internet connection
2. Verify the Spotify URL is correct
3. Check if the song is available in your region
4. Try a different audio source: `--audio youtube`

### If you get authentication errors:
```bash
spotdl --user-auth
```

### To update spotdl:
```bash
pip install --upgrade spotdl
```

## Legal Notice

- Only download music you have the right to download
- Respect artist and label copyrights
- This tool is for personal use only
- spotDL downloads from YouTube, not directly from Spotify

## Support

- Documentation: https://spotdl.rtfd.io/
- Discord: https://discord.com/invite/xCa23pwJWY
- GitHub Issues: https://github.com/spotDL/spotify-downloader/issues

---

**Version**: spotDL 4.2.11  
**Last Updated**: June 20, 2025 