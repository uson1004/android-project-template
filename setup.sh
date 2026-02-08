#!/bin/bash

# Android Project Template Setup
# Usage: ./setup.sh
# This script changes package names, app name, and directory structure

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Detect current values from actual source directory structure
detect_current_values() {
    # Detect app package from actual source directory (find first .kt file and extract path)
    local app_kt_file=$(find app/src/main/java -name "*.kt" -type f 2>/dev/null | head -1)
    if [[ -n "$app_kt_file" ]]; then
        # Extract package path: app/src/main/java/com/example/myapp/File.kt -> com/example/myapp
        local pkg_path=$(dirname "$app_kt_file" | sed 's|app/src/main/java/||')
        OLD_APP_PACKAGE=$(echo "$pkg_path" | tr '/' '.')
    fi

    # Detect designsystem package from actual source directory
    local ds_kt_file=$(find core/designsystem/src/main/java -name "*.kt" -type f 2>/dev/null | head -1)
    if [[ -n "$ds_kt_file" ]]; then
        local ds_pkg_path=$(dirname "$ds_kt_file" | sed 's|core/designsystem/src/main/java/||')
        # Get base package (remove subpackages like ui/theme)
        OLD_DESIGNSYSTEM_PACKAGE=$(echo "$ds_pkg_path" | tr '/' '.' | sed 's/\.ui\..*$//' | sed 's/\.utils$//')
    fi

    # Detect core package from actual source directory
    local core_kt_file=$(find core/network/src/main/java -name "*.kt" -type f 2>/dev/null | head -1)
    if [[ -n "$core_kt_file" ]]; then
        local core_pkg_path=$(dirname "$core_kt_file" | sed 's|core/network/src/main/java/||')
        # Remove .network suffix to get base core package
        OLD_CORE_PACKAGE=$(echo "$core_pkg_path" | tr '/' '.' | sed 's/\.network$//')
    fi

    # Detect app name from settings.gradle.kts
    OLD_APP_NAME=$(grep -E 'rootProject\.name\s*=' settings.gradle.kts 2>/dev/null | sed 's/.*"\(.*\)".*/\1/')

    # Detect display name from strings.xml
    OLD_APP_DISPLAY_NAME=$(grep -E '<string name="app_name">' app/src/main/res/values/strings.xml 2>/dev/null | sed 's/.*>\(.*\)<.*/\1/')

    # Detect theme name from Theme.kt
    local theme_file=$(find core/designsystem/src/main/java -name "Theme.kt" -type f 2>/dev/null | head -1)
    if [[ -n "$theme_file" ]]; then
        OLD_THEME_NAME=$(grep -oE '[A-Z][a-zA-Z]*Theme' "$theme_file" 2>/dev/null | head -1 | sed 's/Theme$//')
    fi
    if [[ -z "$OLD_THEME_NAME" ]]; then
        OLD_THEME_NAME="$OLD_APP_NAME"
    fi

    # Also detect gradle namespace for updating gradle files
    OLD_GRADLE_APP_NAMESPACE=$(grep -E 'namespace\s*=' app/build.gradle.kts 2>/dev/null | head -1 | sed 's/.*"\(.*\)".*/\1/')
    OLD_GRADLE_DS_NAMESPACE=$(grep -E 'namespace\s*=' core/designsystem/build.gradle.kts 2>/dev/null | head -1 | sed 's/.*"\(.*\)".*/\1/')
    OLD_GRADLE_CORE_NAMESPACE=$(grep -E 'namespace\s*=' core/network/build.gradle.kts 2>/dev/null | head -1 | sed 's/.*"\(.*\)".*/\1/' | sed 's/\.network$//')
}

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[OK]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Read input with protected prompt (backspace cannot delete prompt)
read_protected() {
    local prompt="$1"
    local result=""
    local char

    echo -n "$prompt" >&2

    while IFS= read -r -s -n1 char; do
        if [[ $char == $'\177' || $char == $'\b' ]]; then
            # Backspace - only delete if input is not empty
            if [[ -n "$result" ]]; then
                result="${result%?}"
                echo -ne "\b \b" >&2
            fi
        elif [[ $char == "" ]]; then
            # Enter
            echo >&2
            break
        else
            result+="$char"
            echo -n "$char" >&2
        fi
    done

    echo "$result"
}

print_banner() {
    echo ""
    echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║   Android Project Template Setup           ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}"
    echo ""
}

validate_package() {
    if [[ ! $1 =~ ^[a-z][a-z0-9]*(\.[a-z][a-z0-9]*)+$ ]]; then
        log_error "Invalid package: $1"
        log_info "Format: com.example.myapp (lowercase, 2+ segments)"
        return 1
    fi
    return 0
}

package_to_path() {
    echo "$1" | tr '.' '/'
}

# Convert PascalCase to kebab-case (e.g., MyNewApp -> my-new-app)
# macOS BSD sed doesn't support \L, so use tr for lowercase conversion
to_kebab_case() {
    echo "$1" | sed 's/\([A-Z]\)/-\1/g' | sed 's/^-//' | tr '[:upper:]' '[:lower:]'
}

# Replace in file (compatible with both macOS and Linux)
replace_in_file() {
    local file="$1"
    local old="$2"
    local new="$3"

    if [[ -f "$file" ]]; then
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i '' "s|$old|$new|g" "$file"
        else
            sed -i "s|$old|$new|g" "$file"
        fi
    fi
}

# Replace in all matching files
replace_in_files() {
    local pattern="$1"
    local old="$2"
    local new="$3"

    find . -type f -name "$pattern" | while read -r file; do
        replace_in_file "$file" "$old" "$new"
    done
}

# Remove empty directories recursively up to base
cleanup_empty_dirs() {
    local dir="$1"
    local base="$2"

    while [[ "$dir" != "$base" && -d "$dir" ]]; do
        if [[ -z "$(ls -A "$dir" 2>/dev/null)" ]]; then
            rmdir "$dir" 2>/dev/null || break
            dir=$(dirname "$dir")
        else
            break
        fi
    done
}

# Move source directory to new location
move_source_directory() {
    local base_dir="$1"
    local old_pkg_path="$2"
    local new_pkg_path="$3"
    local description="$4"

    # Skip if source and destination are the same
    if [[ "$old_pkg_path" == "$new_pkg_path" ]]; then
        log_info "$description: No change needed"
        return 0
    fi

    local src="$base_dir/$old_pkg_path"
    local dst="$base_dir/$new_pkg_path"

    if [[ -d "$src" ]]; then
        # Create destination directory
        mkdir -p "$dst"

        # Copy all contents
        if [[ -n "$(ls -A "$src" 2>/dev/null)" ]]; then
            cp -R "$src"/. "$dst"/
        fi

        # Remove old directory
        rm -rf "$src"

        # Cleanup empty parent directories
        cleanup_empty_dirs "$(dirname "$src")" "$base_dir"

        log_success "$description: $old_pkg_path -> $new_pkg_path"
        return 0
    else
        log_warn "$description: Source not found ($src)"
        return 1
    fi
}

main() {
    # Check if running from project root
    if [[ ! -f "settings.gradle.kts" ]]; then
        log_error "Run this script from project root directory"
        exit 1
    fi

    # Auto-detect current project values
    detect_current_values

    if [[ -z "$OLD_APP_PACKAGE" ]]; then
        log_error "Could not detect app package from app/build.gradle.kts"
        exit 1
    fi

    print_banner

    # Show current values
    echo "Detected Values:"
    echo "  App Package (source): $OLD_APP_PACKAGE"
    echo "  Core Package (source): $OLD_CORE_PACKAGE"
    echo "  App Name: $OLD_APP_NAME"
    echo ""

    # Get new package name
    while true; do
        NEW_APP_PACKAGE=$(read_protected "Enter new app package (e.g., com.example.myapp): ")
        if validate_package "$NEW_APP_PACKAGE"; then
            if [[ "$NEW_APP_PACKAGE" == "$OLD_APP_PACKAGE" ]]; then
                log_warn "Same as current package. Enter a different package."
                continue
            fi
            break
        fi
    done

    # Derive other packages (all based on app package)
    NEW_CORE_PACKAGE="${NEW_APP_PACKAGE}.core"
    NEW_DESIGNSYSTEM_PACKAGE="${NEW_APP_PACKAGE}.designsystem"

    # Get new app name
    while true; do
        NEW_APP_NAME=$(read_protected "Enter new app name (e.g., MyNewApp): ")
        if [[ -z "$NEW_APP_NAME" ]]; then
            log_warn "App name cannot be empty."
            continue
        fi
        if [[ "$NEW_APP_NAME" == "$OLD_APP_NAME" ]]; then
            log_warn "Same as current app name. Enter a different name."
            continue
        fi
        break
    done

    # Create display name
    NEW_APP_DISPLAY_NAME=$(echo "$NEW_APP_NAME" | sed 's/\([A-Z]\)/ \1/g' | sed 's/^ //')

    echo ""
    echo "New Values:"
    echo "  App Package: $NEW_APP_PACKAGE"
    echo "  Core Package: $NEW_CORE_PACKAGE.*"
    echo "  Designsystem Package: $NEW_DESIGNSYSTEM_PACKAGE"
    echo "  App Name: $NEW_APP_NAME"
    echo "  Display Name: $NEW_APP_DISPLAY_NAME"
    echo ""

    confirm=$(read_protected "Proceed? (y/n): ")
    if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
        log_warn "Cancelled"
        exit 0
    fi

    echo ""
    log_info "Starting setup..."
    echo ""

    # Calculate paths
    OLD_APP_PATH=$(package_to_path "$OLD_APP_PACKAGE")
    NEW_APP_PATH=$(package_to_path "$NEW_APP_PACKAGE")
    OLD_DS_PATH=$(package_to_path "$OLD_DESIGNSYSTEM_PACKAGE")
    NEW_DS_PATH=$(package_to_path "$NEW_DESIGNSYSTEM_PACKAGE")
    OLD_CORE_PATH=$(package_to_path "$OLD_CORE_PACKAGE")
    NEW_CORE_PATH=$(package_to_path "$NEW_CORE_PACKAGE")

    # ========================================
    # 1. Move source directories FIRST
    # ========================================
    log_info "Moving source directories..."

    # App module (main, androidTest, test)
    for src_type in main androidTest test; do
        local base="app/src/$src_type/java"
        if [[ -d "$base" ]]; then
            move_source_directory "$base" "$OLD_APP_PATH" "$NEW_APP_PATH" "app/$src_type"
        fi
    done

    # Designsystem module
    move_source_directory "core/designsystem/src/main/java" "$OLD_DS_PATH" "$NEW_DS_PATH" "designsystem"

    # Core modules (network, domain, data, common, local)
    for module in network domain data common local; do
        local core_base="core/$module/src/main/java"
        if [[ -d "$core_base" ]]; then
            # Old path: com/seunghoon/core/network -> New path: com/example/myapp/core/network
            move_source_directory "$core_base" "$OLD_CORE_PATH/$module" "$NEW_CORE_PATH/$module" "core/$module"
        fi
    done

    # ========================================
    # 2. Update package declarations in source files
    # ========================================
    log_info "Updating package declarations in source files..."

    find . -type f \( -name "*.kt" -o -name "*.java" \) | while read -r file; do
        # App package
        replace_in_file "$file" "package $OLD_APP_PACKAGE" "package $NEW_APP_PACKAGE"
        replace_in_file "$file" "import $OLD_APP_PACKAGE" "import $NEW_APP_PACKAGE"

        # Designsystem package
        replace_in_file "$file" "package $OLD_DESIGNSYSTEM_PACKAGE" "package $NEW_DESIGNSYSTEM_PACKAGE"
        replace_in_file "$file" "import $OLD_DESIGNSYSTEM_PACKAGE" "import $NEW_DESIGNSYSTEM_PACKAGE"

        # Core package (handles all core submodules)
        replace_in_file "$file" "package $OLD_CORE_PACKAGE" "package $NEW_CORE_PACKAGE"
        replace_in_file "$file" "import $OLD_CORE_PACKAGE" "import $NEW_CORE_PACKAGE"

        # Theme/App composable names
        replace_in_file "$file" "${OLD_THEME_NAME}Theme" "${NEW_APP_NAME}Theme"
        replace_in_file "$file" "${OLD_THEME_NAME}App" "${NEW_APP_NAME}App"
    done
    log_success "Updated package declarations"

    # ========================================
    # 3. Update Gradle files
    # ========================================
    log_info "Updating Gradle files..."

    # app/build.gradle.kts
    replace_in_file "app/build.gradle.kts" \
        "namespace = \"$OLD_GRADLE_APP_NAMESPACE\"" \
        "namespace = \"$NEW_APP_PACKAGE\""
    replace_in_file "app/build.gradle.kts" \
        "applicationId = \"$OLD_GRADLE_APP_NAMESPACE\"" \
        "applicationId = \"$NEW_APP_PACKAGE\""
    log_success "Updated app/build.gradle.kts"

    # core modules
    for module in designsystem network domain data common local; do
        local file="core/$module/build.gradle.kts"
        if [[ -f "$file" ]]; then
            if [[ "$module" == "designsystem" ]]; then
                replace_in_file "$file" \
                    "namespace = \"$OLD_GRADLE_DS_NAMESPACE\"" \
                    "namespace = \"$NEW_DESIGNSYSTEM_PACKAGE\""
            else
                replace_in_file "$file" \
                    "namespace = \"$OLD_GRADLE_CORE_NAMESPACE.$module\"" \
                    "namespace = \"$NEW_CORE_PACKAGE.$module\""
            fi
            log_success "Updated core/$module/build.gradle.kts"
        fi
    done

    # settings.gradle.kts
    replace_in_file "settings.gradle.kts" \
        "rootProject.name = \"$OLD_APP_NAME\"" \
        "rootProject.name = \"$NEW_APP_NAME\""
    log_success "Updated settings.gradle.kts"

    # ========================================
    # 4. Update resource files
    # ========================================
    log_info "Updating resource files..."

    # strings.xml
    replace_in_file "app/src/main/res/values/strings.xml" \
        "<string name=\"app_name\">$OLD_APP_DISPLAY_NAME</string>" \
        "<string name=\"app_name\">$NEW_APP_DISPLAY_NAME</string>"
    log_success "Updated strings.xml"

    # Theme references in XML files
    replace_in_files "*.xml" "Theme.$OLD_THEME_NAME" "Theme.$NEW_APP_NAME"
    log_success "Updated theme references"

    # ========================================
    # 5. Rename files
    # ========================================
    log_info "Renaming files..."

    # Rename ProjectGeneratorApp.kt -> {NewAppName}App.kt
    local old_app_kt=$(find . -name "${OLD_THEME_NAME}App.kt" -type f 2>/dev/null | head -1)
    if [[ -n "$old_app_kt" ]]; then
        local dir=$(dirname "$old_app_kt")
        mv "$old_app_kt" "$dir/${NEW_APP_NAME}App.kt"
        log_success "Renamed ${OLD_THEME_NAME}App.kt -> ${NEW_APP_NAME}App.kt"
    fi

    # ========================================
    # 6. Rename project root directory
    # ========================================
    log_info "Renaming project directory..."

    local CURRENT_DIR=$(pwd)
    local PARENT_DIR=$(dirname "$CURRENT_DIR")
    local NEW_PROJECT_DIR_NAME=$(to_kebab_case "$NEW_APP_NAME")
    local NEW_PROJECT_DIR="$PARENT_DIR/$NEW_PROJECT_DIR_NAME"

    if [[ "$CURRENT_DIR" != "$NEW_PROJECT_DIR" ]]; then
        cd "$PARENT_DIR"
        mv "$CURRENT_DIR" "$NEW_PROJECT_DIR"
        log_success "Renamed project directory: $(basename "$CURRENT_DIR") -> $NEW_PROJECT_DIR_NAME"
        cd "$NEW_PROJECT_DIR"
    fi

    # ========================================
    # Done
    # ========================================
    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║   Setup Complete!                          ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════╝${NC}"
    echo ""
    echo "Project location: $NEW_PROJECT_DIR"
    echo ""
    echo "Next steps:"
    echo "  1. cd $NEW_PROJECT_DIR"
    echo "  2. Open project in Android Studio"
    echo "  3. Sync Gradle and build"
    echo ""
}

main "$@"