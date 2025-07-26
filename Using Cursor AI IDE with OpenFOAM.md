# Using Cursor AI IDE with OpenFOAM

This guide provides specific information on how to effectively use Cursor AI IDE when working with OpenFOAM projects.

## What is Cursor AI IDE?

Cursor is an AI-powered code editor built on top of Visual Studio Code. It integrates large language models to assist with code understanding, generation, and editing. Key features include:

- Code completion and generation based on natural language prompts
- Codebase understanding and contextual assistance
- Ability to explain and refactor existing code
- Support for multiple programming languages, including C++ (used by OpenFOAM)

## Setting Up Cursor AI for OpenFOAM Development

### Installation

1. Download Cursor AI IDE from the [official website](https://www.cursor.com/)
2. Install on macOS by moving the application to your Applications folder
3. Launch Cursor and complete the initial setup

### Configuring for OpenFOAM

1. **Open an OpenFOAM Project**:
   - File → Open Folder → Select your OpenFOAM case directory

2. **Configure C++ Support**:
   - Install C/C++ extension if not already included
   - Set up include paths for OpenFOAM headers:
     - Create a `.vscode/c_cpp_properties.json` file with appropriate include paths

   Example configuration:
   ```json
   {
       "configurations": [
           {
               "name": "OpenFOAM",
               "includePath": [
                   "${workspaceFolder}/**",
                   "/opt/openfoam/OpenFOAM-v2412/src/finiteVolume/lnInclude",
                   "/opt/openfoam/OpenFOAM-v2412/src/meshTools/lnInclude"
               ],
               "defines": [],
               "compilerPath": "/usr/bin/clang++",
               "cStandard": "c17",
               "cppStandard": "c++14",
               "intelliSenseMode": "clang-x64"
           }
       ],
       "version": 4
   }
   ```

3. **Set Up Terminal Integration**:
   - Configure the integrated terminal to access your OpenFOAM environment
   - For Docker-based installations, create a custom terminal profile

## Working with OpenFOAM Files

### Case Directory Structure

Cursor AI can help navigate and understand the standard OpenFOAM case structure:

```
case/
├── 0/              # Initial conditions
├── constant/       # Mesh and physical properties
│   └── polyMesh/   # Mesh description
└── system/         # Simulation control parameters
```

Use Cursor's file explorer to navigate between these directories efficiently.

### Dictionary Files

OpenFOAM uses dictionary files for configuration. Cursor AI can help with:

1. **Syntax Highlighting**: Ensure proper visualization of OpenFOAM dictionary syntax
2. **Code Completion**: Suggest field names, boundary conditions, and parameters
3. **Error Detection**: Identify syntax errors in dictionary files

Example prompt for Cursor AI:
```
Help me understand what this fvSchemes dictionary is configuring and suggest any improvements
```

### C++ Source Files

When working with custom solvers or utilities:

1. **Code Navigation**: Jump to definitions and references in the OpenFOAM codebase
2. **Code Generation**: Generate boilerplate code for new classes or functions
3. **Refactoring**: Improve existing code structure and readability

Example prompt for Cursor AI:
```
Explain this finite volume discretization code and suggest how to optimize it
```

## Integrating with OpenFOAM Workflow

### Running Simulations

While Cursor AI is primarily a code editor, you can integrate it with your OpenFOAM workflow:

1. **Terminal Commands**: Run OpenFOAM commands directly from Cursor's integrated terminal
2. **Task Configuration**: Set up tasks for common OpenFOAM operations

Example `.vscode/tasks.json`:
```json
{
    "version": "2.0.0",
    "tasks": [
        {
            "label": "blockMesh",
            "type": "shell",
            "command": "blockMesh",
            "problemMatcher": []
        },
        {
            "label": "simpleFoam",
            "type": "shell",
            "command": "simpleFoam",
            "problemMatcher": []
        }
    ]
}
```

### Debugging

For debugging OpenFOAM applications:

1. **Log Analysis**: Use Cursor AI to analyze OpenFOAM log files
   ```
   Analyze this log file and identify why the simulation is diverging
   ```

2. **Code Inspection**: Understand complex parts of the code
   ```
   Explain how this turbulence model is implemented
   ```

3. **Error Resolution**: Get suggestions for fixing common errors
   ```
   Help me fix this compilation error in my custom solver
   ```

## Best Practices for Using Cursor AI with OpenFOAM

1. **Provide Context**: When asking Cursor AI about OpenFOAM code, provide sufficient context about what you're trying to achieve

2. **Verify Suggestions**: Always verify AI-generated code against OpenFOAM documentation and best practices

3. **Incremental Development**: Use Cursor AI to develop custom code incrementally, testing each step

4. **Documentation Integration**: Ask Cursor AI to explain OpenFOAM documentation when needed
   ```
   Explain this section of the OpenFOAM user guide about fvOptions
   ```

5. **Learning Aid**: Use Cursor AI to understand complex OpenFOAM concepts
   ```
   Explain how the PIMPLE algorithm works in OpenFOAM
   ```

## Example Workflows

### 1. Creating a Custom Solver

```
1. Open Cursor AI IDE
2. Create a new directory for your solver
3. Ask Cursor: "Help me create a custom OpenFOAM solver based on icoFoam but adding a passive scalar transport equation"
4. Review and modify the generated code
5. Create Make files with Cursor's assistance
6. Compile and test the solver
```

### 2. Case Setup

```
1. Open an existing case template
2. Ask Cursor: "Help me modify this controlDict for a transient simulation running for 10 seconds with adaptive timestepping"
3. Review and apply the suggested changes
4. Continue with other dictionary files as needed
```

### 3. Post-processing

```
1. Open your case directory after running a simulation
2. Ask Cursor: "Generate a Python script using matplotlib to plot residuals from the log file"
3. Save and run the generated script
```

## Limitations and Considerations

1. **OpenFOAM-Specific Knowledge**: While Cursor AI has general programming knowledge, it may not have specific details about the latest OpenFOAM releases

2. **Complex Physics**: For advanced CFD concepts, verify Cursor's suggestions against established literature

3. **Performance Optimization**: Cursor can suggest code improvements, but domain-specific optimizations may require expert knowledge

4. **Large Codebases**: When working with extensive custom libraries, provide Cursor with focused context rather than the entire codebase

## References

- Cursor AI IDE: https://www.cursor.com/
- OpenFOAM C++ Source Guide: https://cpp.openfoam.org/
- OpenFOAM Wiki: https://wiki.openfoam.com/
- CFD Online Forums: https://www.cfd-online.com/Forums/openfoam/

