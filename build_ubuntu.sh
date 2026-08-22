SUPERFILE_VERSION=$1
BUILD_VERSION=$2
ARCH=${3:-amd64}  # Default to amd64 if no architecture specified

if [ -z "$SUPERFILE_VERSION" ] || [ -z "$BUILD_VERSION" ]; then
    echo "Usage: $0 <superfile_version> <build_version> [architecture]"
    echo "Example: $0 1.6.0 1 arm64"
    echo "Example: $0 1.6.0 1 all    # Build for all architectures"
    echo "Supported architectures: amd64, arm64, all"
    exit 1
fi

# Upstream tags carry a "v" prefix (e.g. v1.6.0), and so do the asset names.
UPSTREAM_URL="https://github.com/yorukot/superfile/releases/download/v${SUPERFILE_VERSION}"

# Function to map Debian architecture to the superfile release asset name.
# Upstream names its Linux assets after the Go architecture spelling, which
# happens to match Debian's for the two architectures it publishes. Both are
# statically linked Go binaries, so they run on every suite we target and need
# no library dependencies.
get_superfile_release() {
    local arch=$1
    case "$arch" in
        "amd64") echo "superfile-linux-v${SUPERFILE_VERSION}-amd64" ;;
        "arm64") echo "superfile-linux-v${SUPERFILE_VERSION}-arm64" ;;
        *)       echo "" ;;
    esac
}

# The release tarballs nest the binary under "./dist/<asset-name>/", so the
# binary is hoisted straight into a directory we create. The leading "./"
# counts as a path component, hence --strip-components=3.
download_release() {
    local release=$1

    rm -rf "$release" || true
    rm -f "${release}.tar.gz" || true

    if ! wget -q "${UPSTREAM_URL}/${release}.tar.gz"; then
        echo "❌ Failed to download ${release}.tar.gz"
        return 1
    fi

    mkdir -p "$release"
    if ! tar -xf "${release}.tar.gz" -C "$release" --strip-components=3; then
        echo "❌ Failed to extract ${release}.tar.gz"
        return 1
    fi
    rm -f "${release}.tar.gz"

    if [ ! -f "$release/spf" ]; then
        echo "❌ Unexpected tarball layout for $release (missing spf binary)"
        return 1
    fi
    chmod +x "$release/spf"
}

# Function to build for a specific architecture
build_architecture() {
    local build_arch=$1
    local superfile_release

    superfile_release=$(get_superfile_release "$build_arch")
    if [ -z "$superfile_release" ]; then
        echo "❌ Unsupported architecture: $build_arch"
        echo "Supported architectures: amd64, arm64"
        return 1
    fi

    echo "Building for architecture: $build_arch using $superfile_release"

    if ! download_release "$superfile_release"; then
        echo "❌ Failed to prepare superfile binary for $build_arch"
        return 1
    fi

    # Upstream ships static Linux binaries for amd64/arm64 only, and both work
    # on every Ubuntu suite we target.
    declare -a arr=("jammy" "noble" "questing" "resolute")

    for dist in "${arr[@]}"; do
        FULL_VERSION="$SUPERFILE_VERSION-${BUILD_VERSION}~${dist}_${build_arch}_ubu"
        echo "  Building $FULL_VERSION"

        if ! docker build . -f Dockerfile.ubu -t "superfile-ubuntu-$dist-$build_arch" \
            --build-arg UBUNTU_DIST="$dist" \
            --build-arg SUPERFILE_VERSION="$SUPERFILE_VERSION" \
            --build-arg BUILD_VERSION="$BUILD_VERSION" \
            --build-arg FULL_VERSION="$FULL_VERSION" \
            --build-arg ARCH="$build_arch" \
            --build-arg SPF_RELEASE="$superfile_release"; then
            echo "❌ Failed to build Docker image for $dist on $build_arch"
            return 1
        fi

        id="$(docker create "superfile-ubuntu-$dist-$build_arch")"
        if ! docker cp "$id:/superfile_$FULL_VERSION.deb" - > "./superfile_$FULL_VERSION.deb"; then
            echo "❌ Failed to extract .deb package for $dist on $build_arch"
            return 1
        fi

        if ! tar -xf "./superfile_$FULL_VERSION.deb"; then
            echo "❌ Failed to extract .deb contents for $dist on $build_arch"
            return 1
        fi
    done

    # Clean up extracted directory
    rm -rf "$superfile_release" || true

    echo "✅ Successfully built for $build_arch"
    return 0
}

# Main build logic
if [ "$ARCH" = "all" ]; then
    echo "🚀 Building superfile $SUPERFILE_VERSION-$BUILD_VERSION for all supported architectures..."
    echo ""

    # All supported architectures
    ARCHITECTURES=("amd64" "arm64")

    for build_arch in "${ARCHITECTURES[@]}"; do
        echo "==========================================="
        echo "Building for architecture: $build_arch"
        echo "==========================================="

        if ! build_architecture "$build_arch"; then
            echo "❌ Failed to build for $build_arch"
            exit 1
        fi

        echo ""
    done

    echo "🎉 All architectures built successfully!"
    echo "Generated packages:"
    ls -la superfile_*.deb
else
    # Build for single architecture
    if ! build_architecture "$ARCH"; then
        exit 1
    fi
fi
