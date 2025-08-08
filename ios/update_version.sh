#!/bin/bash

# This script updates iOS version information based on pubspec.yaml

# Navigate to the root of your Flutter project
cd "$(dirname "$0")/.."

# Extract version info from pubspec.yaml
VERSION_LINE=$(grep 'version:' pubspec.yaml)
if [[ $VERSION_LINE =~ version:[[:space:]]*(.*)\+(.*) ]]; then
    VERSION_NAME="${BASH_REMATCH[1]}"
    VERSION_CODE="${BASH_REMATCH[2]}"
    
    echo "Found version $VERSION_NAME+$VERSION_CODE in pubspec.yaml"
    
    # Update iOS project version info
    cd ios
    
    # Update all CURRENT_PROJECT_VERSION values in project.pbxproj
    sed -i '' "s/CURRENT_PROJECT_VERSION = [0-9]*;/CURRENT_PROJECT_VERSION = $VERSION_CODE;/g" Runner.xcodeproj/project.pbxproj
    
    # Update MARKETING_VERSION in project.pbxproj if needed
    sed -i '' "s/MARKETING_VERSION = [0-9.]*;/MARKETING_VERSION = $VERSION_NAME;/g" Runner.xcodeproj/project.pbxproj
    
    echo "iOS version info updated successfully!"
else
    echo "Error: Could not parse version from pubspec.yaml"
    exit 1
fi
