#!/bin/bash

# Fix SoundCloud file names - Remove playlist prefix from all files
# This script removes the "PLAYLISTNAME_" prefix from all files in SoundCloud subfolders

# Navigate to the spotify-downloader directory
cd "$(dirname "$0")"

echo "🔧 SoundCloud Filename Fixer"
echo "Removing playlist prefixes from all SoundCloud files..."
echo ""

# Check if SoundCloud directory exists
if [ ! -d "downloads/SoundCloud" ]; then
    echo "❌ No SoundCloud downloads directory found."
    echo "   Expected: downloads/SoundCloud/"
    exit 1
fi

# Counter for renamed files
renamed_count=0
total_files=0

# Function to rename files in a directory
rename_files_in_dir() {
    local dir="$1"
    local playlist_name=$(basename "$dir")
    
    echo "📁 Processing folder: $playlist_name"
    
    # Find all audio files in this directory
    find "$dir" -maxdepth 1 -type f \( -name "*.mp3" -o -name "*.m4a" -o -name "*.wav" -o -name "*.flac" \) | while read -r file; do
        filename=$(basename "$file")
        total_files=$((total_files + 1))
        
        # Check if filename contains underscore (indicating playlist prefix)
        if [[ "$filename" == *"_"* ]]; then
            # Extract everything after the last underscore (handles multiple underscores)
            new_name=$(echo "$filename" | sed 's/.*_//')
            
            # Only rename if the new name is different and not empty
            if [ "$new_name" != "$filename" ] && [ -n "$new_name" ] && [ ${#new_name} -gt 4 ]; then
                new_path="$dir/$new_name"
                
                # Check if target file already exists
                if [ -f "$new_path" ]; then
                    echo "   ⚠️  Skipping: $new_name (file already exists)"
                else
                    mv "$file" "$new_path"
                    echo "   ✅ Renamed: $(basename "$filename") → $new_name"
                    renamed_count=$((renamed_count + 1))
                fi
            else
                echo "   ➡️  Skipping: $(basename "$filename") (no valid prefix to remove)"
            fi
        else
            echo "   ➡️  Skipping: $(basename "$filename") (no underscore found)"
        fi
    done
}

# Process all subdirectories in SoundCloud folder (including nested ones)
find downloads/SoundCloud -mindepth 1 -type d | while read -r subdir; do
    if [ -d "$subdir" ]; then
        # Check if this directory contains audio files
        audio_count=$(find "$subdir" -maxdepth 1 -type f \( -name "*.mp3" -o -name "*.m4a" -o -name "*.wav" -o -name "*.flac" \) | wc -l)
        if [ "$audio_count" -gt 0 ]; then
            rename_files_in_dir "$subdir"
            echo ""
        fi
    fi
done

echo "🏁 Filename fixing complete!"
echo ""

# Count total files after processing
total_audio_files=$(find downloads/SoundCloud -type f \( -name "*.mp3" -o -name "*.m4a" -o -name "*.wav" -o -name "*.flac" \) | wc -l)

echo "📊 SUMMARY:"
echo "📁 Total audio files found: $total_audio_files"
echo "✅ Files renamed: $renamed_count"
echo ""
echo "🎵 All SoundCloud files now have clean names!"
echo "📁 Check downloads/SoundCloud/ to see the results" 