# Writing OpenFOAM Code and Custom Solvers

This guide provides information on how to write and develop custom code for OpenFOAM.

## OpenFOAM Programming Basics

OpenFOAM is written in C++ and makes extensive use of object-oriented programming concepts. Understanding these fundamentals is essential for developing custom solvers and utilities.

### Key C++ Concepts Used in OpenFOAM

- Object-oriented programming
- Operator overloading
- Template programming
- Runtime type identification (RTTI)
- Dynamic polymorphism

### OpenFOAM-Specific Programming Concepts

- Field operations
- Dimensional units
- Tensor mathematics
- Finite volume discretization
- Boundary conditions

## Directory Structure for Custom Code

When developing custom code for OpenFOAM, follow this directory structure:

```
$WM_PROJECT_USER_DIR/
├── applications/
│   ├── solvers/
│   │   └── mySolver/
│   └── utilities/
│       └── myUtility/
└── src/
    ├── myLibrary/
    │   ├── Make/
    │   ├── lnInclude/
    │   └── myClass.C/H
    └── finiteVolume/
```

## Creating a Custom Solver

### Step 1: Create the Solver Directory

```bash
mkdir -p $WM_PROJECT_USER_DIR/applications/solvers/mySolver
cd $WM_PROJECT_USER_DIR/applications/solvers/mySolver
```

### Step 2: Create Source Files

Create the main solver file, e.g., `mySolver.C`:

```cpp
#include "fvCFD.H"

int main(int argc, char *argv[])
{
    #include "setRootCase.H"
    #include "createTime.H"
    #include "createMesh.H"
    
    // Create fields
    // ...
    
    // Main solution loop
    while (runTime.loop())
    {
        Info<< "Time = " << runTime.timeName() << nl << endl;
        
        // Solve equations
        // ...
        
        runTime.write();
    }
    
    Info<< "End\n" << endl;
    
    return 0;
}
```

### Step 3: Create Make Files

Create a `Make` directory with two files:

1. `Make/files`:
```
mySolver.C

EXE = $(FOAM_USER_APPBIN)/mySolver
```

2. `Make/options`:
```
EXE_INC = \
    -I$(LIB_SRC)/finiteVolume/lnInclude \
    -I$(LIB_SRC)/meshTools/lnInclude

EXE_LIBS = \
    -lfiniteVolume \
    -lmeshTools
```

### Step 4: Compile the Solver

```bash
wmake
```

## Creating a Custom Library

### Step 1: Create the Library Directory

```bash
mkdir -p $WM_PROJECT_USER_DIR/src/myLibrary
cd $WM_PROJECT_USER_DIR/src/myLibrary
```

### Step 2: Create Source Files

Create header and implementation files, e.g., `myClass.H` and `myClass.C`.

### Step 3: Create Make Files

1. `Make/files`:
```
myClass.C

LIB = $(FOAM_USER_LIBBIN)/libmyLibrary
```

2. `Make/options`:
```
EXE_INC = \
    -I$(LIB_SRC)/finiteVolume/lnInclude

LIB_LIBS = \
    -lfiniteVolume
```

### Step 4: Compile the Library

```bash
wmake libso
```

## Modifying Existing Solvers

A common approach is to copy and modify an existing solver:

1. Find a solver that's close to what you need:
```bash
find $FOAM_SOLVERS -name "*.C" | grep -i keyword
```

2. Copy the solver to your user directory:
```bash
cp -r $FOAM_SOLVERS/incompressible/icoFoam $WM_PROJECT_USER_DIR/applications/solvers/myIcoFoam
```

3. Modify the source files and Make files as needed

4. Compile the new solver:
```bash
cd $WM_PROJECT_USER_DIR/applications/solvers/myIcoFoam
wmake
```

## Best Practices for OpenFOAM Development

1. **Start Simple**
   - Begin by modifying existing solvers rather than writing from scratch
   - Understand the code structure before making significant changes

2. **Use Version Control**
   - Track changes with Git or another version control system
   - Create branches for experimental features

3. **Test Incrementally**
   - Test each change with simple cases before proceeding
   - Use the built-in test cases as validation

4. **Follow OpenFOAM Coding Style**
   - Maintain consistent indentation (4 spaces)
   - Follow naming conventions (camelCase for variables, CamelCase for classes)
   - Use descriptive variable names

5. **Document Your Code**
   - Add comments explaining the purpose of functions and complex operations
   - Include references to equations or algorithms implemented

## Debugging OpenFOAM Code

1. **Use Info Statements**
```cpp
Info<< "Variable value: " << variable << endl;
```

2. **Check Dimensions**
```cpp
Info<< "Dimensions: " << variable.dimensions() << endl;
```

3. **Write Fields for Visualization**
```cpp
volScalarField debugField
(
    IOobject
    (
        "debugField",
        mesh.time().timeName(),
        mesh,
        IOobject::NO_READ,
        IOobject::AUTO_WRITE
    ),
    mesh,
    dimensionedScalar("zero", dimless, 0.0)
);

debugField = myCalculation;
debugField.write();
```

4. **Use System Debuggers**
   - GDB can be used with OpenFOAM applications
   - Compile with debug flags: `wmake -with-debug`

## Common Development Tasks

### Adding a Transport Equation

```cpp
// Solve a scalar transport equation for T
fvScalarMatrix TEqn
(
    fvm::ddt(T)
    + fvm::div(phi, T)
    - fvm::laplacian(DT, T)
    ==
    fvOptions(T)
);

TEqn.relax();
fvOptions.constrain(TEqn);
TEqn.solve();
fvOptions.correct(T);
```

### Adding a Source Term

```cpp
// Add a source term S to the momentum equation
fvVectorMatrix UEqn
(
    fvm::ddt(U)
    + fvm::div(phi, U)
    - fvm::laplacian(nu, U)
    ==
    S
);
```

### Creating a Custom Boundary Condition

1. Create header and source files in your library
2. Register the boundary condition using the `addToRunTimeSelectionTable` macro
3. Implement the required virtual functions

## Compiling OpenFOAM Code in Docker

When using Docker, you can develop and compile custom OpenFOAM code:

1. Use the `-dev` or `-default` Docker images which include the development environment
2. Mount your source directory into the container:
```bash
docker run -it --rm -v "$(pwd):/home/openfoam/workingDir" -v "$WM_PROJECT_USER_DIR:/home/openfoam/OpenFOAM/openfoam-$USER-$WM_PROJECT_VERSION" opencfd/openfoam-dev
```

3. Compile within the container using the standard OpenFOAM build tools

## References

- OpenFOAM Programmer's Guide: https://cpp.openfoam.org/
- OpenFOAM Wiki Programming Tutorials: https://wiki.openfoam.com/Programming_by_Alexander_Vakhrushev
- CFD Online Programming Forum: https://www.cfd-online.com/Forums/openfoam-programming-development/

