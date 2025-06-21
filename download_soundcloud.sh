#!/bin/bash

# SoundCloud Download Script using SpotDL
# Downloads tracks and playlists from SoundCloud

# Navigate to the spotify-downloader directory
cd "$(dirname "$0")"

# Activate virtual environment
source venv/bin/activate

# Check if arguments are provided
if [ $# -eq 0 ]; then
    echo "🔊 SoundCloud Downloader (using SpotDL)"
    echo "Downloads tracks and playlists from SoundCloud"
    echo ""
    echo "Usage: ./download_soundcloud.sh <soundcloud_url1> [url2] [url3] ..."
    echo ""
    echo "Examples:"
    echo "  ./download_soundcloud.sh 'https://soundcloud.com/artist/track-name'"
    echo "  ./download_soundcloud.sh 'https://soundcloud.com/user/sets/playlist-name'"
    echo "  ./download_soundcloud.sh 'https://soundcloud.com/artist/track1' 'https://soundcloud.com/artist/track2'"
    echo ""
    echo "Features:"
    echo "  ✅ Downloads individual tracks"
    echo "  ✅ Downloads entire playlists/sets"
    echo "  ✅ Downloads multiple URLs simultaneously"
    echo "  ✅ High-quality audio with metadata"
    echo "  ✅ Uses SoundCloud as primary audio provider"
    echo "  ✅ Organized file structure"
    echo ""
    echo "Downloads will be saved to: downloads/SoundCloud/"
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

# Function to download from SoundCloud (optimized for playlists)
download_soundcloud() {
    local url="$1"
    local item_num="$2"
    local total_items="$3"
    
    echo "🔊 [$item_num/$total_items] Starting download: $url"
    
    # Check if it's a playlist/set or single track and organize accordingly
    if [[ "$url" == *"/sets/"* ]]; then
        # It's a playlist/set - organize in playlist folder
        echo "📁 [$item_num/$total_items] Detected playlist/set - organizing in separate folder"
        spotdl "$url" \
            --audio soundcloud youtube-music youtube \
            --output "downloads/SoundCloud/{list-name}/{artists} - {title}.{output-ext}" \
            --format mp3
    else
        # It's a single track - put in main SoundCloud folder
        echo "🎵 [$item_num/$total_items] Detected single track"
        spotdl "$url" \
            --audio soundcloud youtube-music youtube \
            --output "downloads/SoundCloud/{artists} - {title}.{output-ext}" \
            --format mp3
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
echo "🎵 Single tracks will be saved to: downloads/SoundCloud/"
echo "🎵 Using SoundCloud as primary audio provider"
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
        echo "🚀 Starting playlist download $item_num/$total_items: $url"
    else
        echo "🚀 Starting track download $item_num/$total_items: $url"
    fi
    download_soundcloud "$url" "$item_num" "$total_items" &
    pids+=($!)
    item_num=$((item_num + 1))
    # Small delay to avoid overwhelming the system
    sleep 2
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
echo "   🎵 Single tracks: downloads/SoundCloud/"
echo ""
echo "🔊 Audio provider priority used: SoundCloud → YouTube Music → YouTube"
echo "✅ Script execution complete - all downloads finished!" 