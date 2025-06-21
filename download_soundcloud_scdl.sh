#!/bin/bash

# SoundCloud Download Script using SCDL (dedicated SoundCloud downloader)
# Downloads tracks and playlists from SoundCloud with proper organization

# Navigate to the spotify-downloader directory
cd "$(dirname "$0")"

# Activate virtual environment
source venv/bin/activate

# Check if arguments are provided
if [ $# -eq 0 ]; then
    echo "🔊 SoundCloud Downloader (using SCDL)"
    echo "Downloads tracks and playlists from SoundCloud with perfect quality"
    echo ""
    echo "Usage: ./download_soundcloud_scdl.sh <soundcloud_url1> [url2] [url3] ..."
    echo ""
    echo "Examples:"
    echo "  ./download_soundcloud_scdl.sh 'https://soundcloud.com/artist/track-name'"
    echo "  ./download_soundcloud_scdl.sh 'https://soundcloud.com/user/sets/playlist-name'"
    echo "  ./download_soundcloud_scdl.sh 'https://soundcloud.com/artist/track1' 'https://soundcloud.com/artist/track2'"
    echo ""
    echo "Features:"
    echo "  ✅ Downloads individual tracks"
    echo "  ✅ Downloads entire playlists/sets"
    echo "  ✅ Downloads multiple URLs simultaneously"
    echo "  ✅ High-quality audio directly from SoundCloud"
    echo "  ✅ Perfect metadata and organization"
    echo "  ✅ Each playlist gets its own folder"
    echo ""
    echo "Downloads will be saved to: downloads/SoundCloud/[Playlist Name]/"
    exit 1
fi

# Function to validate SoundCloud URL
validate_url() {
    if [[ ! "$1" == *"soundcloud.com/"* ]]; then
        echo "❌ Error: Invalid SoundCloud URL: $1"
        echo "   Example: https://soundcloud.com/artist/track-name"
        return 1
    fi
    return 0
}

# Function to extract playlist name from URL
get_playlist_name() {
    local url="$1"
    # Extract the playlist name from the URL
    if [[ "$url" == *"/sets/"* ]]; then
        # Extract playlist name from URL like: /sets/playlist-name
        playlist_name=$(echo "$url" | sed 's/.*\/sets\///' | sed 's/\?.*$//')
        # Convert dashes to spaces and capitalize
        playlist_name=$(echo "$playlist_name" | sed 's/-/ /g' | sed 's/\b\w/\U&/g')
        echo "$playlist_name"
    else
        echo "Single-Tracks"
    fi
}

# Function to download from SoundCloud using scdl
download_soundcloud() {
    local url="$1"
    local item_num="$2"
    local total_items="$3"
    
    echo "🔊 [$item_num/$total_items] Starting download: $url"
    
    if [[ "$url" == *"/sets/"* ]]; then
        # It's a playlist/set - organize in playlist folder
        playlist_name=$(get_playlist_name "$url")
        echo "📁 [$item_num/$total_items] Detected playlist: $playlist_name"
        
        # Create directory for playlist
        mkdir -p "downloads/SoundCloud/$playlist_name"
        
        # Download playlist using scdl with clean naming
        scdl -l "$url" --path "downloads/SoundCloud/$playlist_name/" --original-art --name-format "{title}"
        
    else
        # It's a single track - put in Single-Tracks folder
        echo "🎵 [$item_num/$total_items] Detected single track"
        
        # Create directory for single tracks
        mkdir -p "downloads/SoundCloud/Single-Tracks"
        
        # Download single track using scdl with clean naming
        scdl -l "$url" --path "downloads/SoundCloud/Single-Tracks/" --original-art --name-format "{title}"
    fi
    
    if [ $? -eq 0 ]; then
        echo "✅ [$item_num/$total_items] Download complete: $url"
        return 0
    else
        echo "❌ [$item_num/$total_items] Download failed: $url"
        return 1
    fi
}

# Validate all URLs first
echo "🔍 Validating SoundCloud URLs..."
for url in "$@"; do
    if ! validate_url "$url"; then
        exit 1
    fi
done

# Create downloads directory if it doesn't exist
mkdir -p downloads/SoundCloud

echo ""
echo "🔊 Starting download of $# SoundCloud item(s)..."
echo "📁 Playlists will be saved in separate folders: downloads/SoundCloud/[Playlist Name]/"
echo "🎵 Single tracks will be saved to: downloads/SoundCloud/Single-Tracks/"
echo "🎵 Using SCDL - dedicated SoundCloud downloader"
echo "⚡ Downloads will run in parallel for faster completion"
echo "⏰ Script will wait for ALL downloads to complete before finishing"
echo ""

# Array to store background process IDs
pids=()
item_num=1
total_items=$#

# Start downloads in parallel
for url in "$@"; do
    if [[ "$url" == *"/sets/"* ]]; then
        playlist_name=$(get_playlist_name "$url")
        echo "🚀 Starting playlist download $item_num/$total_items: $playlist_name"
    else
        echo "🚀 Starting track download $item_num/$total_items: $url"
    fi
    download_soundcloud "$url" "$item_num" "$total_items" &
    pids+=($!)
    item_num=$((item_num + 1))
    # Small delay to avoid overwhelming SoundCloud
    sleep 3
done

echo ""
echo "⏳ All $total_items download(s) started! Waiting for ALL to complete..."
echo "💡 You can check the downloads/SoundCloud/ directory to see progress"
echo "🛑 The script will NOT exit until all downloads are finished"
echo ""

# Wait for all background processes to complete and track results
failed_count=0
completed_count=0

echo "📊 Monitoring download progress..."
for i in "${!pids[@]}"; do
    pid=${pids[$i]}
    item_number=$((i + 1))
    
    echo "⏳ Waiting for download $item_number/$total_items to complete (PID: $pid)..."
    
    if wait "$pid"; then
        completed_count=$((completed_count + 1))
        echo "✅ Download $item_number/$total_items completed successfully!"
    else
        failed_count=$((failed_count + 1))
        echo "❌ Download $item_number/$total_items failed!"
    fi
done

echo ""
echo "🏁 All downloads completed! Script finishing now."
echo "📁 Check the downloads/SoundCloud/ directory for your files"

# Final summary
echo ""
echo "📊 FINAL DOWNLOAD SUMMARY:"
echo "✅ Successfully completed: $completed_count/$total_items"
echo "❌ Failed downloads: $failed_count/$total_items"

if [ $failed_count -eq 0 ]; then
    echo ""
    echo "🎉 ALL $total_items SoundCloud item(s) downloaded successfully!"
    echo "🎵 No errors encountered!"
else
    echo ""
    echo "⚠️  $failed_count out of $total_items item(s) failed to download"
    echo "   Please check the error messages above and try again for failed items"
fi

echo ""
echo "📁 File locations:"
echo "   📂 Playlists: downloads/SoundCloud/[Playlist Name]/"
echo "   🎵 Single tracks: downloads/SoundCloud/Single-Tracks/"
echo ""
echo "🔊 Using SCDL - Direct SoundCloud downloads with perfect quality!"
echo "✅ Script execution complete - all downloads finished!" 