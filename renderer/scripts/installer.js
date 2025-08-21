// Sefirot Installation Management - Enhanced Installation Logic

class SefirotInstaller {
    constructor() {
        this.steps = [
            {
                number: 1,
                name: 'Environment Setup',
                description: 'Installing system prerequisites and development environment',
                estimatedTime: 10, // minutes
                subSteps: [
                    'Detecting System Capabilities',
                    'Checking Minimum Requirements', 
                    'Installing Package Managers',
                    'Installing System Dependencies',
                    'Installing Nix Package Manager',
                    'Installing Conda/Mamba',
                    'Configuring Shell Environment',
                    'Creating Directory Structure',
                    'Environment Validation'
                ]
            },
            {
                number: 2,
                name: 'Python Environment & Dependencies',
                description: 'Setting up Python 3.11 environment with AI/ML dependencies',
                estimatedTime: 15,
                subSteps: [
                    'Creating Sefirot Conda Environment',
                    'Installing Core Python Dependencies',
                    'Installing ChromaDB and Vector Database Dependencies',
                    'Installing NLP and Language Processing Dependencies',
                    'Installing Development and Jupyter Dependencies',
                    'Installing Obsidian Integration Dependencies',
                    'Installing API Client Dependencies',
                    'Hardware-Specific Optimizations',
                    'Creating Python Environment Configuration',
                    'Environment Validation'
                ]
            },
            {
                number: 3,
                name: 'ChromaDB Intelligence Platform',
                description: 'Initializing ChromaDB intelligence engine and privacy framework',
                estimatedTime: 5,
                subSteps: [
                    'Initializing ChromaDB Intelligence Engine',
                    'Setting Up Privacy Framework',
                    'Creating Sample Document Collection',
                    'Testing Semantic Search',
                    'Creating Intelligence Engine CLI',
                    'Hardware Performance Optimization',
                    'Creating Intelligence Engine Configuration',
                    'Platform Integration Testing',
                    'Creating Usage Examples',
                    'Final Platform Validation'
                ]
            },
            {
                number: 4,
                name: 'Obsidian Vault Integration', 
                description: 'Installing Obsidian with custom plugins and vault integration',
                estimatedTime: 8,
                subSteps: [
                    'Installing Obsidian Application',
                    'Creating Sefirot Vault Structure',
                    'Installing Essential Obsidian Plugins',
                    'Creating Sefirot-Specific Templates',
                    'Setting Up Obsidian Configuration',
                    'Creating Sefirot-ChromaDB Integration',
                    'Creating Sample Vault Content',
                    'Setting Up Automated Vault Sync',
                    'Plugin Configuration and Setup',
                    'Final Integration Validation'
                ]
            },
            {
                number: 5,
                name: 'Final Configuration & Testing',
                description: 'Final system configuration, testing, and validation',
                estimatedTime: 5,
                subSteps: [
                    'System-Wide Configuration',
                    'Creating CLI Commands',
                    'Comprehensive System Testing',
                    'Creating Installation Summary',
                    'Post-Installation Scripts',
                    'Final System Validation'
                ]
            }
        ];

        this.currentStep = 0;
        this.currentSubStep = 0;
        this.startTime = null;
        this.stepStartTimes = {};
        this.completedSteps = new Set();
        
        this.init();
    }

    init() {
        console.log('🔧 Sefirot Installer initialized');
        this.setupProgressTracking();
    }

    setupProgressTracking() {
        // Initialize step progress rings
        this.steps.forEach(step => {
            const stepItem = document.querySelector(`.step-item[data-step="${step.number}"]`);
            if (stepItem) {
                const progressRing = stepItem.querySelector('.step-progress-ring path:last-child');
                if (progressRing) {
                    // Initialize with 0% progress
                    this.updateStepProgressRing(step.number, 0);
                }
            }
        });
    }

    startInstallation() {
        console.log('🚀 Starting Sefirot installation sequence');
        
        this.startTime = Date.now();
        this.currentStep = 1;
        this.currentSubStep = 0;
        
        // Reset all visual indicators
        this.resetAllSteps();
        
        // Start first step
        this.beginStep(1);
    }

    resetAllSteps() {
        this.steps.forEach(step => {
            const stepItem = document.querySelector(`.step-item[data-step="${step.number}"]`);
            if (stepItem) {
                stepItem.classList.remove('active', 'completed', 'error');
                
                const statusElement = stepItem.querySelector('.step-status');
                if (statusElement) {
                    statusElement.textContent = 'Waiting...';
                }
                
                this.updateStepProgressRing(step.number, 0);
            }
        });
        
        // Reset overall progress
        this.updateOverallProgress(0);
    }

    beginStep(stepNumber) {
        const step = this.steps.find(s => s.number === stepNumber);
        if (!step) return;

        console.log(`📋 Beginning Step ${stepNumber}: ${step.name}`);
        
        this.stepStartTimes[stepNumber] = Date.now();
        
        // Update visual state
        const stepItem = document.querySelector(`.step-item[data-step="${stepNumber}"]`);
        if (stepItem) {
            stepItem.classList.add('active');
            
            const statusElement = stepItem.querySelector('.step-status');
            if (statusElement) {
                statusElement.textContent = 'Starting...';
            }
        }
        
        // Update ETA based on current step
        this.updateETADisplay();
    }

    updateStepProgress(stepNumber, progress, message = '') {
        console.log(`📊 Step ${stepNumber} progress: ${progress}%`);
        
        const stepItem = document.querySelector(`.step-item[data-step="${stepNumber}"]`);
        if (!stepItem) return;
        
        // Update progress ring
        this.updateStepProgressRing(stepNumber, progress);
        
        // Update status message
        const statusElement = stepItem.querySelector('.step-status');
        if (statusElement && message) {
            statusElement.textContent = this.truncateMessage(message, 50);
        }
        
        // Update overall progress
        this.updateOverallProgressFromSteps();
        
        // Update ETA
        this.updateETADisplay();
    }

    updateStepProgressRing(stepNumber, progress) {
        const stepItem = document.querySelector(`.step-item[data-step="${stepNumber}"]`);
        if (!stepItem) return;
        
        const progressRing = stepItem.querySelector('.step-progress-ring path:last-child');
        if (progressRing) {
            const circumference = 100; // 2 * π * r where r = ~15.9
            const offset = circumference - (progress / 100) * circumference;
            
            progressRing.style.strokeDasharray = `${circumference}`;
            progressRing.style.strokeDashoffset = `${offset}`;
            progressRing.style.transition = 'stroke-dashoffset 0.3s ease';
        }
    }

    completeStep(stepNumber, success = true) {
        const step = this.steps.find(s => s.number === stepNumber);
        if (!step) return;

        console.log(`${success ? '✅' : '❌'} Step ${stepNumber} ${success ? 'completed' : 'failed'}: ${step.name}`);
        
        const stepItem = document.querySelector(`.step-item[data-step="${stepNumber}"]`);
        if (!stepItem) return;
        
        // Remove active state
        stepItem.classList.remove('active');
        
        if (success) {
            stepItem.classList.add('completed');
            this.completedSteps.add(stepNumber);
            
            // Complete progress ring
            this.updateStepProgressRing(stepNumber, 100);
            
            // Update status
            const statusElement = stepItem.querySelector('.step-status');
            if (statusElement) {
                const elapsedTime = this.getStepElapsedTime(stepNumber);
                statusElement.textContent = `Completed in ${elapsedTime}`;
            }
            
            // Show completion icon
            const stepCircle = stepItem.querySelector('.step-circle .step-num');
            if (stepCircle) {
                setTimeout(() => {
                    stepCircle.innerHTML = '<i class="fas fa-check"></i>';
                }, 300);
            }
            
        } else {
            stepItem.classList.add('error');
            
            const statusElement = stepItem.querySelector('.step-status');
            if (statusElement) {
                statusElement.textContent = 'Failed - Check logs';
            }
            
            // Show error icon
            const stepCircle = stepItem.querySelector('.step-circle .step-num');
            if (stepCircle) {
                setTimeout(() => {
                    stepCircle.innerHTML = '<i class="fas fa-times"></i>';
                }, 300);
            }
        }
        
        // Update overall progress
        this.updateOverallProgressFromSteps();
        
        // Start next step if successful
        if (success && stepNumber < this.steps.length) {
            setTimeout(() => {
                this.beginStep(stepNumber + 1);
            }, 1000);
        } else if (success && stepNumber === this.steps.length) {
            // All steps completed
            this.completeInstallation();
        }
    }

    completeInstallation() {
        console.log('🎉 Installation sequence completed successfully!');
        
        const totalTime = this.getTotalElapsedTime();
        
        // Update overall progress to 100%
        this.updateOverallProgress(100);
        
        // Update ETA to show completion
        const etaText = document.getElementById('eta-text');
        if (etaText) {
            etaText.textContent = `Completed in ${totalTime}`;
        }
        
        // Add celebration animation
        this.showCompletionAnimation();
    }

    updateOverallProgress(progress = null) {
        let totalProgress = progress;
        
        if (totalProgress === null) {
            totalProgress = this.calculateOverallProgress();
        }
        
        const progressFill = document.getElementById('overall-progress-fill');
        const progressText = document.getElementById('overall-progress-text');
        
        if (progressFill) {
            progressFill.style.width = `${totalProgress}%`;
        }
        
        if (progressText) {
            progressText.textContent = `${Math.round(totalProgress)}% Complete`;
        }
    }

    updateOverallProgressFromSteps() {
        const totalProgress = this.calculateOverallProgress();
        this.updateOverallProgress(totalProgress);
    }

    calculateOverallProgress() {
        let totalProgress = 0;
        const totalSteps = this.steps.length;
        
        // Calculate based on completed steps
        const completedCount = this.completedSteps.size;
        totalProgress = (completedCount / totalSteps) * 100;
        
        // Add partial progress for current active step
        const activeStep = document.querySelector('.step-item.active');
        if (activeStep) {
            const activeStepNumber = parseInt(activeStep.getAttribute('data-step'));
            const activeStepProgress = this.estimateActiveStepProgress(activeStepNumber);
            totalProgress += (activeStepProgress / totalSteps);
        }
        
        return Math.min(100, totalProgress);
    }

    estimateActiveStepProgress(stepNumber) {
        // Get current progress ring value
        const stepItem = document.querySelector(`.step-item[data-step="${stepNumber}"]`);
        if (!stepItem) return 0;
        
        const progressRing = stepItem.querySelector('.step-progress-ring path:last-child');
        if (!progressRing) return 0;
        
        const dashOffset = parseFloat(progressRing.style.strokeDashoffset) || 100;
        const circumference = 100;
        const progress = ((circumference - dashOffset) / circumference) * 100;
        
        return Math.max(0, Math.min(20, progress / 5)); // Cap at 20% per step
    }

    updateETADisplay() {
        const etaText = document.getElementById('eta-text');
        if (!etaText) return;
        
        if (this.completedSteps.size === 0 && !this.startTime) {
            etaText.textContent = 'Estimating time...';
            return;
        }
        
        if (this.completedSteps.size === this.steps.length) {
            const totalTime = this.getTotalElapsedTime();
            etaText.textContent = `Completed in ${totalTime}`;
            return;
        }
        
        // Calculate ETA based on completed steps and estimated remaining time
        const avgTimePerStep = this.getAverageStepTime();
        const remainingSteps = this.steps.length - this.completedSteps.size;
        
        // Account for current step progress
        let currentStepRemaining = 0;
        const currentStepNumber = Math.max(1, this.completedSteps.size + 1);
        const currentStep = this.steps.find(s => s.number === currentStepNumber);
        
        if (currentStep) {
            const currentStepElapsed = this.getStepElapsedTime(currentStepNumber, false);
            const currentStepEstimate = currentStep.estimatedTime * 60 * 1000; // Convert to ms
            currentStepRemaining = Math.max(0, currentStepEstimate - currentStepElapsed);
        }
        
        // Calculate total remaining time
        const remainingTime = (remainingSteps - 1) * avgTimePerStep + currentStepRemaining;
        const remainingMinutes = Math.ceil(remainingTime / (60 * 1000));
        
        if (remainingMinutes > 0) {
            etaText.textContent = `~${remainingMinutes} ${remainingMinutes === 1 ? 'minute' : 'minutes'} remaining`;
        } else {
            etaText.textContent = 'Almost done...';
        }
    }

    getAverageStepTime() {
        if (this.completedSteps.size === 0) {
            // Use estimated times
            const totalEstimated = this.steps.reduce((sum, step) => sum + step.estimatedTime, 0);
            return (totalEstimated / this.steps.length) * 60 * 1000; // Convert to ms
        }
        
        // Calculate actual average from completed steps
        let totalTime = 0;
        let completedCount = 0;
        
        this.completedSteps.forEach(stepNumber => {
            const stepTime = this.getStepElapsedTime(stepNumber, false);
            if (stepTime > 0) {
                totalTime += stepTime;
                completedCount++;
            }
        });
        
        if (completedCount > 0) {
            return totalTime / completedCount;
        }
        
        // Fallback to estimated average
        const totalEstimated = this.steps.reduce((sum, step) => sum + step.estimatedTime, 0);
        return (totalEstimated / this.steps.length) * 60 * 1000;
    }

    getStepElapsedTime(stepNumber, formatted = true) {
        const startTime = this.stepStartTimes[stepNumber];
        if (!startTime) return formatted ? '0m' : 0;
        
        const elapsed = Date.now() - startTime;
        
        if (formatted) {
            const minutes = Math.floor(elapsed / (60 * 1000));
            const seconds = Math.floor((elapsed % (60 * 1000)) / 1000);
            
            if (minutes > 0) {
                return `${minutes}m ${seconds}s`;
            } else {
                return `${seconds}s`;
            }
        }
        
        return elapsed;
    }

    getTotalElapsedTime() {
        if (!this.startTime) return '0m';
        
        const elapsed = Date.now() - this.startTime;
        const minutes = Math.floor(elapsed / (60 * 1000));
        const seconds = Math.floor((elapsed % (60 * 1000)) / 1000);
        
        if (minutes > 0) {
            return `${minutes}m ${seconds}s`;
        } else {
            return `${seconds}s`;
        }
    }

    truncateMessage(message, maxLength = 50) {
        if (message.length <= maxLength) return message;
        return message.substring(0, maxLength - 3) + '...';
    }

    showCompletionAnimation() {
        // Add sparkle effects to completed steps
        const completedSteps = document.querySelectorAll('.step-item.completed');
        
        completedSteps.forEach((step, index) => {
            setTimeout(() => {
                this.addSparkleEffect(step);
            }, index * 200);
        });
        
        // Pulse the overall progress bar
        const progressBar = document.querySelector('.progress-bar');
        if (progressBar) {
            progressBar.style.animation = 'pulse 1s ease-in-out 3';
        }
    }

    addSparkleEffect(element) {
        const sparkle = document.createElement('div');
        sparkle.innerHTML = '✨';
        sparkle.style.cssText = `
            position: absolute;
            top: -10px;
            right: -10px;
            font-size: 20px;
            animation: sparkle 2s ease-out forwards;
            pointer-events: none;
            z-index: 10;
        `;
        
        element.style.position = 'relative';
        element.appendChild(sparkle);
        
        setTimeout(() => {
            sparkle.remove();
        }, 2000);
    }

    // Error Handling
    handleStepError(stepNumber, error) {
        console.error(`❌ Step ${stepNumber} error:`, error);
        
        this.completeStep(stepNumber, false);
        
        // Show error notification
        if (window.sefirotApp) {
            window.sefirotApp.showNotification('error', 'Installation Error', 
                `Step ${stepNumber} failed: ${error}`);
        }
    }

    // Recovery Options
    retryStep(stepNumber) {
        console.log(`🔄 Retrying Step ${stepNumber}`);
        
        // Reset step state
        const stepItem = document.querySelector(`.step-item[data-step="${stepNumber}"]`);
        if (stepItem) {
            stepItem.classList.remove('completed', 'error');
            
            const stepCircle = stepItem.querySelector('.step-circle .step-num');
            if (stepCircle) {
                stepCircle.textContent = stepNumber;
            }
        }
        
        // Remove from completed steps
        this.completedSteps.delete(stepNumber);
        
        // Restart the step
        this.beginStep(stepNumber);
    }

    skipStep(stepNumber) {
        console.log(`⏭️ Skipping Step ${stepNumber}`);
        
        // Mark as completed but with warning
        const stepItem = document.querySelector(`.step-item[data-step="${stepNumber}"]`);
        if (stepItem) {
            stepItem.classList.remove('active', 'error');
            stepItem.classList.add('completed');
            
            const statusElement = stepItem.querySelector('.step-status');
            if (statusElement) {
                statusElement.textContent = 'Skipped';
            }
            
            const stepCircle = stepItem.querySelector('.step-circle .step-num');
            if (stepCircle) {
                stepCircle.innerHTML = '<i class="fas fa-forward"></i>';
            }
        }
        
        this.completedSteps.add(stepNumber);
        
        // Continue to next step
        if (stepNumber < this.steps.length) {
            setTimeout(() => {
                this.beginStep(stepNumber + 1);
            }, 1000);
        } else {
            this.completeInstallation();
        }
    }

    // Installation State Management
    getInstallationState() {
        return {
            currentStep: this.currentStep,
            completedSteps: Array.from(this.completedSteps),
            totalSteps: this.steps.length,
            startTime: this.startTime,
            stepStartTimes: { ...this.stepStartTimes },
            overallProgress: this.calculateOverallProgress(),
            isRunning: this.completedSteps.size < this.steps.length,
            estimatedTimeRemaining: this.updateETADisplay()
        };
    }

    saveInstallationState() {
        const state = this.getInstallationState();
        localStorage.setItem('sefirot_installation_state', JSON.stringify(state));
    }

    loadInstallationState() {
        try {
            const saved = localStorage.getItem('sefirot_installation_state');
            if (saved) {
                const state = JSON.parse(saved);
                
                this.currentStep = state.currentStep || 0;
                this.completedSteps = new Set(state.completedSteps || []);
                this.startTime = state.startTime || null;
                this.stepStartTimes = state.stepStartTimes || {};
                
                // Restore visual state
                this.restoreVisualState();
                
                console.log('📂 Installation state restored');
                return true;
            }
        } catch (error) {
            console.error('Failed to load installation state:', error);
        }
        
        return false;
    }

    restoreVisualState() {
        // Restore completed steps
        this.completedSteps.forEach(stepNumber => {
            const stepItem = document.querySelector(`.step-item[data-step="${stepNumber}"]`);
            if (stepItem) {
                stepItem.classList.add('completed');
                this.updateStepProgressRing(stepNumber, 100);
                
                const stepCircle = stepItem.querySelector('.step-circle .step-num');
                if (stepCircle) {
                    stepCircle.innerHTML = '<i class="fas fa-check"></i>';
                }
                
                const statusElement = stepItem.querySelector('.step-status');
                if (statusElement) {
                    statusElement.textContent = 'Completed';
                }
            }
        });
        
        // Update overall progress
        this.updateOverallProgressFromSteps();
    }

    clearInstallationState() {
        localStorage.removeItem('sefirot_installation_state');
    }
}

// Add sparkle animation styles
const sparkleStyles = `
@keyframes sparkle {
    0% { transform: scale(0) rotate(0deg); opacity: 1; }
    50% { transform: scale(1) rotate(180deg); opacity: 0.8; }
    100% { transform: scale(0) rotate(360deg); opacity: 0; }
}

@keyframes pulse {
    0% { box-shadow: 0 0 5px rgba(79, 70, 229, 0.3); }
    50% { box-shadow: 0 0 20px rgba(79, 70, 229, 0.8); }
    100% { box-shadow: 0 0 5px rgba(79, 70, 229, 0.3); }
}
`;

// Inject styles
const styleSheet = document.createElement('style');
styleSheet.textContent = sparkleStyles;
document.head.appendChild(styleSheet);

// Export for use in other modules
if (typeof module !== 'undefined' && module.exports) {
    module.exports = SefirotInstaller;
} else {
    window.SefirotInstaller = SefirotInstaller;
}