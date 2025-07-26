# OpenFOAM Versions and Documentation

This guide provides information about OpenFOAM versions and where to find documentation resources.

## OpenFOAM Versions

OpenFOAM has two main development lines:

1. **OpenFOAM Foundation** (openfoam.org) - The original open-source project
2. **OpenCFD/ESI** (openfoam.com) - Commercial entity that also releases open-source versions

### Version Naming Convention

- **OpenFOAM Foundation**: Uses version numbers (e.g., v11, v12)
- **OpenCFD/ESI**: Uses year-month format (e.g., v2406 for June 2024 release)

### Current Versions (as of June 2025)

**OpenFOAM Foundation:**
- OpenFOAM 12 (Latest stable release)
- OpenFOAM-dev (Development version)

**OpenCFD/ESI:**
- OpenFOAM v2412 (December 2024)
- OpenFOAM v2406 (June 2024)
- OpenFOAM v2312 (December 2023)

## Documentation Resources

### Official Documentation

1. **OpenFOAM Foundation User Guide**
   - Online: https://doc.cfd.direct/openfoam/user-guide/
   - Covers basic tutorials, general operation, compilation, solvers, models, mesh generation, and post-processing

2. **OpenCFD/ESI Documentation**
   - User Guide: https://www.openfoam.com/documentation/user-guide
   - Tutorial Guide: https://www.openfoam.com/documentation/tutorial-guide
   - Programmer's Guide: https://www.openfoam.com/documentation/cpp-guide

### API Documentation

- C++ Source Guide: https://cpp.openfoam.org/ (OpenFOAM Foundation)
- Doxygen Documentation: Generated from source code

### Tutorials and Examples

1. **Standard Tutorials**
   - Located in `$FOAM_TUTORIALS` directory within OpenFOAM installation
   - Organized by solver type (incompressible, compressible, multiphase, etc.)

2. **Example Cases**
   - Documented in the User Guide
   - Demonstrate specific features and capabilities

### Community Resources

1. **CFD Online Forums**
   - OpenFOAM Discussion: https://www.cfd-online.com/Forums/openfoam/
   - Extensive user discussions and problem-solving

2. **OpenFOAM Wiki**
   - https://wiki.openfoam.com/
   - Community-contributed guides and tips

3. **GitHub Repositories**
   - OpenFOAM Foundation: https://github.com/OpenFOAM
   - Development Repository: https://develop.openfoam.com/Development/openfoam/

## Documentation Structure

### Case Structure Documentation

OpenFOAM cases follow a specific directory structure:

```
case/
├── 0/              # Initial conditions
├── constant/       # Mesh and physical properties
│   └── polyMesh/   # Mesh description
└── system/         # Simulation control parameters
```

Documentation for each component:
- Initial conditions: User Guide, Chapter 4
- Physical properties: User Guide, Chapter 5
- System settings: User Guide, Chapter 6

### Solver Documentation

- Standard solvers are documented in the User Guide
- Each solver has specific requirements for boundary conditions and physical properties
- Solver source code is the ultimate reference (typically in `$FOAM_SOLVERS` directory)

## How to Access Documentation in Docker

When running OpenFOAM in Docker, documentation can be accessed in several ways:

1. **Built-in Help**
   ```bash
   # General help
   openfoam-docker / -help
   
   # Application-specific help
   openfoam-docker / blockMesh -help
   ```

2. **PDF Documentation**
   - Located in `$FOAM_DOC` directory within the container
   - Can be copied out of the container if needed

3. **Online Documentation**
   - Access the links provided above from your host system

## Best Practices for Documentation Use

1. **Start with Tutorials**
   - Begin with the tutorials that match your application
   - Follow step-by-step to understand the workflow

2. **Reference the User Guide**
   - Use for detailed explanations of parameters and models
   - Refer to specific chapters for different aspects of simulation setup

3. **Check Source Code**
   - For advanced usage, the source code provides the definitive reference
   - Comments in header files often contain valuable information

4. **Community Support**
   - Search the CFD Online forums for similar problems
   - Post questions with clear descriptions and minimal working examples

## References

- OpenFOAM Foundation: https://openfoam.org/
- OpenCFD/ESI: https://www.openfoam.com/
- CFD Direct Documentation: https://doc.cfd.direct/
- CFD Online Forums: https://www.cfd-online.com/Forums/openfoam/

