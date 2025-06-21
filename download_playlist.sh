#!/bin/bash

# SpotDL Multiple Playlist Download Script
# Downloads multiple playlists simultaneously into individual folders named after each playlist

# Navigate to the spotify-downloader directory
cd "$(dirname "$0")"

# Activate virtual environment
source venv/bin/activate

# Check if arguments are provided
if [ $# -eq 0 ]; then
    echo "🎵 SpotDL Multiple Playlist Downloader"
    echo "Downloads multiple playlists simultaneously into folders named after each playlist"
    echo ""
    echo "Usage: ./download_playlist.sh <spotify_playlist_url1> [playlist_url2] [playlist_url3] ..."
    echo ""
    echo "Examples:"
    echo "  ./download_playlist.sh 'https://open.spotify.com/playlist/37i9dQZF1DXcBWIGoYBM5M'"
    echo "  ./download_playlist.sh 'https://open.spotify.com/playlist/ID1' 'https://open.spotify.com/playlist/ID2'"
    echo "  ./download_playlist.sh playlist1_url playlist2_url playlist3_url"
    echo ""
    echo "Features:"
    echo "  ✅ Downloads multiple playlists simultaneously"
    echo "  ✅ Creates separate folder for each playlist"
    echo "  ✅ Downloads all tracks with metadata and album art"
    echo "  ✅ Skips already downloaded files"
    echo "  ✅ Shows progress for each playlist"
    echo ""
    echo "Downloads will be saved to: downloads/[Playlist Name]/"
    exit 1
fi

# Function to validate Spotify playlist URL
validate_url() {
    if [[ ! "$1" == *"open.spotify.com/playlist/"* ]]; then
        echo "❌ Error: Invalid Spotify playlist URL: $1"
        echo "   Example: https://open.spotify.com/playlist/37i9dQZF1DXcBWIGoYBM5M"
        return 1
    fi
    return 0
}

# Function to download a single playlist
download_playlist() {
    local url="$1"
    local playlist_num="$2"
    local total_playlists="$3"
    
    echo "🎵 [$playlist_num/$total_playlists] Starting download for playlist: $url"
    
    # Download playlist organized in playlist folder
    spotdl "$url" --output "downloads/{list-name}/{artists} - {title}.{output-ext}"
    
    if [ $? -eq 0 ]; then
        echo "✅ [$playlist_num/$total_playlists] Playlist download complete: $url"
    else
        echo "❌ [$playlist_num/$total_playlists] Download failed for: $url"
    fi
}

# Validate all URLs first
echo "🔍 Validating playlist URLs..."
for url in "$@"; do
    if ! validate_url "$url"; then
        exit 1
    fi
done

# Create downloads directory if it doesn't exist
mkdir -p downloads

echo ""
echo "🎵 Starting download of $# playlist(s)..."
echo "📁 Each playlist will be saved in its own folder"
echo "⚡ Downloads will run in parallel for faster completion"
echo ""

# Array to store background process IDs
pids=()
playlist_num=1
total_playlists=$#

# Start downloads in parallel
for url in "$@"; do
    echo "🚀 Starting download $playlist_num/$total_playlists: $url"
    download_playlist "$url" "$playlist_num" "$total_playlists" &
    pids+=($!)
    playlist_num=$((playlist_num + 1))
    # Small delay to avoid overwhelming the system
    sleep 2
done

echo ""
echo "⏳ All downloads started! Waiting for completion..."
echo "💡 You can check the downloads/ directory to see progress"
echo ""

# Wait for all background processes to complete
failed_count=0
for pid in "${pids[@]}"; do
    if ! wait "$pid"; then
        failed_count=$((failed_count + 1))
    fi
done

echo ""
echo "🏁 All downloads completed!"
echo "📁 Check the downloads/ directory for your playlist folders"

if [ $failed_count -eq 0 ]; then
    echo "✅ All $total_playlists playlist(s) downloaded successfully!"
else
    echo "⚠️  $failed_count out of $total_playlists playlist(s) failed to download"
    echo "   Please check the error messages above and try again for failed playlists"
fi

echo ""
echo "🎵 Files are organized in separate folders for each playlist" 