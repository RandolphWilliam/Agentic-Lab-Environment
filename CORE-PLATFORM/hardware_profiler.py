#!/usr/bin/env python3
"""
ChromaDB Adaptive Intelligence Platform - Hardware Profiler & Service Recommender

This module provides comprehensive hardware capability detection and generates
intelligent service recommendations for optimal task distribution between
local processing and cloud services.
"""

import json
import time
import psutil
import platform
import subprocess
from dataclasses import dataclass, asdict
from typing import Dict, List, Optional, Tuple
from pathlib import Path

try:
    import cpuinfo
    CPUINFO_AVAILABLE = True
except ImportError:
    CPUINFO_AVAILABLE = False

@dataclass
class CPUProfile:
    """CPU capability profile"""
    name: str
    cores_physical: int
    cores_logical: int
    base_frequency_ghz: float
    max_frequency_ghz: float
    cache_size_mb: int
    architecture: str
    vendor: str
    performance_score: float

@dataclass
class GPUProfile:
    """GPU capability profile"""
    name: str
    memory_gb: float
    compute_capability: Optional[str]
    driver_version: Optional[str]
    cuda_available: bool
    opencl_available: bool
    performance_score: float

@dataclass
class SystemProfile:
    """Complete system hardware profile"""
    cpu: CPUProfile
    gpus: List[GPUProfile]
    ram_gb: float
    storage_type: str
    storage_speed_mbps: float
    network_speed_mbps: float
    platform_info: Dict[str, str]
    performance_class: str  # "budget", "mid_tier", "high_end", "workstation"

@dataclass
class ServiceRecommendation:
    """Service recommendation with cost and performance analysis"""
    service_name: str
    service_type: str  # "gpu_cloud", "llm_inference", "vector_db", "document_processing"
    provider: str
    monthly_cost_estimate: float
    performance_improvement: float  # Expected improvement over local processing
    use_case: str
    priority: str  # "essential", "recommended", "optional"
    partner_tier: str  # "premium", "standard", "community"
    commission_rate: float

class HardwareProfiler:
    """Comprehensive hardware profiling with intelligent service recommendations"""
    
    def __init__(self):
        self.service_catalog = self._load_service_catalog()
        self.benchmark_cache = Path("./hardware_benchmark_cache.json")
        self.profile_cache = Path("./hardware_profile_cache.json")
        
    def _load_service_catalog(self) -> Dict:
        """Load service catalog with pricing and performance data"""
        return {
            "gpu_cloud": {
                "runpod": {
                    "rtx_4090": {"cost_per_hour": 0.89, "performance_multiplier": 8.5, "commission": 0.15},
                    "rtx_3090": {"cost_per_hour": 0.69, "performance_multiplier": 6.2, "commission": 0.15},
                    "a100": {"cost_per_hour": 1.89, "performance_multiplier": 12.0, "commission": 0.15}
                },
                "paperspace": {
                    "rtx_4000": {"cost_per_hour": 0.51, "performance_multiplier": 4.8, "commission": 0.10},
                    "a4000": {"cost_per_hour": 0.76, "performance_multiplier": 6.8, "commission": 0.10}
                },
                "lambda_labs": {
                    "rtx_6000": {"cost_per_hour": 0.50, "performance_multiplier": 5.5, "commission": 0.12}
                },
                "vast_ai": {
                    "rtx_3080": {"cost_per_hour": 0.35, "performance_multiplier": 5.0, "commission": 0.08}
                }
            },
            "llm_inference": {
                "openai": {
                    "gpt-4": {"cost_per_1k_tokens": 0.03, "performance_multiplier": 1.0, "commission": 0.05},
                    "gpt-3.5-turbo": {"cost_per_1k_tokens": 0.002, "performance_multiplier": 0.8, "commission": 0.05}
                },
                "anthropic": {
                    "claude-3-opus": {"cost_per_1k_tokens": 0.015, "performance_multiplier": 1.1, "commission": 0.05},
                    "claude-3-sonnet": {"cost_per_1k_tokens": 0.003, "performance_multiplier": 0.9, "commission": 0.05}
                },
                "together_ai": {
                    "llama-2-70b": {"cost_per_1k_tokens": 0.0008, "performance_multiplier": 0.75, "commission": 0.12}
                }
            },
            "vector_db": {
                "pinecone": {
                    "starter": {"monthly_cost": 70, "performance_multiplier": 3.0, "commission": 0.10},
                    "standard": {"monthly_cost": 140, "performance_multiplier": 4.5, "commission": 0.10}
                },
                "weaviate": {
                    "cloud": {"monthly_cost": 50, "performance_multiplier": 2.5, "commission": 0.08}
                },
                "qdrant": {
                    "cloud": {"monthly_cost": 40, "performance_multiplier": 2.2, "commission": 0.08}
                }
            }
        }
    
    def profile_cpu(self) -> CPUProfile:
        """Profile CPU capabilities and performance"""
        try:
            # Get CPU information
            if CPUINFO_AVAILABLE:
                cpu_info = cpuinfo.get_cpu_info()
                name = cpu_info.get('brand_raw', 'Unknown CPU')
                base_freq = cpu_info.get('hz_advertised_friendly', '0 Hz')
                max_freq = cpu_info.get('hz_actual_friendly', '0 Hz')
            else:
                name = platform.processor()
                base_freq = "Unknown"
                max_freq = "Unknown"
            
            # System CPU information
            cores_physical = psutil.cpu_count(logical=False)
            cores_logical = psutil.cpu_count(logical=True)
            
            # CPU frequency (current)
            cpu_freq = psutil.cpu_freq()
            current_freq = cpu_freq.current if cpu_freq else 0
            max_freq_detected = cpu_freq.max if cpu_freq else 0
            
            # Performance scoring based on known CPU characteristics
            performance_score = self._calculate_cpu_performance_score(
                name, cores_physical, cores_logical, max_freq_detected
            )
            
            return CPUProfile(
                name=name,
                cores_physical=cores_physical or 1,
                cores_logical=cores_logical or 1,
                base_frequency_ghz=current_freq / 1000.0 if current_freq else 0.0,
                max_frequency_ghz=max_freq_detected / 1000.0 if max_freq_detected else 0.0,
                cache_size_mb=self._estimate_cache_size(name),
                architecture=platform.machine(),
                vendor=self._detect_cpu_vendor(name),
                performance_score=performance_score
            )
        except Exception as e:
            print(f"CPU profiling error: {e}")
            return CPUProfile("Unknown", 1, 1, 0.0, 0.0, 0, "unknown", "unknown", 1.0)
    
    def profile_gpu(self) -> List[GPUProfile]:
        """Profile GPU capabilities including CUDA and OpenCL"""
        gpus = []
        
        # NVIDIA GPU detection
        try:
            nvidia_output = subprocess.run(
                ['nvidia-smi', '--query-gpu=name,memory.total,driver_version', 
                 '--format=csv,noheader,nounits'],
                capture_output=True, text=True, timeout=10
            )
            
            if nvidia_output.returncode == 0:
                for line in nvidia_output.stdout.strip().split('\n'):
                    if line.strip():
                        parts = [p.strip() for p in line.split(',')]
                        if len(parts) >= 3:
                            gpu = GPUProfile(
                                name=parts[0],
                                memory_gb=float(parts[1]) / 1024.0,
                                compute_capability=self._detect_cuda_capability(parts[0]),
                                driver_version=parts[2],
                                cuda_available=True,
                                opencl_available=True,  # NVIDIA supports both
                                performance_score=self._calculate_gpu_performance_score(parts[0])
                            )
                            gpus.append(gpu)
        except (subprocess.TimeoutExpired, FileNotFoundError):
            pass
        
        # AMD GPU detection (for systems like 5700G)
        try:
            # Try to detect AMD GPUs via lspci
            lspci_output = subprocess.run(
                ['lspci', '-nn'], capture_output=True, text=True, timeout=10
            )
            
            if lspci_output.returncode == 0:
                for line in lspci_output.stdout.split('\n'):
                    if 'VGA' in line and ('AMD' in line or 'ATI' in line):
                        # Extract GPU name from lspci output
                        gpu_name = self._extract_amd_gpu_name(line)
                        if gpu_name and not any(gpu.name == gpu_name for gpu in gpus):
                            gpu = GPUProfile(
                                name=gpu_name,
                                memory_gb=self._estimate_amd_gpu_memory(gpu_name),
                                compute_capability=None,
                                driver_version=None,
                                cuda_available=False,
                                opencl_available=True,  # AMD supports OpenCL
                                performance_score=self._calculate_gpu_performance_score(gpu_name)
                            )
                            gpus.append(gpu)
        except (subprocess.TimeoutExpired, FileNotFoundError):
            pass
        
        # If no discrete GPUs found, check for integrated graphics
        if not gpus:
            integrated_gpu = self._detect_integrated_gpu()
            if integrated_gpu:
                gpus.append(integrated_gpu)
        
        return gpus
    
    def profile_system_complete(self) -> SystemProfile:
        """Generate complete system profile"""
        # Check cache first
        if self.profile_cache.exists():
            try:
                with open(self.profile_cache, 'r') as f:
                    cached_data = json.load(f)
                    # Cache valid for 24 hours
                    if time.time() - cached_data.get('timestamp', 0) < 86400:
                        return SystemProfile(**cached_data['profile'])
            except (json.JSONDecodeError, KeyError):
                pass
        
        print("🔍 Profiling system hardware capabilities...")
        
        # Profile individual components
        cpu = self.profile_cpu()
        gpus = self.profile_gpu()
        
        # System memory
        ram_info = psutil.virtual_memory()
        ram_gb = ram_info.total / (1024**3)
        
        # Storage profiling
        storage_type, storage_speed = self._profile_storage()
        
        # Network speed estimation
        network_speed = self._estimate_network_speed()
        
        # Platform information
        platform_info = {
            "system": platform.system(),
            "release": platform.release(),
            "version": platform.version(),
            "machine": platform.machine(),
            "processor": platform.processor()
        }
        
        # Determine performance class
        performance_class = self._classify_system_performance(cpu, gpus, ram_gb)
        
        profile = SystemProfile(
            cpu=cpu,
            gpus=gpus,
            ram_gb=ram_gb,
            storage_type=storage_type,
            storage_speed_mbps=storage_speed,
            network_speed_mbps=network_speed,
            platform_info=platform_info,
            performance_class=performance_class
        )
        
        # Cache the profile
        cache_data = {
            "timestamp": time.time(),
            "profile": asdict(profile)
        }
        with open(self.profile_cache, 'w') as f:
            json.dump(cache_data, f, indent=2)
        
        return profile
    
    def generate_service_recommendations(self, 
                                       profile: SystemProfile,
                                       task_scale: str = "medium",
                                       budget_range: str = "moderate") -> List[ServiceRecommendation]:
        """Generate intelligent service recommendations based on hardware profile"""
        
        recommendations = []
        
        # GPU Cloud recommendations
        if profile.performance_class in ["budget", "mid_tier"]:
            # Local GPU insufficient, recommend cloud GPU
            gpu_recs = self._recommend_gpu_services(profile, task_scale, budget_range)
            recommendations.extend(gpu_recs)
        
        # LLM Inference recommendations
        llm_recs = self._recommend_llm_services(profile, task_scale, budget_range)
        recommendations.extend(llm_recs)
        
        # Vector Database recommendations
        if task_scale in ["large", "enterprise"]:
            vector_recs = self._recommend_vector_services(profile, task_scale, budget_range)
            recommendations.extend(vector_recs)
        
        # Sort by priority and performance improvement
        recommendations.sort(key=lambda x: (
            {"essential": 0, "recommended": 1, "optional": 2}[x.priority],
            -x.performance_improvement
        ))
        
        return recommendations
    
    def _calculate_cpu_performance_score(self, name: str, physical_cores: int, 
                                       logical_cores: int, max_freq: float) -> float:
        """Calculate CPU performance score based on specifications"""
        base_score = 1.0
        
        # Core count scoring
        core_score = (physical_cores * 0.7 + logical_cores * 0.3) / 8.0
        
        # Frequency scoring (normalized to 3.5 GHz)
        freq_score = (max_freq / 1000.0) / 3.5 if max_freq > 0 else 1.0
        
        # Architecture-specific bonuses
        if any(arch in name.lower() for arch in ['ryzen', 'threadripper']):
            arch_bonus = 1.2  # AMD Ryzen efficiency
        elif any(arch in name.lower() for arch in ['core i9', 'core i7']):
            arch_bonus = 1.1  # Intel high-end
        elif '5700g' in name.lower():
            arch_bonus = 1.15  # Specific boost for user's hardware
        else:
            arch_bonus = 1.0
        
        return base_score * core_score * freq_score * arch_bonus
    
    def _calculate_gpu_performance_score(self, gpu_name: str) -> float:
        """Calculate GPU performance score for ML/AI workloads"""
        gpu_lower = gpu_name.lower()
        
        # High-end consumer/prosumer GPUs
        if any(model in gpu_lower for model in ['rtx 4090', 'rtx 4080']):
            return 10.0
        elif any(model in gpu_lower for model in ['rtx 3090', 'rtx 3080']):
            return 8.0
        elif any(model in gpu_lower for model in ['rtx 4070', 'rtx 3070']):
            return 6.0
        elif any(model in gpu_lower for model in ['rtx 4060', 'rtx 3060']):
            return 4.0
        
        # AMD GPUs
        elif any(model in gpu_lower for model in ['rx 7900', 'rx 6900']):
            return 7.0
        elif any(model in gpu_lower for model in ['rx 7800', 'rx 6800']):
            return 6.0
        elif any(model in gpu_lower for model in ['rx 7700', 'rx 6700']):
            return 5.0
        
        # Integrated graphics (like 5700G)
        elif any(model in gpu_lower for model in ['vega', 'rdna']):
            return 2.0
        elif 'intel' in gpu_lower and any(model in gpu_lower for model in ['xe', 'iris']):
            return 1.5
        
        # Default for unknown GPUs
        return 1.0
    
    def _recommend_gpu_services(self, profile: SystemProfile, task_scale: str, budget: str) -> List[ServiceRecommendation]:
        """Recommend GPU cloud services based on local capabilities"""
        recommendations = []
        
        # Determine if local GPU is insufficient
        local_gpu_score = max([gpu.performance_score for gpu in profile.gpus], default=0)
        
        if local_gpu_score < 5.0 or task_scale == "large":
            # Recommend cloud GPU services
            if budget == "premium":
                recommendations.append(ServiceRecommendation(
                    service_name="RunPod RTX 4090",
                    service_type="gpu_cloud",
                    provider="runpod",
                    monthly_cost_estimate=200.0,  # ~8 hours/day usage
                    performance_improvement=8.5 / max(local_gpu_score, 1.0),
                    use_case="High-performance embedding generation and model training",
                    priority="recommended",
                    partner_tier="premium",
                    commission_rate=0.15
                ))
            
            if budget in ["moderate", "premium"]:
                recommendations.append(ServiceRecommendation(
                    service_name="Vast.ai RTX 3080",
                    service_type="gpu_cloud", 
                    provider="vast_ai",
                    monthly_cost_estimate=100.0,
                    performance_improvement=5.0 / max(local_gpu_score, 1.0),
                    use_case="Cost-effective batch processing for large document corpora",
                    priority="recommended",
                    partner_tier="standard",
                    commission_rate=0.08
                ))
        
        return recommendations
    
    def _recommend_llm_services(self, profile: SystemProfile, task_scale: str, budget: str) -> List[ServiceRecommendation]:
        """Recommend LLM inference services"""
        recommendations = []
        
        # Always recommend some LLM service for optimization and failure analysis
        if budget in ["moderate", "premium"]:
            recommendations.append(ServiceRecommendation(
                service_name="OpenAI GPT-4",
                service_type="llm_inference",
                provider="openai", 
                monthly_cost_estimate=150.0,
                performance_improvement=1.0,  # Quality baseline
                use_case="Search failure analysis and system optimization suggestions",
                priority="recommended",
                partner_tier="premium",
                commission_rate=0.05
            ))
        
        # Budget-friendly option
        recommendations.append(ServiceRecommendation(
            service_name="OpenAI GPT-3.5 Turbo",
            service_type="llm_inference",
            provider="openai",
            monthly_cost_estimate=30.0,
            performance_improvement=0.8,
            use_case="Basic optimization and content processing",
            priority="essential",
            partner_tier="standard", 
            commission_rate=0.05
        ))
        
        return recommendations
    
    def _recommend_vector_services(self, profile: SystemProfile, task_scale: str, budget: str) -> List[ServiceRecommendation]:
        """Recommend vector database services for large-scale deployments"""
        recommendations = []
        
        if task_scale in ["large", "enterprise"]:
            if budget == "premium":
                recommendations.append(ServiceRecommendation(
                    service_name="Pinecone Standard",
                    service_type="vector_db",
                    provider="pinecone",
                    monthly_cost_estimate=140.0,
                    performance_improvement=4.5,
                    use_case="Enterprise-scale vector search with high performance SLA",
                    priority="recommended",
                    partner_tier="premium",
                    commission_rate=0.10
                ))
        
        return recommendations
    
    # Helper methods for hardware detection
    def _detect_cpu_vendor(self, cpu_name: str) -> str:
        """Detect CPU vendor from name"""
        cpu_lower = cpu_name.lower()
        if any(vendor in cpu_lower for vendor in ['amd', 'ryzen']):
            return "AMD"
        elif any(vendor in cpu_lower for vendor in ['intel', 'core']):
            return "Intel"
        else:
            return "Unknown"
    
    def _estimate_cache_size(self, cpu_name: str) -> int:
        """Estimate CPU cache size based on model"""
        cpu_lower = cpu_name.lower()
        if 'ryzen' in cpu_lower and any(model in cpu_lower for model in ['9', 'threadripper']):
            return 64  # High-end Ryzen
        elif 'ryzen' in cpu_lower and any(model in cpu_lower for model in ['7', '5']):
            return 32  # Mid-range Ryzen
        elif 'core i9' in cpu_lower:
            return 24  # Intel i9
        elif 'core i7' in cpu_lower:
            return 16  # Intel i7
        else:
            return 8   # Conservative estimate
    
    def _detect_cuda_capability(self, gpu_name: str) -> Optional[str]:
        """Detect CUDA compute capability"""
        gpu_lower = gpu_name.lower()
        if 'rtx 40' in gpu_lower:
            return "8.9"  # Ada Lovelace
        elif 'rtx 30' in gpu_lower:
            return "8.6"  # Ampere
        elif 'rtx 20' in gpu_lower:
            return "7.5"  # Turing
        else:
            return None
    
    def _extract_amd_gpu_name(self, lspci_line: str) -> Optional[str]:
        """Extract AMD GPU name from lspci output"""
        # Simplified extraction - would need more sophisticated parsing
        if 'VGA' in lspci_line and ('AMD' in lspci_line or 'ATI' in lspci_line):
            # Extract GPU model name
            parts = lspci_line.split(']')[-1].strip()
            return parts[:50] if parts else "AMD GPU"
        return None
    
    def _estimate_amd_gpu_memory(self, gpu_name: str) -> float:
        """Estimate AMD GPU memory based on model"""
        gpu_lower = gpu_name.lower()
        if '5700g' in gpu_lower or 'vega' in gpu_lower:
            return 1.0  # Shared system memory, conservative estimate
        else:
            return 4.0  # Default estimate for discrete AMD GPUs
    
    def _detect_integrated_gpu(self) -> Optional[GPUProfile]:
        """Detect integrated graphics"""
        try:
            # Check for common integrated graphics indicators
            system_info = platform.uname()
            if '5700g' in system_info.processor.lower():
                return GPUProfile(
                    name="AMD Radeon Graphics (5700G Integrated)",
                    memory_gb=2.0,  # Shared system memory
                    compute_capability=None,
                    driver_version=None,
                    cuda_available=False,
                    opencl_available=True,
                    performance_score=2.0
                )
        except:
            pass
        return None
    
    def _profile_storage(self) -> Tuple[str, float]:
        """Profile storage type and speed"""
        try:
            # Simple heuristic - actual implementation would need more sophisticated detection
            storage_type = "SSD"  # Default assumption for modern systems
            storage_speed = 500.0  # Conservative SSD estimate (MB/s)
            return storage_type, storage_speed
        except:
            return "Unknown", 100.0
    
    def _estimate_network_speed(self) -> float:
        """Estimate network speed"""
        # Would implement actual network speed test in production
        return 100.0  # Conservative estimate (Mbps)
    
    def _classify_system_performance(self, cpu: CPUProfile, gpus: List[GPUProfile], ram_gb: float) -> str:
        """Classify overall system performance"""
        cpu_score = cpu.performance_score
        gpu_score = max([gpu.performance_score for gpu in gpus], default=1.0)
        ram_score = ram_gb / 16.0  # Normalized to 16GB
        
        overall_score = (cpu_score * 0.4 + gpu_score * 0.4 + ram_score * 0.2)
        
        if overall_score >= 8.0:
            return "workstation"
        elif overall_score >= 6.0:
            return "high_end"
        elif overall_score >= 3.0:
            return "mid_tier"
        else:
            return "budget"

def main():
    """Main function for hardware profiling"""
    profiler = HardwareProfiler()
    
    print("🔍 ChromaDB Platform - Hardware Profiling & Service Recommendations")
    print("=" * 70)
    
    # Generate complete system profile
    profile = profiler.profile_system_complete()
    
    # Display system information
    print(f"\n🖥️  System Profile:")
    print(f"Performance Class: {profile.performance_class.upper()}")
    print(f"Platform: {profile.platform_info['system']} {profile.platform_info['machine']}")
    
    print(f"\n💾 CPU: {profile.cpu.name}")
    print(f"Cores: {profile.cpu.cores_physical}P/{profile.cpu.cores_logical}T")
    print(f"Frequency: {profile.cpu.max_frequency_ghz:.2f} GHz")
    print(f"Performance Score: {profile.cpu.performance_score:.2f}")
    
    print(f"\n🎮 GPUs:")
    for gpu in profile.gpus:
        print(f"  • {gpu.name}")
        print(f"    Memory: {gpu.memory_gb:.1f} GB")
        print(f"    CUDA: {'Yes' if gpu.cuda_available else 'No'}")
        print(f"    Performance Score: {gpu.performance_score:.2f}")
    
    print(f"\n💾 RAM: {profile.ram_gb:.1f} GB")
    print(f"💾 Storage: {profile.storage_type} ({profile.storage_speed_mbps:.0f} MB/s)")
    
    # Generate service recommendations
    print(f"\n🚀 Service Recommendations:")
    recommendations = profiler.generate_service_recommendations(profile)
    
    for rec in recommendations:
        print(f"\n  📦 {rec.service_name}")
        print(f"     Provider: {rec.provider}")
        print(f"     Monthly Cost: ${rec.monthly_cost_estimate:.2f}")
        print(f"     Performance Boost: {rec.performance_improvement:.1f}x")
        print(f"     Use Case: {rec.use_case}")
        print(f"     Priority: {rec.priority.upper()}")
    
    # Save detailed profile
    profile_file = Path("hardware_profile_detailed.json")
    with open(profile_file, 'w') as f:
        json.dump({
            "profile": asdict(profile),
            "recommendations": [asdict(rec) for rec in recommendations],
            "generated_at": time.time()
        }, f, indent=2)
    
    print(f"\n💾 Detailed profile saved to: {profile_file}")
    print("\n✅ Hardware profiling complete!")

if __name__ == "__main__":
    main()