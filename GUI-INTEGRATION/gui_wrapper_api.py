#!/usr/bin/env python3
"""
SEFIROT GUI WRAPPER API
Ready-to-integrate API for GUI applications

This module provides a complete API interface for GUI applications to integrate
with the Sefirot numbered installation sequence. 

🚀 PRIMARY TARGET: ELECTRON APPLICATIONS
While this API supports multiple frameworks, it is specifically designed and 
optimized for Electron-based GUI implementations. See ELECTRON-PRIORITY.md 
for complete implementation strategy and reasoning.

Designed for easy integration with any GUI framework (Electron, Qt, Tkinter, web-based, etc.).
"""

import os
import sys
import json
import yaml
import asyncio
import subprocess
import threading
import time
from pathlib import Path
from typing import Dict, List, Optional, Any, Callable, Union
from dataclasses import dataclass, asdict
from datetime import datetime
import logging

@dataclass
class InstallationStep:
    """Individual installation step information"""
    number: int
    name: str
    description: str
    script_path: str
    status: str = "pending"  # pending, running, completed, failed
    progress: float = 0.0
    start_time: Optional[datetime] = None
    completion_time: Optional[datetime] = None
    output: List[str] = None
    errors: List[str] = None
    
    def __post_init__(self):
        if self.output is None:
            self.output = []
        if self.errors is None:
            self.errors = []

@dataclass
class SystemRequirements:
    """System requirements check results"""
    macos_version: str
    architecture: str
    available_disk_gb: int
    memory_gb: float
    cpu_cores: int
    requirements_met: bool
    issues: List[str] = None
    
    def __post_init__(self):
        if self.issues is None:
            self.issues = []

class SefirotGUIAPI:
    """
    Complete GUI API for Sefirot Installation
    
    This class provides all necessary methods for GUI applications to:
    - Check system requirements
    - Run installation steps with progress tracking
    - Get real-time status updates
    - Handle errors and recovery
    - Provide user feedback
    """
    
    def __init__(self, distribution_path: str = None):
        self.distribution_path = Path(distribution_path) if distribution_path else Path(__file__).parent.parent
        self.sequenced_install_path = self.distribution_path / "SEQUENCED-INSTALLATION"
        self.sefirot_dir = Path.home() / ".sefirot"
        self.install_dir = self.sefirot_dir / "installation"
        
        # Installation steps configuration
        self.installation_steps = [
            InstallationStep(
                number=1,
                name="Environment Setup",
                description="Installing system prerequisites and development environment",
                script_path=str(self.sequenced_install_path / "step_01_environment_setup.sh")
            ),
            InstallationStep(
                number=2,
                name="Python Environment & Dependencies",
                description="Setting up Python 3.11 environment with AI/ML dependencies",
                script_path=str(self.sequenced_install_path / "step_02_python_environment.sh")
            ),
            InstallationStep(
                number=3,
                name="ChromaDB Intelligence Platform",
                description="Initializing ChromaDB intelligence engine and privacy framework",
                script_path=str(self.sequenced_install_path / "step_03_chromadb_platform.sh")
            ),
            InstallationStep(
                number=4,
                name="Obsidian Vault Integration",
                description="Installing Obsidian with custom plugins and vault integration",
                script_path=str(self.sequenced_install_path / "step_04_obsidian_integration.sh")
            ),
            InstallationStep(
                number=5,
                name="Final Configuration & Testing",
                description="Final system configuration, testing, and validation",
                script_path=str(self.sequenced_install_path / "step_05_final_configuration.sh")
            )
        ]
        
        # Progress tracking
        self.current_step = 0
        self.is_running = False
        self.installation_complete = False
        self.progress_callbacks = []
        self.status_callbacks = []
        self.error_callbacks = []
        
        # Logging setup
        self._setup_logging()
        
        # Load existing state if available
        self._load_existing_state()
    
    def _setup_logging(self):
        """Setup logging for GUI API"""
        log_dir = self.sefirot_dir / "logs"
        log_dir.mkdir(parents=True, exist_ok=True)
        
        logging.basicConfig(
            level=logging.INFO,
            format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
            handlers=[
                logging.FileHandler(log_dir / "gui_api.log"),
                logging.StreamHandler()
            ]
        )
        self.logger = logging.getLogger("SefirotGUI")
    
    def _load_existing_state(self):
        """Load existing installation state"""
        try:
            # Check for existing installation progress
            for step in self.installation_steps:
                status_file = self.install_dir / f"step_{step.number}_status.txt"
                completion_file = self.install_dir / f"step_{step.number}_completion.json"
                
                if status_file.exists():
                    status_content = status_file.read_text().strip()
                    if "completed" in status_content:
                        step.status = "completed"
                        step.progress = 100.0
                        self.current_step = max(self.current_step, step.number)
                    elif "failed" in status_content:
                        step.status = "failed"
                        step.progress = 0.0
                        break
                        
                if completion_file.exists():
                    try:
                        completion_data = json.loads(completion_file.read_text())
                        step.completion_time = datetime.fromisoformat(completion_data.get("completion_time", ""))
                        step.status = completion_data.get("status", step.status)
                    except:
                        pass
            
            # Check if installation is complete
            complete_file = self.install_dir / "installation_complete.json"
            if complete_file.exists():
                self.installation_complete = True
                
        except Exception as e:
            self.logger.warning(f"Could not load existing state: {e}")
    
    # Callback Management
    def add_progress_callback(self, callback: Callable[[int, float, str], None]):
        """Add callback for progress updates: callback(step_number, progress_percent, message)"""
        self.progress_callbacks.append(callback)
    
    def add_status_callback(self, callback: Callable[[str, Dict], None]):
        """Add callback for status updates: callback(status, data)"""
        self.status_callbacks.append(callback)
    
    def add_error_callback(self, callback: Callable[[str, Exception], None]):
        """Add callback for errors: callback(step_name, error)"""
        self.error_callbacks.append(callback)
    
    def _notify_progress(self, step_number: int, progress: float, message: str):
        """Notify all progress callbacks"""
        for callback in self.progress_callbacks:
            try:
                callback(step_number, progress, message)
            except Exception as e:
                self.logger.error(f"Progress callback error: {e}")
    
    def _notify_status(self, status: str, data: Dict = None):
        """Notify all status callbacks"""
        for callback in self.status_callbacks:
            try:
                callback(status, data or {})
            except Exception as e:
                self.logger.error(f"Status callback error: {e}")
    
    def _notify_error(self, step_name: str, error: Exception):
        """Notify all error callbacks"""
        for callback in self.error_callbacks:
            try:
                callback(step_name, error)
            except Exception as e:
                self.logger.error(f"Error callback error: {e}")
    
    # System Requirements
    def check_system_requirements(self) -> SystemRequirements:
        """
        Check system requirements for Sefirot installation
        
        Returns:
            SystemRequirements: Detailed requirements check results
        """
        try:
            # Get macOS version
            result = subprocess.run(["sw_vers", "-productVersion"], capture_output=True, text=True)
            macos_version = result.stdout.strip()
            
            # Get architecture
            result = subprocess.run(["uname", "-m"], capture_output=True, text=True)
            architecture = result.stdout.strip()
            
            # Get available disk space
            result = subprocess.run(["df", "-g", str(Path.home())], capture_output=True, text=True)
            disk_info = result.stdout.split('\n')[1].split()
            available_disk_gb = int(disk_info[3])
            
            # Get memory
            result = subprocess.run(["sysctl", "-n", "hw.memsize"], capture_output=True, text=True)
            memory_bytes = int(result.stdout.strip())
            memory_gb = memory_bytes / (1024 ** 3)
            
            # Get CPU cores
            result = subprocess.run(["sysctl", "-n", "hw.physicalcpu"], capture_output=True, text=True)
            cpu_cores = int(result.stdout.strip())
            
            # Check requirements
            issues = []
            requirements_met = True
            
            # macOS version (require 12.0+)
            macos_major = int(macos_version.split('.')[0])
            if macos_major < 12:
                issues.append(f"macOS version too old (requires 12.0+, found {macos_version})")
                requirements_met = False
            
            # Disk space (require 10GB)
            if available_disk_gb < 10:
                issues.append(f"Insufficient disk space (requires 10GB, available {available_disk_gb}GB)")
                requirements_met = False
            
            # Memory (recommend 8GB)
            if memory_gb < 8:
                issues.append(f"Low memory (recommended 8GB+, found {memory_gb:.1f}GB)")
                # Don't fail installation for this, just warn
            
            return SystemRequirements(
                macos_version=macos_version,
                architecture=architecture,
                available_disk_gb=available_disk_gb,
                memory_gb=memory_gb,
                cpu_cores=cpu_cores,
                requirements_met=requirements_met,
                issues=issues
            )
            
        except Exception as e:
            self.logger.error(f"System requirements check failed: {e}")
            return SystemRequirements(
                macos_version="unknown",
                architecture="unknown", 
                available_disk_gb=0,
                memory_gb=0.0,
                cpu_cores=0,
                requirements_met=False,
                issues=[f"System check error: {e}"]
            )
    
    # Installation Control
    def get_installation_status(self) -> Dict[str, Any]:
        """
        Get current installation status
        
        Returns:
            Dict with complete installation status information
        """
        return {
            "is_running": self.is_running,
            "installation_complete": self.installation_complete,
            "current_step": self.current_step,
            "total_steps": len(self.installation_steps),
            "steps": [asdict(step) for step in self.installation_steps],
            "overall_progress": self._calculate_overall_progress()
        }
    
    def _calculate_overall_progress(self) -> float:
        """Calculate overall installation progress"""
        if not self.installation_steps:
            return 0.0
            
        total_progress = sum(step.progress for step in self.installation_steps)
        return total_progress / len(self.installation_steps)
    
    def start_installation(self, start_from_step: int = 1) -> bool:
        """
        Start installation process
        
        Args:
            start_from_step: Step number to start from (1-5)
            
        Returns:
            bool: True if installation started successfully
        """
        if self.is_running:
            return False
            
        if start_from_step < 1 or start_from_step > len(self.installation_steps):
            return False
            
        self.is_running = True
        self.current_step = start_from_step - 1
        
        # Start installation in background thread
        install_thread = threading.Thread(
            target=self._run_installation_sequence,
            args=(start_from_step,),
            daemon=True
        )
        install_thread.start()
        
        return True
    
    def _run_installation_sequence(self, start_step: int):
        """Run the complete installation sequence"""
        try:
            self._notify_status("installation_started", {"start_step": start_step})
            
            for i in range(start_step - 1, len(self.installation_steps)):
                step = self.installation_steps[i]
                self.current_step = step.number
                
                # Skip if already completed
                if step.status == "completed":
                    continue
                    
                success = self._run_single_step(step)
                
                if not success:
                    self.is_running = False
                    self._notify_status("installation_failed", {"failed_step": step.number})
                    return
                    
            # All steps completed
            self.installation_complete = True
            self.is_running = False
            self._notify_status("installation_completed", {})
            
        except Exception as e:
            self.is_running = False
            self.logger.error(f"Installation sequence failed: {e}")
            self._notify_error("installation_sequence", e)
    
    def _run_single_step(self, step: InstallationStep) -> bool:
        """
        Run a single installation step
        
        Args:
            step: InstallationStep to execute
            
        Returns:
            bool: True if step completed successfully
        """
        try:
            step.status = "running"
            step.progress = 0.0
            step.start_time = datetime.now()
            step.output = []
            step.errors = []
            
            self._notify_progress(step.number, 0.0, f"Starting {step.name}")
            
            # Check if script exists
            if not Path(step.script_path).exists():
                raise FileNotFoundError(f"Installation script not found: {step.script_path}")
            
            # Run installation script
            process = subprocess.Popen(
                ["/bin/bash", step.script_path],
                stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT,
                text=True,
                bufsize=1,
                universal_newlines=True
            )
            
            # Monitor progress
            output_lines = []
            while True:
                line = process.stdout.readline()
                if not line and process.poll() is not None:
                    break
                    
                if line:
                    line = line.rstrip()
                    output_lines.append(line)
                    step.output.append(line)
                    
                    # Extract progress information from output
                    progress = self._extract_progress_from_output(line)
                    if progress >= 0:
                        step.progress = progress
                        self._notify_progress(step.number, progress, line)
                    
                    # Check for errors
                    if "❌" in line or "ERROR" in line or "FAILED" in line:
                        step.errors.append(line)
            
            # Wait for process completion
            return_code = process.wait()
            
            if return_code == 0:
                step.status = "completed"
                step.progress = 100.0
                step.completion_time = datetime.now()
                self._notify_progress(step.number, 100.0, f"{step.name} completed successfully")
                return True
            else:
                step.status = "failed"
                step.completion_time = datetime.now()
                error_msg = f"{step.name} failed with return code {return_code}"
                self._notify_error(step.name, Exception(error_msg))
                return False
                
        except Exception as e:
            step.status = "failed"
            step.completion_time = datetime.now()
            step.errors.append(str(e))
            self.logger.error(f"Step {step.number} failed: {e}")
            self._notify_error(step.name, e)
            return False
    
    def _extract_progress_from_output(self, line: str) -> float:
        """
        Extract progress percentage from output line
        
        Args:
            line: Output line to analyze
            
        Returns:
            float: Progress percentage (0-100), or -1 if no progress found
        """
        # Look for progress indicators in the output
        progress_indicators = [
            ("Step 1.1:", 5.0),
            ("Step 1.2:", 10.0),
            ("Step 1.3:", 20.0),
            ("Step 1.4:", 30.0),
            ("Step 1.5:", 40.0),
            ("Step 1.6:", 50.0),
            ("Step 1.7:", 60.0),
            ("Step 1.8:", 70.0),
            ("Step 1.9:", 85.0),
            ("Step 1.10:", 95.0),
            ("✅ STEP", 100.0),
            ("❌ STEP", 0.0)
        ]
        
        # Similar patterns for other steps
        for i in range(2, 6):
            for j in range(1, 11):
                progress_indicators.append((f"Step {i}.{j}:", j * 10.0))
            progress_indicators.append((f"✅ STEP {i}", 100.0))
            progress_indicators.append((f"❌ STEP {i}", 0.0))
        
        for indicator, progress in progress_indicators:
            if indicator in line:
                return progress
                
        return -1.0
    
    def pause_installation(self) -> bool:
        """
        Pause current installation (if possible)
        
        Returns:
            bool: True if paused successfully
        """
        # Note: Pausing shell scripts is complex, 
        # this is a placeholder for future implementation
        return False
    
    def cancel_installation(self) -> bool:
        """
        Cancel current installation
        
        Returns:
            bool: True if cancelled successfully
        """
        if not self.is_running:
            return False
            
        # This would need more sophisticated process management
        # For now, just mark as not running
        self.is_running = False
        self._notify_status("installation_cancelled", {})
        return True
    
    def retry_failed_step(self, step_number: int) -> bool:
        """
        Retry a specific failed step
        
        Args:
            step_number: Step number to retry (1-5)
            
        Returns:
            bool: True if retry started successfully
        """
        if self.is_running:
            return False
            
        if step_number < 1 or step_number > len(self.installation_steps):
            return False
            
        step = self.installation_steps[step_number - 1]
        if step.status != "failed":
            return False
            
        # Reset step status
        step.status = "pending"
        step.progress = 0.0
        step.output = []
        step.errors = []
        step.start_time = None
        step.completion_time = None
        
        return self.start_installation(step_number)
    
    # Utility Methods
    def get_step_details(self, step_number: int) -> Optional[Dict[str, Any]]:
        """
        Get detailed information about a specific step
        
        Args:
            step_number: Step number (1-5)
            
        Returns:
            Dict with step details, or None if step not found
        """
        if step_number < 1 or step_number > len(self.installation_steps):
            return None
            
        step = self.installation_steps[step_number - 1]
        return asdict(step)
    
    def get_installation_logs(self, step_number: int = None) -> List[str]:
        """
        Get installation logs
        
        Args:
            step_number: Specific step to get logs for, or None for all
            
        Returns:
            List of log lines
        """
        if step_number is None:
            # Return all logs
            all_logs = []
            for step in self.installation_steps:
                all_logs.extend(step.output)
            return all_logs
        else:
            if step_number < 1 or step_number > len(self.installation_steps):
                return []
            return self.installation_steps[step_number - 1].output.copy()
    
    def export_installation_report(self, file_path: str) -> bool:
        """
        Export detailed installation report
        
        Args:
            file_path: Path to save report to
            
        Returns:
            bool: True if report saved successfully
        """
        try:
            report = {
                "sefirot_installation_report": {
                    "generated_at": datetime.now().isoformat(),
                    "installation_complete": self.installation_complete,
                    "overall_progress": self._calculate_overall_progress(),
                    "steps": [asdict(step) for step in self.installation_steps],
                    "system_info": asdict(self.check_system_requirements())
                }
            }
            
            with open(file_path, 'w') as f:
                yaml.dump(report, f, indent=2, default_str=str)
                
            return True
            
        except Exception as e:
            self.logger.error(f"Failed to export report: {e}")
            return False

# Example GUI Integration Code
class ExampleGUIIntegration:
    """
    Example showing how to integrate Sefirot GUI API with different GUI frameworks
    """
    
    def __init__(self):
        self.api = SefirotGUIAPI()
        
        # Setup callbacks
        self.api.add_progress_callback(self.on_progress_update)
        self.api.add_status_callback(self.on_status_update)
        self.api.add_error_callback(self.on_error)
    
    def on_progress_update(self, step_number: int, progress: float, message: str):
        """Handle progress updates"""
        print(f"Step {step_number}: {progress:.1f}% - {message}")
        
        # In a real GUI, you would update progress bars, labels, etc.
        # Example for different frameworks:
        
        # Tkinter:
        # self.progress_bar['value'] = progress
        # self.status_label.config(text=message)
        
        # PyQt/PySide:
        # self.progress_bar.setValue(int(progress))
        # self.status_label.setText(message)
        
        # Electron (via JSON-RPC or WebSocket):
        # self.send_to_renderer({'type': 'progress', 'step': step_number, 'progress': progress, 'message': message})
    
    def on_status_update(self, status: str, data: Dict):
        """Handle status updates"""
        print(f"Status: {status}, Data: {data}")
        
        # Handle different status types
        if status == "installation_started":
            print("Installation started!")
        elif status == "installation_completed":
            print("Installation completed successfully!")
        elif status == "installation_failed":
            print(f"Installation failed at step {data.get('failed_step')}")
    
    def on_error(self, step_name: str, error: Exception):
        """Handle errors"""
        print(f"Error in {step_name}: {error}")
        
        # In a real GUI, show error dialog or update error display
    
    def start_installation_example(self):
        """Example of starting installation"""
        # Check requirements first
        requirements = self.api.check_system_requirements()
        
        if not requirements.requirements_met:
            print("System requirements not met:")
            for issue in requirements.issues:
                print(f"  - {issue}")
            return False
        
        # Start installation
        success = self.api.start_installation()
        if success:
            print("Installation started successfully")
        else:
            print("Failed to start installation")
        
        return success

# CLI for testing
def main():
    """CLI interface for testing GUI API"""
    import argparse
    
    parser = argparse.ArgumentParser(description='Sefirot GUI API Test Interface')
    parser.add_argument('command', choices=['check', 'status', 'install', 'retry', 'report'])
    parser.add_argument('--step', type=int, help='Step number for specific operations')
    parser.add_argument('--output', type=str, help='Output file path for reports')
    
    args = parser.parse_args()
    
    api = SefirotGUIAPI()
    
    if args.command == 'check':
        requirements = api.check_system_requirements()
        print(json.dumps(asdict(requirements), indent=2, default=str))
        
    elif args.command == 'status':
        status = api.get_installation_status()
        print(json.dumps(status, indent=2, default=str))
        
    elif args.command == 'install':
        # Simple example integration
        example = ExampleGUIIntegration()
        example.start_installation_example()
        
        # Wait for completion (in real GUI this would be event-driven)
        while example.api.is_running:
            time.sleep(1)
            
    elif args.command == 'retry':
        if args.step:
            success = api.retry_failed_step(args.step)
            print(f"Retry step {args.step}: {'success' if success else 'failed'}")
        else:
            print("--step required for retry command")
            
    elif args.command == 'report':
        output_path = args.output or 'sefirot_installation_report.yaml'
        success = api.export_installation_report(output_path)
        print(f"Report export: {'success' if success else 'failed'}")
        if success:
            print(f"Report saved to: {output_path}")

if __name__ == "__main__":
    main()