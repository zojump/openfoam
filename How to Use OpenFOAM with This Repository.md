# How to Use OpenFOAM with This Repository

This comprehensive guide explains how to effectively use OpenFOAM with this repository, which provides a Docker-based approach to computational fluid dynamics (CFD) simulations.

## Table of Contents

1. [Repository Overview](#repository-overview)
2. [Prerequisites](#prerequisites)
3. [Quick Start](#quick-start)
4. [Available Methods](#available-methods)
5. [Running OpenFOAM](#running-openfoam)
6. [Working with Tutorials](#working-with-tutorials)
7. [Visualization with ParaView](#visualization-with-paraview)
8. [Development Workflow](#development-workflow)
9. [Troubleshooting](#troubleshooting)
10. [Additional Resources](#additional-resources)

## Repository Overview

This repository provides a complete OpenFOAM environment using Docker containers, making it easy to run CFD simulations on any system without complex installations. The repository includes:

- **Docker-based OpenFOAM setup** - Containerized environment for consistent execution
- **Multiple execution scripts** - Different ways to run OpenFOAM containers
- **Custom Docker image** - Extended image with additional tools like gmsh
- **Comprehensive documentation** - Guides for various use cases and platforms
- **Tutorial analyses** - Detailed explanations of OpenFOAM examples

### Key Components

- `openfoam-docker` - Main script for running official OpenFOAM images
- `openfoam-docker-agent` - Script for running custom Docker image
- `build.sh` - Builds custom local Docker image with additional tools
- `Dockerfile` - Custom image configuration with gmsh integration
- Documentation files covering Docker setup, macOS alternatives, and development guides

## Prerequisites

### System Requirements

1. **Docker Desktop** (required)
   - Download from [Docker's official website](https://www.docker.com/products/docker-desktop/)
   - Ensure sufficient resources: minimum 4GB RAM, 2 CPUs recommended
   - On macOS: Install Docker Desktop for Mac
   - On Linux: Install Docker Engine or Docker Desktop
   - On Windows: Install Docker Desktop for Windows

2. **ParaView** (recommended for visualization)
   - Download from [ParaView website](https://www.paraview.org/download/)
   - Install natively on your host system for better performance

3. **Git** (for cloning this repository)

### Verify Installation

```bash
# Check Docker installation
docker --version
docker run hello-world

# Check available system resources
docker system info
```

## Quick Start

### 1. Clone the Repository

```bash
git clone <repository-url>
cd <repository-name>
```

### 2. Choose Your Approach

**Option A: Use Official OpenFOAM Images (Recommended for beginners)**
```bash
# Make the script executable
chmod +x openfoam-docker

# Run OpenFOAM interactively
./openfoam-docker
```

**Option B: Build and Use Custom Image (Recommended for advanced users)**
```bash
# Build custom image with additional tools
./build.sh

# Run custom image
chmod +x openfoam-docker-agent
./openfoam-docker-agent
```

### 3. Test the Installation

Once inside the container:
```bash
# Check OpenFOAM version
echo $WM_PROJECT_VERSION

# Test basic functionality
blockMesh -help
```

## Available Methods

### Method 1: Official OpenFOAM Docker Images

The `openfoam-docker` script provides access to official OpenCFD Docker images:

```bash
# Run latest version interactively
./openfoam-docker

# Run specific version
./openfoam-docker -2412

# Run with specific image flavor
./openfoam-docker -dev    # Development environment
./openfoam-docker -run    # Runtime only (default)
./openfoam-docker -default # Complete installation

# Execute commands non-interactively
./openfoam-docker blockMesh -help
./openfoam-docker -c './Allrun'
```

### Method 2: Custom Docker Image

The custom image includes additional tools like gmsh for mesh generation:

```bash
# Build the custom image
./build.sh

# Run the custom image
./openfoam-docker-agent
```

### Method 3: Direct Docker Commands

For advanced users who prefer direct Docker control:

```bash
# Pull and run official image
docker pull opencfd/openfoam-default:2412
docker run -it --rm -v "$(pwd):/home/openfoam/workingDir" opencfd/openfoam-default:2412

# Run custom image (after building)
docker run -it --rm -v "$(pwd):/home/openfoam/workingDir" openfoam-local:2412
```

## Running OpenFOAM

### Interactive Mode

Start an interactive shell with OpenFOAM environment:

```bash
./openfoam-docker
```

Inside the container, you'll have access to:
- All OpenFOAM utilities and solvers
- Your local directory mounted at `/home/openfoam/workingDir`
- Complete OpenFOAM environment variables

### Non-Interactive Mode

Execute specific commands without entering the container:

```bash
# Run a single command
./openfoam-docker blockMesh

# Run a script
./openfoam-docker -c './Allrun'

# Run multiple commands
./openfoam-docker -c 'blockMesh && checkMesh && icoFoam'
```

### Directory Mounting

Your current working directory is automatically mounted inside the container:
- **Host path**: `$(pwd)` (current directory)
- **Container path**: `/home/openfoam/workingDir`
- **Access**: Read/write permissions preserved

## Working with Tutorials

### Running Built-in Tutorials

```bash
# Enter the container
./openfoam-docker

# Copy a tutorial to your working directory
cp -r $FOAM_TUTORIALS/incompressible/icoFoam/elbow ./my-elbow

# Navigate to the tutorial
cd my-elbow

# Run the tutorial
./Allrun
```

### Running Repository Tutorials

If the repository includes tutorials in `storage/tutorials`:

```bash
# Navigate to tutorials directory
cd storage/tutorials

# Enter container
../../openfoam-docker

# Run specific tutorial
cd <tutorial-name>
./Allrun
```

### Understanding Tutorial Structure

OpenFOAM cases follow a standard structure:
```
case-directory/
├── 0.orig/          # Initial and boundary conditions
├── constant/        # Physical properties and mesh
├── system/          # Control parameters and schemes
├── Allrun          # Execution script
└── Allclean        # Cleanup script
```

### Monitoring Simulation Progress

```bash
# Check log files for errors (important!)
cat log.blockMesh
cat log.checkMesh
cat log.icoFoam

# Monitor running simulation
tail -f log.icoFoam

# Check simulation time progress
grep "Time =" log.icoFoam | tail
```

## Visualization with ParaView

### Creating ParaView Files

After successful simulation, create a `.foam` file for ParaView:

```bash
# Create foam file (replace FOAMNAME with your case name)
touch <FOAMNAME>.foam
```

### Opening in ParaView

1. **Open ParaView** on your host system (not in Docker)
2. **File → Open** → Select the `.foam` file
3. **Apply** to load the case
4. **Select fields** to visualize (pressure, velocity, etc.)
5. **Play** to animate time steps

### Visualization Tips

- Run ParaView natively on your host system for better performance
- Use the `.foam` file format for OpenFOAM cases
- Check time directories (0, 0.05, 0.1, etc.) for available time steps
- Common fields to visualize: `p` (pressure), `U` (velocity), `magU` (velocity magnitude)

## Development Workflow

### Typical Workflow

1. **Prepare Case Directory**
   ```bash
   mkdir my-simulation
   cd my-simulation
   ```

2. **Set Up Case Structure**
   ```bash
   mkdir -p 0.orig constant system
   ```

3. **Enter OpenFOAM Environment**
   ```bash
   ../openfoam-docker
   ```

4. **Create/Configure Case Files**
   - Define geometry and mesh (`constant/polyMesh/` or using `blockMesh`)
   - Set boundary conditions (`0.orig/`)
   - Configure physics (`constant/transportProperties`)
   - Set simulation parameters (`system/controlDict`)

5. **Run Simulation**
   ```bash
   # Generate mesh
   blockMesh
   
   # Check mesh quality
   checkMesh
   
   # Run solver
   icoFoam  # or appropriate solver
   ```

6. **Post-Process Results**
   ```bash
   # Create ParaView file
   touch myCase.foam
   
   # Exit container and open ParaView on host
   exit
   paraview myCase.foam
   ```

### Custom Solver Development

For developing custom solvers, use the development image:

```bash
# Run development environment
./openfoam-docker -dev

# Create solver directory
mkdir -p $FOAM_USER_APPBIN
cd $FOAM_USER_APPBIN

# Follow OpenFOAM development guidelines
# (See "Writing OpenFOAM Code and Custom Solvers.md" for details)
```

### Debugging and Troubleshooting

```bash
# Check OpenFOAM environment
printenv | grep FOAM

# Verify case setup
checkCase

# Run with debugging
icoFoam -case . 2>&1 | tee log.debug

# Check mesh quality
checkMesh -allGeometry -allTopology
```

## Troubleshooting

### Common Issues

1. **Docker Permission Issues**
   ```bash
   # Fix permissions if needed
   sudo usermod -aG docker $USER
   # Log out and back in
   ```

2. **Container Can't Access Files**
   - Ensure you're running the script from the directory containing your case
   - Check file permissions and ownership

3. **Simulation Errors**
   - Always check log files: `cat log.solver-name`
   - Verify mesh quality: `checkMesh`
   - Check boundary conditions and initial conditions

4. **Memory Issues**
   - Increase Docker memory allocation in Docker Desktop settings
   - For large cases, consider using cloud computing resources

5. **ParaView Issues**
   - Ensure `.foam` file exists in case directory
   - Check that simulation completed successfully
   - Verify time directories exist (0, 0.05, etc.)

### Log File Analysis

```bash
# Check for errors in log files
grep -i error log.*
grep -i fail log.*
grep -i fatal log.*

# Check convergence
grep "Solving for" log.icoFoam
```

### Performance Optimization

```bash
# Check available resources
docker stats

# Run with specific CPU/memory limits
docker run --cpus="2" --memory="4g" -it --rm -v "$(pwd):/home/openfoam/workingDir" opencfd/openfoam-default:2412
```

## Additional Resources

### Documentation in This Repository

- `OpenFOAM Docker Setup Guide.md` - Detailed Docker setup instructions
- `OpenFOAM Versions and Documentation.md` - Version information and resources
- `Writing OpenFOAM Code and Custom Solvers.md` - Development guide
- `Alternative Approaches to Run OpenFOAM on macOS.md` - macOS-specific options
- `Using Cursor AI IDE with OpenFOAM.md` - IDE integration guide
- `OpenFOAM Elbow Tutorial Analysis.md` - Detailed tutorial walkthrough

### External Resources

- [OpenFOAM Foundation](https://openfoam.org/) - Official documentation
- [OpenCFD OpenFOAM](https://www.openfoam.com/) - Commercial support and documentation
- [CFD Online Forums](https://www.cfd-online.com/Forums/openfoam/) - Community support
- [OpenFOAM Wiki](https://openfoamwiki.net/) - Community-maintained wiki

### Docker Resources

- [OpenCFD Docker Hub](https://hub.docker.com/u/opencfd) - Official Docker images
- [Docker Documentation](https://docs.docker.com/) - Docker usage guide

## Best Practices

1. **Always check log files** after running simulations - errors may not be visible in terminal output
2. **Use version control** for your case files to track changes
3. **Document your modifications** when customizing cases
4. **Start with simple cases** before attempting complex simulations
5. **Verify mesh quality** before running solvers
6. **Monitor system resources** during large simulations
7. **Keep case directories organized** with clear naming conventions
8. **Backup important results** before cleanup operations

## Conclusion

This repository provides a robust, containerized approach to using OpenFOAM that works consistently across different platforms. The Docker-based setup eliminates installation complexity while providing access to the full OpenFOAM ecosystem. Whether you're running tutorials, developing custom solvers, or conducting research simulations, this repository offers the tools and documentation needed for effective CFD workflows.

For specific use cases or advanced configurations, refer to the detailed documentation files included in this repository.