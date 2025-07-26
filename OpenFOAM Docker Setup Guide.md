# OpenFOAM Docker Setup Guide

This guide provides instructions for running OpenFOAM using Docker on macOS.

## What is OpenFOAM?

OpenFOAM (Open Field Operation and Manipulation) is a free, open-source computational fluid dynamics (CFD) software package. It has an extensive range of features to solve complex fluid flows involving chemical reactions, turbulence, heat transfer, solid dynamics, and electromagnetics.

## Docker Images for OpenFOAM

There are two main sources for official OpenFOAM Docker images:

1. **OpenFOAM Foundation** - https://hub.docker.com/u/openfoam
2. **OpenCFD Ltd.** - https://hub.docker.com/u/opencfd

### OpenCFD Docker Images

OpenCFD provides three main Docker image variants:

- **openfoam-run**: A small-footprint runtime-only image
- **openfoam-dev**: Runtime with OpenFOAM development environment
- **openfoam-default**: Complete "just-give-me-everything" image

The latest images use Ubuntu LTS as the base operating system.

## Running OpenFOAM with Docker on macOS

### Prerequisites

1. Install Docker Desktop for macOS from the [official Docker website](https://www.docker.com/products/docker-desktop/)
2. Ensure Docker has sufficient resources allocated (recommended: at least 4GB RAM, 2 CPUs)

### Method 1: Using the openfoam-docker Script (Recommended)

The recommended approach is to use the `openfoam-docker` script:

1. Download the [openfoam-docker](https://develop.openfoam.com/Development/openfoam/-/raw/master/bin/tools/openfoam-docker) script
2. Make it executable and place it in your PATH:
   ```bash
   chmod +x openfoam-docker
   mv openfoam-docker ~/bin/  # or another directory in your PATH
   ```
3. Create symbolic links for specific OpenFOAM versions:
   ```bash
   ln -sf openfoam-docker openfoam2406-run
   ```
4. Run OpenFOAM interactively:
   ```bash
   openfoam-docker
   ```
   
   Or with a specific version:
   ```bash
   openfoam-docker -2412
   ```

This will open an interactive shell with the OpenFOAM environment active, with your current local directory mounted within the container.

### Method 2: Direct Docker Commands

You can also run OpenFOAM directly with Docker commands:

```bash
# Pull the latest OpenFOAM image
docker pull opencfd/openfoam-default:latest

# Run OpenFOAM with the current directory mounted
docker run -it --rm -v "$(pwd):/home/openfoam/workingDir" opencfd/openfoam-default
```

## Running Commands Non-interactively

You can run OpenFOAM commands without entering an interactive shell:

```bash
# Using the openfoam-docker script
openfoam-docker / blockMesh -help

# Run a shell script
openfoam-docker -c './Allrun'
```

## Current OpenFOAM Versions

As of June 2025, the latest OpenFOAM versions available as Docker images are:

- OpenFOAM v2412 (December 2024 release)
- OpenFOAM v2406 (June 2024 release)
- OpenFOAM v2312 (December 2023 release)
- OpenFOAM-dev (development version)

## Performance Considerations

- On macOS, there is a slight performance penalty compared to native Linux installations, primarily related to I/O operations
- For better performance with visualization, it's recommended to run ParaView natively on macOS rather than through Docker

## Common Docker Commands for OpenFOAM

```bash
# Check Docker images
docker images

# Remove an image
docker rmi <image-id>

# List running containers
docker ps

# Stop a container
docker stop <container-id>
```

## References

- OpenFOAM Docker Wiki: https://develop.openfoam.com/Development/openfoam/-/wikis/precompiled/docker
- OpenCFD Docker Hub: https://hub.docker.com/u/opencfd
- OpenFOAM Foundation Docker Hub: https://hub.docker.com/u/openfoam

