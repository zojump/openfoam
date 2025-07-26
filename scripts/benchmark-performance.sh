#!/bin/bash
# OpenFOAM Performance Benchmark Suite for macOS
# Tests various configurations to find optimal settings for your MacBook Pro

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Configuration
BENCHMARK_DIR="./benchmark-results"
TEST_CASE="cavity"
OPENFOAM_VERSION="2412"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
RESULTS_FILE="${BENCHMARK_DIR}/benchmark_${TIMESTAMP}.txt"

print_header() {
    echo -e "${BLUE}🏃‍♂️ OpenFOAM Performance Benchmark Suite${NC}"
    echo -e "${BLUE}===============================================${NC}"
    echo "Timestamp: $(date)"
    echo "Host: $(hostname)"
    echo "Results will be saved to: $RESULTS_FILE"
    echo ""
}

detect_system_specs() {
    echo -e "${GREEN}🔍 System Specifications:${NC}"
    
    # Basic system info
    TOTAL_CORES=$(sysctl -n hw.ncpu)
    TOTAL_RAM_GB=$(( $(sysctl -n hw.memsize) / 1024 / 1024 / 1024 ))
    
    # CPU information
    if [[ $(uname -m) == "arm64" ]]; then
        CHIP_TYPE="Apple Silicon"
        CPU_INFO=$(system_profiler SPHardwareDataType | grep "Chip:" | awk -F': ' '{print $2}')
    else
        CHIP_TYPE="Intel"
        CPU_INFO=$(sysctl -n machdep.cpu.brand_string)
    fi
    
    # macOS version
    MACOS_VERSION=$(sw_vers -productVersion)
    
    # Docker version
    DOCKER_VERSION=$(docker --version | awk '{print $3}' | sed 's/,//')
    
    echo "  CPU: $CHIP_TYPE - $CPU_INFO"
    echo "  Cores: $TOTAL_CORES"
    echo "  RAM: ${TOTAL_RAM_GB}GB"
    echo "  macOS: $MACOS_VERSION"
    echo "  Docker: $DOCKER_VERSION"
    echo ""
    
    # Save to results file
    {
        echo "=== System Specifications ==="
        echo "Timestamp: $(date)"
        echo "CPU: $CHIP_TYPE - $CPU_INFO"
        echo "Cores: $TOTAL_CORES"
        echo "RAM: ${TOTAL_RAM_GB}GB"
        echo "macOS: $MACOS_VERSION"
        echo "Docker: $DOCKER_VERSION"
        echo ""
    } >> "$RESULTS_FILE"
}

prepare_test_case() {
    echo -e "${YELLOW}📁 Preparing test case...${NC}"
    
    # Create benchmark directory
    mkdir -p "$BENCHMARK_DIR"
    
    # Copy cavity tutorial for testing
    docker run --rm \
        -v "$(pwd)/${BENCHMARK_DIR}:/home/openfoam/benchmark" \
        opencfd/openfoam-default:$OPENFOAM_VERSION \
        bash -c "cp -r \$FOAM_TUTORIALS/incompressible/simpleFoam/cavity /home/openfoam/benchmark/"
    
    echo -e "${GREEN}✅ Test case prepared${NC}"
}

run_baseline_test() {
    local cores=$1
    local memory=$2
    local test_name=$3
    
    echo -e "${BLUE}🧪 Running test: $test_name (${cores} cores, ${memory}GB RAM)${NC}"
    
    local start_time=$(date +%s.%N)
    
    # Run the benchmark
    docker run --rm \
        --cpus="$cores" \
        --memory="${memory}g" \
        -v "$(pwd)/${BENCHMARK_DIR}/cavity:/home/openfoam/cavity" \
        -e OMP_NUM_THREADS="$cores" \
        -e WM_NCOMPPROCS="$cores" \
        opencfd/openfoam-default:$OPENFOAM_VERSION \
        bash -c "cd cavity && blockMesh > /dev/null 2>&1 && simpleFoam > /dev/null 2>&1"
    
    local end_time=$(date +%s.%N)
    local runtime=$(echo "$end_time - $start_time" | bc)
    
    echo -e "${GREEN}✅ Test completed in ${runtime}s${NC}"
    
    # Log results
    {
        echo "$test_name: ${runtime}s (${cores} cores, ${memory}GB RAM)"
    } >> "$RESULTS_FILE"
    
    echo "$runtime"
}

run_volume_mount_tests() {
    echo -e "${PURPLE}📂 Testing volume mount performance...${NC}"
    
    local cores=4
    local memory=8
    
    echo "=== Volume Mount Performance ===" >> "$RESULTS_FILE"
    
    # Test 1: Default mount
    echo -e "${BLUE}Testing default volume mount...${NC}"
    local start_time=$(date +%s.%N)
    docker run --rm \
        --cpus="$cores" \
        --memory="${memory}g" \
        -v "$(pwd)/${BENCHMARK_DIR}/cavity:/home/openfoam/cavity" \
        opencfd/openfoam-default:$OPENFOAM_VERSION \
        bash -c "cd cavity && blockMesh > /dev/null 2>&1"
    local end_time=$(date +%s.%N)
    local default_time=$(echo "$end_time - $start_time" | bc)
    
    # Test 2: Delegated mount
    echo -e "${BLUE}Testing delegated volume mount...${NC}"
    start_time=$(date +%s.%N)
    docker run --rm \
        --cpus="$cores" \
        --memory="${memory}g" \
        -v "$(pwd)/${BENCHMARK_DIR}/cavity:/home/openfoam/cavity:delegated" \
        opencfd/openfoam-default:$OPENFOAM_VERSION \
        bash -c "cd cavity && blockMesh > /dev/null 2>&1"
    end_time=$(date +%s.%N)
    local delegated_time=$(echo "$end_time - $start_time" | bc)
    
    # Test 3: Cached mount
    echo -e "${BLUE}Testing cached volume mount...${NC}"
    start_time=$(date +%s.%N)
    docker run --rm \
        --cpus="$cores" \
        --memory="${memory}g" \
        -v "$(pwd)/${BENCHMARK_DIR}/cavity:/home/openfoam/cavity:cached" \
        opencfd/openfoam-default:$OPENFOAM_VERSION \
        bash -c "cd cavity && blockMesh > /dev/null 2>&1"
    end_time=$(date +%s.%N)
    local cached_time=$(echo "$end_time - $start_time" | bc)
    
    echo -e "${GREEN}Volume mount results:${NC}"
    echo "  Default: ${default_time}s"
    echo "  Delegated: ${delegated_time}s"
    echo "  Cached: ${cached_time}s"
    
    {
        echo "Default mount: ${default_time}s"
        echo "Delegated mount: ${delegated_time}s"
        echo "Cached mount: ${cached_time}s"
        echo ""
    } >> "$RESULTS_FILE"
}

run_parallel_scaling_test() {
    echo -e "${PURPLE}⚡ Testing parallel scaling...${NC}"
    
    echo "=== Parallel Scaling Test ===" >> "$RESULTS_FILE"
    
    local memory=8
    local core_counts=(1 2 4 8)
    
    # Run tests with different core counts
    for cores in "${core_counts[@]}"; do
        if [ "$cores" -le "$TOTAL_CORES" ]; then
            local runtime=$(run_baseline_test "$cores" "$memory" "Parallel-${cores}cores")
            
            # Calculate efficiency
            if [ "$cores" -eq 1 ]; then
                local baseline_time="$runtime"
            fi
            
            if [ -n "$baseline_time" ] && [ "$cores" -gt 1 ]; then
                local efficiency=$(echo "scale=2; ($baseline_time / $runtime) / $cores * 100" | bc)
                echo "  Efficiency with $cores cores: ${efficiency}%"
                echo "Efficiency with $cores cores: ${efficiency}%" >> "$RESULTS_FILE"
            fi
        fi
    done
    
    echo "" >> "$RESULTS_FILE"
}

run_memory_scaling_test() {
    echo -e "${PURPLE}🧠 Testing memory allocation...${NC}"
    
    echo "=== Memory Scaling Test ===" >> "$RESULTS_FILE"
    
    local cores=4
    local memory_amounts=(4 8 16)
    
    # Test different memory allocations
    for memory in "${memory_amounts[@]}"; do
        if [ "$memory" -le "$TOTAL_RAM_GB" ]; then
            run_baseline_test "$cores" "$memory" "Memory-${memory}GB"
        fi
    done
    
    echo "" >> "$RESULTS_FILE"
}

run_optimization_test() {
    echo -e "${PURPLE}🚀 Testing optimization flags...${NC}"
    
    echo "=== Optimization Flags Test ===" >> "$RESULTS_FILE"
    
    local cores=4
    local memory=8
    
    # Test with different optimization flags
    echo -e "${BLUE}Testing with optimization flags...${NC}"
    local start_time=$(date +%s.%N)
    docker run --rm \
        --cpus="$cores" \
        --memory="${memory}g" \
        -v "$(pwd)/${BENCHMARK_DIR}/cavity:/home/openfoam/cavity:delegated" \
        -e OMP_NUM_THREADS="$cores" \
        -e WM_NCOMPPROCS="$cores" \
        -e FOAM_VERBOSE=1 \
        -e MALLOC_ARENA_MAX=4 \
        opencfd/openfoam-default:$OPENFOAM_VERSION \
        bash -c "cd cavity && blockMesh > /dev/null 2>&1 && simpleFoam > /dev/null 2>&1"
    local end_time=$(date +%s.%N)
    local optimized_time=$(echo "$end_time - $start_time" | bc)
    
    echo "Optimized flags: ${optimized_time}s" >> "$RESULTS_FILE"
    echo -e "${GREEN}Optimized runtime: ${optimized_time}s${NC}"
    echo "" >> "$RESULTS_FILE"
}

run_docker_desktop_settings_test() {
    echo -e "${PURPLE}⚙️ Testing Docker Desktop configurations...${NC}"
    
    echo "=== Docker Desktop Settings Test ===" >> "$RESULTS_FILE"
    
    # Get current Docker Desktop settings
    local current_cpus=$(docker info --format '{{.NCPU}}' 2>/dev/null || echo "Unknown")
    local current_memory=$(docker info --format '{{.MemTotal}}' 2>/dev/null | awk '{print int($1/1024/1024/1024)}' || echo "Unknown")
    
    echo "Current Docker Desktop allocation:" >> "$RESULTS_FILE"
    echo "  CPUs: $current_cpus" >> "$RESULTS_FILE"
    echo "  Memory: ${current_memory}GB" >> "$RESULTS_FILE"
    echo "" >> "$RESULTS_FILE"
}

generate_recommendations() {
    echo -e "${PURPLE}📊 Generating performance recommendations...${NC}"
    
    {
        echo "=== Performance Recommendations ==="
        echo ""
        echo "Based on your MacBook Pro specifications:"
        echo "  - Total Cores: $TOTAL_CORES"
        echo "  - Total RAM: ${TOTAL_RAM_GB}GB"
        echo "  - Chip: $CHIP_TYPE"
        echo ""
        
        # CPU recommendations
        local recommended_cores=$(( TOTAL_CORES * 3 / 4 ))
        echo "Recommended Docker Desktop settings:"
        echo "  - CPU Cores: $recommended_cores (75% of total)"
        
        # Memory recommendations
        if [ "$TOTAL_RAM_GB" -ge 32 ]; then
            local recommended_memory=$(( TOTAL_RAM_GB * 3 / 4 ))
            echo "  - Memory: ${recommended_memory}GB (75% of total)"
        elif [ "$TOTAL_RAM_GB" -ge 16 ]; then
            local recommended_memory=$(( TOTAL_RAM_GB * 2 / 3 ))
            echo "  - Memory: ${recommended_memory}GB (67% of total)"
        else
            local recommended_memory=$(( TOTAL_RAM_GB / 2 ))
            echo "  - Memory: ${recommended_memory}GB (50% of total)"
        fi
        
        echo "  - Swap: 2-4GB"
        echo "  - Disk Image Size: 100GB+"
        echo ""
        
        # macOS-specific recommendations
        if [[ $(uname -m) == "arm64" ]]; then
            echo "Apple Silicon specific recommendations:"
            echo "  - Enable 'Use Rosetta for x86_64/amd64 emulation'"
            echo "  - Use 'Apple Virtualization Framework' as VMM"
            echo "  - Enable 'VirtioFS' for file sharing"
        else
            echo "Intel Mac specific recommendations:"
            echo "  - Use 'HyperKit' as Virtual Machine Manager"
            echo "  - Use 'VirtioFS' or 'gRPC FUSE' for file sharing"
        fi
        
        echo ""
        echo "Volume mount recommendations:"
        echo "  - Use ':delegated' for source code directories"
        echo "  - Use ':cached' for build outputs and caches"
        echo ""
        
    } >> "$RESULTS_FILE"
}

cleanup() {
    echo -e "${YELLOW}🧹 Cleaning up test files...${NC}"
    # Remove test case directory but keep results
    rm -rf "${BENCHMARK_DIR}/cavity" 2>/dev/null || true
    echo -e "${GREEN}✅ Cleanup completed${NC}"
}

main() {
    print_header
    detect_system_specs
    prepare_test_case
    
    echo -e "${YELLOW}Running performance benchmarks...${NC}"
    echo ""
    
    run_volume_mount_tests
    run_parallel_scaling_test
    run_memory_scaling_test
    run_optimization_test
    run_docker_desktop_settings_test
    generate_recommendations
    
    cleanup
    
    echo ""
    echo -e "${GREEN}🎉 Benchmark completed!${NC}"
    echo -e "${BLUE}Results saved to: $RESULTS_FILE${NC}"
    echo ""
    echo -e "${YELLOW}📋 Summary:${NC}"
    tail -n 20 "$RESULTS_FILE"
}

# Handle script interruption
trap 'echo -e "\n${YELLOW}Benchmark interrupted by user${NC}"; cleanup; exit 130' INT

# Run main function
main "$@"