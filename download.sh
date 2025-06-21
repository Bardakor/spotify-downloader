#!/bin/bash

# SpotDL Quick Download Script
# Usage: ./download.sh <spotify_url>

# Navigate to the spotify-downloader directory
cd "$(dirname "$0")"

# Activate virtual environment
source venv/bin/activate

# Check if argument is provided
if [ $# -eq 0 ]; then
    echo "SpotDL Quick Download"
    echo "Usage: ./download.sh <spotify_url_or_query>"
    echo ""
    echo "Examples:"
    echo "  ./download.sh 'https://open.spotify.com/track/4iV5W9uYEdYUVa79Axb7Rh'"
    echo "  ./download.sh 'https://open.spotify.com/playlist/37i9dQZF1DXcBWIGoYBM5M'"
    echo "  ./download.sh 'artist:Ed Sheeran track:Shape of You'"
    echo ""
    echo "Downloads will be saved to the downloads/ directory"
    exit 1
fi

# Create downloads directory if it doesn't exist
mkdir -p downloads

# Run spotdl with the provided argument
echo "Starting download..."
spotdl "$1" --output "downloads/{artists} - {title}.{output-ext}"

echo "Download complete! Check the downloads/ directory." 