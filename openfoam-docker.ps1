# OpenFOAM Docker Runner for Windows
param(
    [string]$OpenFoamVersion = "latest",
    [string]$ImageFlavour = "-run",
    [string]$MountDir = (Get-Location).Path,
    [string]$DataDir,
    [switch]$Update,
    [switch]$DryRun,
    [switch]$Verbose,
    [switch]$X11Forwarding,
    [string]$ShmSize,
    [string]$Entrypoint,
    [string]$Image,
    [string]$Command
)

$ImageBasename = "opencfd/openfoam"
$ContainerHome = "/home/openfoam"

# Build image name
if (-not $Image) {
    $Image = "${ImageBasename}${ImageFlavour}:${OpenFoamVersion}"
}

# Update image if requested
if ($Update) {
    if ($DryRun) {
        Write-Host "(dry-run)"
        Write-Host "docker pull $Image"
    } else {
        Write-Host "Updating image: $Image"
        docker pull $Image
    }
    exit
}

# Build Docker run command
$DockerArgs = @(
    "run",
    "--rm",
    "-it",
    "--user", "$(Get-Process -Id $PID).SessionId:$(Get-Process -Id $PID).SessionId"
)

# Add volume mounts
if ($MountDir) {
    $DockerArgs += "--volume", "${MountDir}:${ContainerHome}"
}
if ($DataDir) {
    $DockerArgs += "--volume", "${DataDir}:/data"
}

# Add X11 forwarding if enabled
if ($X11Forwarding) {
    $DockerArgs += @(
        "--env", "DISPLAY=host.docker.internal:0.0",
        "--env", "XAUTHORITY=/home/openfoam/.Xauthority"
    )
}

# Add shared memory size if specified
if ($ShmSize) {
    $DockerArgs += "--shm-size", $ShmSize
}

# Add entrypoint if specified
if ($Entrypoint) {
    $DockerArgs += "--entrypoint", $Entrypoint
}

# Add image and command
$DockerArgs += $Image
if ($Command) {
    $DockerArgs += $Command
}

# Execute command
if ($DryRun) {
    Write-Host "(dry-run)"
    Write-Host "docker $($DockerArgs -join ' ')"
} else {
    if ($Verbose) {
        Write-Host "Running: docker $($DockerArgs -join ' ')"
    }
    docker $DockerArgs
} 