# OpenFOAM Docker Performance Guide - Quick Reference

## 🚀 Quick Start

### 1. Run Performance Benchmark
```bash
./scripts/benchmark-performance.sh
```
This will test your system and provide optimized settings recommendations.

### 2. Use Optimized Launcher
```bash
# Interactive shell
./scripts/openfoam-pro

# Run specific command
./scripts/openfoam-pro blockMesh

# Development environment
./scripts/openfoam-pro -i dev

# With profiling
./scripts/openfoam-pro --profile simpleFoam
```

### 3. Use High-Performance Compose
```bash
# Start development environment
docker-compose -f docker-compose.performance.yml up -d openfoam-dev

# Enter development container
docker exec -it openfoam-development bash

# Start specialized services
docker-compose -f docker-compose.performance.yml --profile build up -d
docker-compose -f docker-compose.performance.yml --profile simulation up -d
```

## ⚙️ Recommended Docker Desktop Settings

### Apple Silicon (M1/M2/M3) Macs
```
General:
├── Use Rosetta for x86_64/amd64 emulation: ✓ Enabled
├── Virtual Machine Manager: Apple Virtualization Framework  
├── File sharing: VirtioFS
└── Use kernel networking for UDP: ✓ Enabled

Resources:
├── CPU Cores: 75% of total (e.g., 6 cores for 8-core system)
├── Memory: 50-75% of total (e.g., 12GB for 16GB system)
├── Swap: 2-4GB
└── Disk Image Size: 100GB+
```

### Intel Macs
```
General:
├── Virtual Machine Manager: HyperKit
└── File sharing: VirtioFS or gRPC FUSE

Resources:
├── CPU Cores: 75% of total
├── Memory: 50-75% of total  
├── Swap: 2-4GB
└── Disk Image Size: 100GB+
```

## 📁 File Structure
```
project/
├── OpenFOAM-Docker-Development-Guide-macOS.md  # Complete guide
├── docker-compose.performance.yml              # Optimized compose
├── scripts/
│   ├── openfoam-pro                           # Enhanced launcher
│   └── benchmark-performance.sh               # Performance testing
└── cases/                                      # Your OpenFOAM cases
```

## 🔧 Volume Mount Optimization

### For Source Code (Best Write Performance)
```yaml
volumes:
  - ./src:/home/openfoam/src:delegated
```

### For Build Outputs (Best Read Performance)  
```yaml
volumes:
  - ./results:/home/openfoam/results:cached
```

### For Caches (Persistent Data)
```yaml
volumes:
  - ~/.docker/openfoam-cache:/home/openfoam/.cache:cached
```

## ⚡ Quick Performance Tips

1. **Allocate 75% of CPU cores** to Docker Desktop
2. **Use VirtioFS** file sharing on macOS 12.5+
3. **Enable Rosetta** for Apple Silicon Macs
4. **Use delegated mounts** for source code directories
5. **Use cached mounts** for build outputs
6. **Set up ccache** for faster compilation
7. **Monitor resource usage** with `docker stats`
8. **Clean up regularly** with `docker system prune`

## 📊 Performance Monitoring

### Real-time Monitoring
```bash
# Container stats
docker stats

# System monitoring
top -pid $(pgrep Docker)

# Detailed resource usage
htop -p $(pgrep Docker)
```

### OpenFOAM Profiling
```bash
# Time simulation
time simpleFoam

# Memory profiling  
valgrind --tool=massif simpleFoam

# Parallel efficiency test
for np in 1 2 4 8; do
  echo "Testing $np cores"
  time mpirun -np $np simpleFoam -parallel
done
```

## 🛠️ Troubleshooting

### Slow Performance
1. Check Docker Desktop resource allocation
2. Verify volume mount types (use :delegated for source)
3. Monitor thermal throttling with Activity Monitor
4. Check available disk space

### High CPU Usage When Idle
1. Switch Virtual Machine Manager to HyperKit (Intel Macs)
2. Disable unnecessary Docker Desktop features
3. Restart Docker Desktop

### Memory Issues
1. Increase Docker memory limit
2. Add swap space
3. Use memory-efficient OpenFOAM settings

## 📚 Documentation

- **Complete Guide**: `OpenFOAM-Docker-Development-Guide-macOS.md`
- **Script Help**: `./scripts/openfoam-pro --help`
- **Docker Compose Reference**: `docker-compose.performance.yml`

## 🆘 Support

If you encounter issues:
1. Run the benchmark script to identify bottlenecks
2. Check the complete guide for detailed explanations
3. Verify Docker Desktop settings match recommendations
4. Monitor system resources during operations

---

*For detailed explanations and advanced configurations, see the complete guide in `OpenFOAM-Docker-Development-Guide-macOS.md`*