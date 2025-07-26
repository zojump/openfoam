# OpenFOAM Docker Development Guide for macOS
*Maximizing Performance and Resource Utilization on MacBook Pro*

## 🎯 Overview

This guide provides comprehensive instructions for developing with OpenFOAM in Docker on macOS, specifically optimized for MacBook Pro systems. Focus areas include generation speed improvement, optimal resource utilization, and performance tuning strategies.

## 🚀 Quick Start

### Prerequisites
- MacBook Pro (Intel or Apple Silicon)
- Docker Desktop for Mac
- At least 8GB RAM (16GB+ recommended for large simulations)
- 50GB+ free disk space

### Installation Steps
1. Install Docker Desktop for Mac from [official Docker website](https://www.docker.com/products/docker-desktop/)
2. Clone this repository and use the provided scripts
3. Configure Docker Desktop for optimal performance (see Performance Configuration section)

## 📊 Performance Configuration for MacBook Pro

### Docker Desktop Settings Optimization

#### Resource Allocation
Navigate to Docker Desktop → Settings → Resources → Advanced:

```bash
# Recommended settings for MacBook Pro 16-inch (32GB RAM)
CPU Cores: 8-12 (75% of available cores)
Memory: 16-24GB (50-75% of total RAM)
Swap: 4GB
Disk Image Size: 100GB+

# For MacBook Pro 14-inch (16GB RAM)
CPU Cores: 6-8 (75% of available cores)  
Memory: 8-12GB (50-75% of total RAM)
Swap: 2GB
Disk Image Size: 80GB+
```

#### Apple Silicon Optimization (M1/M2/M3 Macs)
```bash
# Enable these settings in Docker Desktop
General → Use Rosetta for x86_64/amd64 emulation: ✓ Enabled
General → Choose Virtual Machine Manager: Apple Virtualization Framework
General → VirtioFS file sharing: ✓ Enabled (fastest option)
Resources → Use kernel networking for UDP: ✓ Enabled
```

#### Intel Mac Optimization
```bash
# Hypervisor settings
General → Choose Virtual Machine Manager: HyperKit
General → File sharing: VirtioFS (if available) or gRPC FUSE
```

### Volume Mount Performance Tuning

Use optimized volume mounting for significant speed improvements:

```yaml
# docker-compose.yml optimized for macOS performance
version: '3.8'
services:
  openfoam:
    image: opencfd/openfoam-default:2412
    volumes:
      # Use delegated consistency for source code (best performance)
      - ../:/home/openfoam/workingDir:delegated
      # Use cached for configuration files
      - ./config:/home/openfoam/config:cached
      # Shared caches for better build performance
      - ~/.docker/openfoam-cache:/home/openfoam/.cache:cached
    working_dir: /home/openfoam/workingDir
    environment:
      - FOAM_VERBOSE=1
    # Resource limits
    deploy:
      resources:
        limits:
          cpus: '8'
          memory: 16G
```

### Performance Monitoring

Monitor Docker resource usage:
```bash
# Real-time container statistics
docker stats

# System resource monitoring
top -pid $(pgrep Docker)
```

## 🛠️ Development Environment Setup

### 1. Enhanced OpenFOAM Script

Create an optimized launcher script `openfoam-pro`:

```bash
#!/bin/bash
# Enhanced OpenFOAM Docker script for MacBook Pro

# Performance settings
export DOCKER_BUILDKIT=1
export COMPOSE_DOCKER_CLI_BUILD=1

# Detect system specs
TOTAL_CORES=$(sysctl -n hw.ncpu)
TOTAL_RAM_GB=$(( $(sysctl -n hw.memsize) / 1024 / 1024 / 1024 ))
OPTIMAL_CORES=$(( TOTAL_CORES * 3 / 4 ))
OPTIMAL_RAM=$(( TOTAL_RAM_GB / 2 ))

echo "🚀 OpenFOAM Docker Launcher for MacBook Pro"
echo "System: ${TOTAL_CORES} cores, ${TOTAL_RAM_GB}GB RAM"
echo "Allocated: ${OPTIMAL_CORES} cores, ${OPTIMAL_RAM}GB RAM"

# Run with optimized settings
docker run -it --rm \
    --cpus="${OPTIMAL_CORES}" \
    --memory="${OPTIMAL_RAM}g" \
    --shm-size=2g \
    -v "$(pwd):/home/openfoam/workingDir:delegated" \
    -v "${HOME}/.docker/openfoam-cache:/home/openfoam/.cache:cached" \
    -e FOAM_VERBOSE=1 \
    -e OMP_NUM_THREADS="${OPTIMAL_CORES}" \
    opencfd/openfoam-default:2412 "$@"
```

### 2. Docker Compose for Development

```yaml
# docker-compose.dev.yml - Optimized for development
version: '3.8'
services:
  openfoam-dev:
    image: opencfd/openfoam-dev:2412
    container_name: openfoam-development
    volumes:
      - ../cases:/home/openfoam/cases:delegated
      - ../custom-solvers:/home/openfoam/solvers:delegated
      - ~/.docker/openfoam-cache:/home/openfoam/.cache:cached
      - ~/.docker/openfoam-ccache:/home/openfoam/.ccache:cached
    environment:
      - FOAM_VERBOSE=1
      - WM_NCOMPPROCS=8  # Adjust based on your MacBook Pro
      - CCACHE_DIR=/home/openfoam/.ccache
      - CCACHE_MAXSIZE=5G
    deploy:
      resources:
        limits:
          cpus: '8'
          memory: 16G
    working_dir: /home/openfoam/cases
    tty: true
    stdin_open: true

  # Separate service for GUI applications
  paraview:
    image: opencfd/openfoam-default:2412
    container_name: openfoam-paraview
    volumes:
      - ../cases:/home/openfoam/cases:cached
      - /tmp/.X11-unix:/tmp/.X11-unix:rw
    environment:
      - DISPLAY=host.docker.internal:0
    network_mode: host
    profiles:
      - gui
```

### 3. Build Optimization

For custom solver development:

```dockerfile
# Dockerfile.dev - Optimized development image
FROM opencfd/openfoam-dev:2412

# Install development tools
USER root
RUN apt-get update && apt-get install -y \
    ccache \
    ninja-build \
    clang-tools \
    gdb \
    valgrind \
    && rm -rf /var/lib/apt/lists/*

# Configure ccache for faster compilation
USER $FOAM_USER
RUN echo 'export PATH="/usr/lib/ccache:$PATH"' >> ~/.bashrc && \
    echo 'export CCACHE_DIR=/home/openfoam/.ccache' >> ~/.bashrc && \
    echo 'export CCACHE_MAXSIZE=5G' >> ~/.bashrc

# Pre-compile commonly used libraries
COPY --chown=$FOAM_USER:$FOAM_USER scripts/precompile.sh /home/openfoam/
RUN /home/openfoam/precompile.sh
```

## ⚡ Speed Optimization Strategies

### 1. Parallel Processing Configuration

```bash
# Optimal processor configuration for OpenFOAM
# Add to your case's system/decomposeParDict

numberOfSubdomains  8;  // Match your CPU cores

method          scotch;  // Best for general cases

scotchCoeffs
{
    writeGraph      false;
    strategy        "b";  // Balanced decomposition
}
```

### 2. Memory Management

```bash
# Environment variables for optimal memory usage
export FOAM_VERBOSE=1
export WM_NCOMPPROCS=8  # Parallel compilation
export OMP_NUM_THREADS=8  # OpenMP threads
export MALLOC_ARENA_MAX=4  # Reduce memory fragmentation
```

### 3. Disk I/O Optimization

```bash
# Create optimized directory structure
mkdir -p ~/.docker/openfoam-cache/{ccache,npm,pip,apt}

# Use ramdisk for temporary files (optional, for extreme performance)
sudo diskutil erasevolume HFS+ "RamDisk" `hdiutil attach -nomount ram://2097152`
export FOAM_USER_TMPDIR=/Volumes/RamDisk
```

## 🔧 Optimized Workflows

### Development Workflow

```bash
# 1. Start development environment
docker-compose -f docker-compose.dev.yml up -d openfoam-dev

# 2. Enter development container
docker exec -it openfoam-development bash

# 3. In container - compile with maximum parallel jobs
wmake -j 8 libso

# 4. Run simulations with optimal decomposition
decomposePar -cellDist
mpirun -np 8 simpleFoam -parallel
reconstructPar
```

### Testing Workflow

```bash
# Quick testing script
#!/bin/bash
# test-performance.sh

echo "🧪 Testing OpenFOAM Performance on $(hostname)"

# Test compilation speed
time wmake -j 8 libso

# Test mesh generation speed  
time blockMesh

# Test solver speed
time simpleFoam

# Test parallel efficiency
for np in 1 2 4 8; do
    echo "Testing with $np processors"
    decomposePar -cellDist > /dev/null 2>&1
    time mpirun -np $np simpleFoam -parallel > /dev/null 2>&1
    reconstructPar > /dev/null 2>&1
done
```

### Batch Processing

```bash
# batch-runner.sh - Process multiple cases efficiently
#!/bin/bash

CASES_DIR="./cases"
MAX_PARALLEL=4  # Adjust based on available resources

find "$CASES_DIR" -name "Allrun" | \
    xargs -I {} -P $MAX_PARALLEL bash -c 'cd "$(dirname "{}")" && ./Allrun'
```

## 📈 Performance Monitoring and Profiling

### Container Resource Monitoring

```bash
# Monitor Docker container performance
docker stats --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}\t{{.BlockIO}}"

# Detailed system monitoring
htop -p $(pgrep Docker)
```

### OpenFOAM Performance Profiling

```bash
# Time analysis for simulations
time simpleFoam > log.simpleFoam 2>&1

# Memory usage profiling
valgrind --tool=massif mpirun -np 1 simpleFoam

# CPU profiling with perf (if available)
perf record -g mpirun -np 8 simpleFoam
perf report
```

### Automated Benchmarking

```bash
# benchmark.sh - Automated performance testing
#!/bin/bash

echo "🏃‍♂️ OpenFOAM Benchmark Suite"

# System info
echo "System: $(system_profiler SPHardwareDataType | grep 'Chip\|Memory')"
echo "Docker: $(docker --version)"

# Benchmark cavity case
cp -r $FOAM_TUTORIALS/incompressible/simpleFoam/cavity .
cd cavity

# Test different core counts
for cores in 1 2 4 8; do
    echo "Benchmarking with $cores cores"
    export OMP_NUM_THREADS=$cores
    
    start_time=$(date +%s)
    blockMesh > /dev/null 2>&1
    simpleFoam > /dev/null 2>&1
    end_time=$(date +%s)
    
    runtime=$((end_time - start_time))
    echo "Runtime with $cores cores: ${runtime}s"
done
```

## 🛡️ Troubleshooting and Best Practices

### Common Performance Issues

#### 1. File System Performance
```bash
# Problem: Slow file I/O
# Solution: Use optimized volume mounts
volumes:
  - ./case:/home/openfoam/case:delegated  # For source code
  - ./results:/home/openfoam/results:cached  # For output data
```

#### 2. Memory Limitations
```bash
# Problem: Out of memory errors
# Solution: Increase Docker memory limits and use swap
docker run --memory=16g --memory-swap=20g ...
```

#### 3. CPU Throttling
```bash
# Problem: Thermal throttling on MacBook Pro
# Solution: Monitor temperatures and use fan control
sudo powermetrics --show-process-energy -n 1 | grep Docker
```

### Best Practices for AI Agents

When developing with AI assistance:

1. **Use consistent project structure**:
   ```
   project/
   ├── cases/          # OpenFOAM cases
   ├── scripts/        # Automation scripts  
   ├── docker/         # Docker configurations
   └── docs/           # Documentation
   ```

2. **Provide clear context to AI**:
   - Include relevant log files
   - Specify hardware configuration
   - Mention performance requirements

3. **Automated testing integration**:
   ```bash
   # CI/CD pipeline script
   docker-compose -f docker-compose.test.yml run --rm test-runner
   ```

### Maintenance Tasks

```bash
# Weekly maintenance script
#!/bin/bash
# maintenance.sh

echo "🧹 Docker Maintenance for OpenFOAM"

# Clean up unused containers and images
docker system prune -f

# Update OpenFOAM images
docker pull opencfd/openfoam-default:latest
docker pull opencfd/openfoam-dev:latest

# Clear build cache (if getting too large)
docker builder prune -f

# Optimize Docker Desktop
echo "Consider restarting Docker Desktop for optimal performance"
```

## 📚 Additional Resources

### Essential Commands Reference

```bash
# Container management
docker exec -it container_name bash
docker-compose logs -f service_name
docker stats container_name

# OpenFOAM utilities
foamCleanTutorials     # Clean case directory
foamListTimes          # List available time directories
foamJob -screen solver # Run solver with output to screen

# Performance utilities
wmake -j $(nproc) libso    # Parallel compilation
decomposePar -cellDist     # Domain decomposition
mpirun -np 8 solver        # Parallel execution
```

### Useful Environment Variables

```bash
# Performance tuning
export FOAM_VERBOSE=1              # Verbose output
export WM_NCOMPPROCS=8            # Parallel compilation jobs
export OMP_NUM_THREADS=8          # OpenMP threads
export MALLOC_ARENA_MAX=4         # Memory optimization

# Development helpers  
export FOAM_USER_APPBIN="$HOME/OpenFOAM/$USER-$WM_PROJECT_VERSION/platforms/$WM_OPTIONS/bin"
export FOAM_USER_LIBBIN="$HOME/OpenFOAM/$USER-$WM_PROJECT_VERSION/platforms/$WM_OPTIONS/lib"
```

### Recommended Tools

- **VS Code** with Docker extension for development
- **Activity Monitor** for system resource monitoring
- **iStat Menus** for detailed system monitoring
- **Cursor AI** for intelligent code assistance
- **Git** for version control of cases and solvers

## 🎯 Summary

This guide provides a comprehensive approach to maximizing OpenFOAM Docker performance on macOS. Key takeaways:

1. **Optimize Docker Desktop settings** for your specific MacBook Pro configuration
2. **Use appropriate volume mount strategies** (delegated/cached) for better I/O performance  
3. **Leverage parallel processing** throughout the workflow
4. **Monitor and profile** performance regularly
5. **Automate repetitive tasks** for efficiency

Following these guidelines should result in 2-5x performance improvements compared to default Docker configurations on macOS.

---

*Last updated: January 2025*  
*Compatible with: OpenFOAM v2412, Docker Desktop 4.34+, macOS 12.5+*