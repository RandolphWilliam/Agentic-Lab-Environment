// Sefirot Intelligence Platform - Main Application Script

class SefirotApp {
    constructor() {
        this.currentPhase = 'welcome';
        this.installationState = {
            currentStep: 0,
            totalSteps: 5,
            isRunning: false,
            logs: []
        };
        this.tourState = {
            currentSection: 0,
            totalSections: 5,
            sections: ['introduction', 'privacy', 'features', 'workflow', 'tools']
        };
        
        this.init();
    }

    async init() {
        console.log('🚀 Sefirot Intelligence Platform starting...');
        
        try {
            // Get app info
            const appInfo = await electronAPI.getAppInfo();
            console.log('App Info:', appInfo);
            
            // Setup event listeners
            this.setupEventListeners();
            this.setupInstallationListeners();
            
            // Initialize first phase
            this.showPhase('welcome');
            
            console.log('✅ Sefirot app initialized successfully');
            
        } catch (error) {
            console.error('❌ Failed to initialize Sefirot app:', error);
            this.showNotification('error', 'Initialization Error', 'Failed to start the application. Please restart.');
        }
    }

    setupEventListeners() {
        // Welcome phase
        const startSetupBtn = document.getElementById('start-setup-btn');
        const learnMoreBtn = document.getElementById('learn-more-btn');
        
        if (startSetupBtn) {
            startSetupBtn.addEventListener('click', () => {
                this.showPhase('requirements');
                this.checkSystemRequirements();
            });
        }
        
        if (learnMoreBtn) {
            learnMoreBtn.addEventListener('click', () => {
                electronAPI.openExternal('https://sefirot.dev/docs');
            });
        }

        // Requirements phase
        const continueToCredentialsBtn = document.getElementById('continue-to-credentials-btn');
        const retryRequirementsBtn = document.getElementById('retry-requirements-btn');
        
        if (continueToCredentialsBtn) {
            continueToCredentialsBtn.addEventListener('click', () => {
                this.showPhase('credentials');
                this.loadExistingCredentials();
            });
        }
        
        if (retryRequirementsBtn) {
            retryRequirementsBtn.addEventListener('click', () => {
                this.checkSystemRequirements();
            });
        }

        // Credentials phase
        const saveCredentialsBtn = document.getElementById('save-credentials-btn');
        const backToRequirementsBtn = document.getElementById('back-to-requirements-btn');
        
        if (saveCredentialsBtn) {
            saveCredentialsBtn.addEventListener('click', () => {
                this.saveCredentials();
            });
        }
        
        if (backToRequirementsBtn) {
            backToRequirementsBtn.addEventListener('click', () => {
                this.showPhase('requirements');
            });
        }

        // Completion phase
        const startTourBtn = document.getElementById('start-tour-btn');
        const openVaultBtn = document.getElementById('open-vault-btn');
        const openCliBtn = document.getElementById('open-cli-btn');
        
        if (startTourBtn) {
            startTourBtn.addEventListener('click', () => {
                this.showPhase('tour');
                this.startTour();
            });
        }
        
        if (openVaultBtn) {
            openVaultBtn.addEventListener('click', async () => {
                const result = await electronAPI.launchObsidianVault();
                if (!result.success) {
                    this.showNotification('error', 'Vault Not Found', result.error);
                }
            });
        }
        
        if (openCliBtn) {
            openCliBtn.addEventListener('click', async () => {
                const result = await electronAPI.launchSefirotCLI();
                if (!result.success) {
                    this.showNotification('error', 'CLI Not Found', result.error);
                }
            });
        }

        // Tour navigation
        const tourPrevBtn = document.getElementById('tour-prev-btn');
        const tourNextBtn = document.getElementById('tour-next-btn');
        const finishTourBtn = document.getElementById('finish-tour-btn');
        const replayTourBtn = document.getElementById('replay-tour-btn');
        
        if (tourPrevBtn) {
            tourPrevBtn.addEventListener('click', () => this.previousTourSection());
        }
        
        if (tourNextBtn) {
            tourNextBtn.addEventListener('click', () => this.nextTourSection());
        }
        
        if (finishTourBtn) {
            finishTourBtn.addEventListener('click', () => this.finishTour());
        }
        
        if (replayTourBtn) {
            replayTourBtn.addEventListener('click', () => this.replayTour());
        }

        // Installation logs toggle
        const toggleLogsBtn = document.getElementById('toggle-logs-btn');
        if (toggleLogsBtn) {
            toggleLogsBtn.addEventListener('click', () => this.toggleInstallationLogs());
        }

        // Expandable form sections
        this.setupExpandableSections();

        // Form validation
        this.setupFormValidation();
    }

    setupInstallationListeners() {
        // Installation progress listeners
        electronAPI.onInstallationStepStart((event, data) => {
            console.log('Installation step started:', data);
            this.updateInstallationStep(data.step, 'running', 'Starting...');
        });

        electronAPI.onInstallationStepComplete((event, data) => {
            console.log('Installation step completed:', data);
            this.updateInstallationStep(data.step, 'completed', 'Completed');
            this.updateOverallProgress();
        });

        electronAPI.onInstallationStepError((event, data) => {
            console.error('Installation step error:', data);
            this.updateInstallationStep(data.step, 'error', `Error: ${data.error}`);
            this.showNotification('error', 'Installation Error', `Step ${data.step}: ${data.error}`);
        });

        electronAPI.onInstallationProgress((event, data) => {
            console.log('Installation progress:', data);
            this.updateStepProgress(data.step, data.progress);
            this.updateInstallationStep(data.step, 'running', data.message);
        });

        electronAPI.onInstallationLog((event, data) => {
            console.log('Installation log:', data);
            this.addInstallationLog(data);
        });

        electronAPI.onInstallationComplete((event, data) => {
            console.log('Installation completed:', data);
            this.installationState.isRunning = false;
            
            if (data.success) {
                this.showPhase('completion');
                this.showNotification('success', 'Installation Complete', 'Your Sefirot Intelligence Platform is ready!');
            } else {
                this.showNotification('error', 'Installation Failed', 'Some components failed to install. Check the logs for details.');
            }
        });
    }

    showPhase(phaseName) {
        console.log(`Switching to phase: ${phaseName}`);
        
        // Hide all phases
        const phases = document.querySelectorAll('.phase');
        phases.forEach(phase => phase.classList.remove('active'));
        
        // Show target phase
        const targetPhase = document.getElementById(`${phaseName}-phase`);
        if (targetPhase) {
            targetPhase.classList.add('active');
            this.currentPhase = phaseName;
        } else {
            console.error(`Phase not found: ${phaseName}`);
        }
    }

    async checkSystemRequirements() {
        console.log('Checking system requirements...');
        
        // Show loading state
        const loadingState = document.getElementById('requirements-loading');
        const resultsState = document.getElementById('requirements-results');
        const continueBtn = document.getElementById('continue-to-credentials-btn');
        const retryBtn = document.getElementById('retry-requirements-btn');
        
        if (loadingState) loadingState.style.display = 'block';
        if (resultsState) resultsState.style.display = 'none';
        if (continueBtn) continueBtn.disabled = true;
        if (retryBtn) retryBtn.style.display = 'none';

        try {
            const requirements = await electronAPI.checkSystemRequirements();
            console.log('System requirements:', requirements);
            
            this.displaySystemRequirements(requirements);
            
        } catch (error) {
            console.error('System requirements check failed:', error);
            this.showNotification('error', 'Requirements Check Failed', 'Could not check system requirements. Please try again.');
            
            if (retryBtn) retryBtn.style.display = 'inline-flex';
        } finally {
            if (loadingState) loadingState.style.display = 'none';
        }
    }

    displaySystemRequirements(requirements) {
        // Update system info
        const elements = {
            'macos-version': requirements.macos_version || 'Unknown',
            'architecture': requirements.architecture || 'Unknown',
            'memory': requirements.memory_gb ? `${requirements.memory_gb.toFixed(1)}GB` : 'Unknown',
            'disk-space': requirements.available_disk_gb ? `${requirements.available_disk_gb}GB` : 'Unknown'
        };

        Object.entries(elements).forEach(([id, value]) => {
            const element = document.getElementById(id);
            if (element) element.textContent = value;
        });

        // Update requirements list
        const requirementsList = document.getElementById('requirements-list');
        if (requirementsList) {
            requirementsList.innerHTML = '';
            
            const checks = [
                {
                    name: 'macOS Version',
                    met: requirements.macos_version && !requirements.issues?.some(issue => issue.includes('macOS version')),
                    description: 'macOS 12.0 (Monterey) or later required'
                },
                {
                    name: 'Available Storage',
                    met: requirements.available_disk_gb >= 10,
                    description: '10GB+ free space required'
                },
                {
                    name: 'Memory',
                    met: requirements.memory_gb >= 4,
                    description: '4GB+ RAM (8GB+ recommended)'
                },
                {
                    name: 'Architecture',
                    met: ['x86_64', 'arm64'].includes(requirements.architecture),
                    description: 'Intel or Apple Silicon Mac'
                }
            ];

            checks.forEach(check => {
                const item = document.createElement('div');
                item.className = `requirement-item ${check.met ? 'met' : 'not-met'}`;
                
                item.innerHTML = `
                    <div class="requirement-icon ${check.met ? 'met' : 'not-met'}">
                        <i class="fas ${check.met ? 'fa-check-circle' : 'fa-times-circle'}"></i>
                    </div>
                    <div class="requirement-info">
                        <strong>${check.name}</strong>
                        <p>${check.description}</p>
                    </div>
                `;
                
                requirementsList.appendChild(item);
            });
        }

        // Show results and update continue button
        const resultsState = document.getElementById('requirements-results');
        const continueBtn = document.getElementById('continue-to-credentials-btn');
        
        if (resultsState) resultsState.style.display = 'block';
        if (continueBtn) {
            continueBtn.disabled = !requirements.requirements_met;
            if (requirements.requirements_met) {
                continueBtn.innerHTML = '<i class="fas fa-arrow-right"></i> Continue to Credentials';
            } else {
                continueBtn.innerHTML = '<i class="fas fa-exclamation-triangle"></i> Requirements Not Met';
            }
        }
    }

    async loadExistingCredentials() {
        try {
            const result = await electronAPI.loadCredentials();
            if (result.success && result.credentials) {
                const credentials = result.credentials;
                
                // Populate form fields
                const fields = [
                    'anthropic-key', 'openai-key', 'shopify-store', 'shopify-token',
                    'runpod-key', 'paperspace-key', 'pinecone-key'
                ];
                
                fields.forEach(fieldId => {
                    const element = document.getElementById(fieldId);
                    const key = fieldId.replace('-', '_');
                    if (element && credentials[key]) {
                        element.value = credentials[key];
                    }
                });
                
                console.log('Existing credentials loaded');
            }
        } catch (error) {
            console.error('Failed to load existing credentials:', error);
        }
    }

    async saveCredentials() {
        console.log('Saving credentials...');
        
        const saveBtn = document.getElementById('save-credentials-btn');
        if (saveBtn) {
            saveBtn.disabled = true;
            saveBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Saving...';
        }

        try {
            // Collect form data
            const credentials = {
                anthropic_api_key: document.getElementById('anthropic-key')?.value.trim() || '',
                openai_api_key: document.getElementById('openai-key')?.value.trim() || '',
                shopify_store_url: document.getElementById('shopify-store')?.value.trim() || '',
                shopify_access_token: document.getElementById('shopify-token')?.value.trim() || '',
                runpod_api_key: document.getElementById('runpod-key')?.value.trim() || '',
                paperspace_api_key: document.getElementById('paperspace-key')?.value.trim() || '',
                pinecone_api_key: document.getElementById('pinecone-key')?.value.trim() || ''
            };

            const result = await electronAPI.saveCredentials(credentials);
            
            if (result.success) {
                this.showNotification('success', 'Credentials Saved', 'Your API credentials have been saved securely.');
                
                // Start installation
                setTimeout(() => {
                    this.showPhase('installation');
                    this.startInstallation();
                }, 1500);
                
            } else {
                this.showNotification('error', 'Validation Error', result.error);
            }
            
        } catch (error) {
            console.error('Failed to save credentials:', error);
            this.showNotification('error', 'Save Error', 'Failed to save credentials. Please try again.');
        } finally {
            if (saveBtn) {
                saveBtn.disabled = false;
                saveBtn.innerHTML = '<i class="fas fa-save"></i> Save & Continue';
            }
        }
    }

    async startInstallation() {
        console.log('Starting installation...');
        
        this.installationState.isRunning = true;
        this.installationState.logs = [];
        
        // Reset all steps to pending
        for (let i = 1; i <= 5; i++) {
            this.updateInstallationStep(i, 'pending', 'Waiting...');
        }
        
        // Reset overall progress
        this.updateOverallProgress(0);
        
        try {
            const result = await electronAPI.startInstallation();
            
            if (!result.success) {
                this.showNotification('error', 'Installation Error', result.error);
                this.installationState.isRunning = false;
            }
            
        } catch (error) {
            console.error('Failed to start installation:', error);
            this.showNotification('error', 'Installation Error', 'Failed to start installation process.');
            this.installationState.isRunning = false;
        }
    }

    updateInstallationStep(stepNumber, status, message) {
        const stepItem = document.querySelector(`.step-item[data-step="${stepNumber}"]`);
        if (!stepItem) return;
        
        // Remove existing status classes
        stepItem.classList.remove('active', 'completed', 'error');
        
        // Add new status class
        if (status === 'running') {
            stepItem.classList.add('active');
        } else if (status === 'completed') {
            stepItem.classList.add('completed');
        } else if (status === 'error') {
            stepItem.classList.add('error');
        }
        
        // Update status text
        const statusElement = stepItem.querySelector('.step-status');
        if (statusElement) {
            statusElement.textContent = message;
        }
    }

    updateStepProgress(stepNumber, progress) {
        const stepItem = document.querySelector(`.step-item[data-step="${stepNumber}"]`);
        if (!stepItem) return;
        
        const progressRing = stepItem.querySelector('.step-progress-ring path:last-child');
        if (progressRing) {
            const circumference = 100;
            const offset = circumference - (progress / 100) * circumference;
            progressRing.style.strokeDasharray = `${circumference}`;
            progressRing.style.strokeDashoffset = `${offset}`;
        }
    }

    updateOverallProgress(overrideProgress = null) {
        let totalProgress = 0;
        
        if (overrideProgress !== null) {
            totalProgress = overrideProgress;
        } else {
            // Calculate based on completed steps
            const completedSteps = document.querySelectorAll('.step-item.completed').length;
            const activeStep = document.querySelector('.step-item.active');
            
            totalProgress = (completedSteps / 5) * 100;
            
            // Add partial progress for active step
            if (activeStep) {
                totalProgress += (1 / 5) * 20; // Assume 20% progress for active step
            }
        }
        
        // Update progress bar
        const progressFill = document.getElementById('overall-progress-fill');
        const progressText = document.getElementById('overall-progress-text');
        
        if (progressFill) {
            progressFill.style.width = `${totalProgress}%`;
        }
        
        if (progressText) {
            progressText.textContent = `${Math.round(totalProgress)}% Complete`;
        }
        
        // Update ETA (simplified calculation)
        const etaText = document.getElementById('eta-text');
        if (etaText && totalProgress > 0 && totalProgress < 100) {
            const estimatedMinutes = Math.round((100 - totalProgress) / 100 * 45);
            etaText.textContent = `~${estimatedMinutes} minutes remaining`;
        } else if (etaText) {
            etaText.textContent = totalProgress === 100 ? 'Complete!' : 'Estimating time...';
        }
    }

    addInstallationLog(logData) {
        const logsOutput = document.getElementById('logs-output');
        if (!logsOutput) return;
        
        const logEntry = document.createElement('div');
        logEntry.className = `log-entry ${logData.type || ''}`;
        
        const timestamp = new Date().toLocaleTimeString();
        logEntry.textContent = `[${timestamp}] Step ${logData.step}: ${logData.message}`;
        
        logsOutput.appendChild(logEntry);
        logsOutput.scrollTop = logsOutput.scrollHeight;
        
        // Keep only last 100 log entries
        const entries = logsOutput.children;
        if (entries.length > 100) {
            logsOutput.removeChild(entries[0]);
        }
    }

    toggleInstallationLogs() {
        const logsContent = document.getElementById('logs-container');
        const toggleBtn = document.getElementById('toggle-logs-btn');
        
        if (logsContent && toggleBtn) {
            const isCollapsed = logsContent.classList.contains('collapsed');
            
            if (isCollapsed) {
                logsContent.classList.remove('collapsed');
                toggleBtn.classList.remove('collapsed');
                toggleBtn.innerHTML = '<i class="fas fa-chevron-up"></i>';
            } else {
                logsContent.classList.add('collapsed');
                toggleBtn.classList.add('collapsed');
                toggleBtn.innerHTML = '<i class="fas fa-chevron-down"></i>';
            }
        }
    }

    setupExpandableSections() {
        const expandableHeaders = document.querySelectorAll('.expandable-header');
        expandableHeaders.forEach(header => {
            header.addEventListener('click', () => {
                const section = header.closest('.expandable');
                if (section) {
                    section.classList.toggle('expanded');
                }
            });
        });
    }

    setupFormValidation() {
        // Real-time validation for required fields
        const requiredFields = document.querySelectorAll('input[required]');
        requiredFields.forEach(field => {
            field.addEventListener('input', () => {
                this.validateForm();
            });
        });
    }

    validateForm() {
        const saveBtn = document.getElementById('save-credentials-btn');
        if (!saveBtn) return;
        
        const anthropicKey = document.getElementById('anthropic-key')?.value.trim() || '';
        const openaiKey = document.getElementById('openai-key')?.value.trim() || '';
        
        const isValid = anthropicKey && openaiKey && 
                       anthropicKey.startsWith('sk-ant-') && 
                       openaiKey.startsWith('sk-');
        
        saveBtn.disabled = !isValid;
    }

    // Tour Methods
    startTour() {
        this.tourState.currentSection = 0;
        this.showTourSection(0);
        this.updateButlerMessage("Hello! I'm your AI butler. I'll guide you through the capabilities of your new intelligence platform.");
    }

    showTourSection(sectionIndex) {
        // Hide all sections
        const sections = document.querySelectorAll('.tour-section');
        sections.forEach(section => section.classList.remove('active'));
        
        // Show target section
        const sectionName = this.tourState.sections[sectionIndex];
        const targetSection = document.querySelector(`[data-section="${sectionName}"]`);
        if (targetSection) {
            targetSection.classList.add('active');
        }
        
        // Update progress dots
        const dots = document.querySelectorAll('.progress-dots .dot');
        dots.forEach((dot, index) => {
            dot.classList.toggle('active', index === sectionIndex);
        });
        
        // Update navigation buttons
        const prevBtn = document.getElementById('tour-prev-btn');
        const nextBtn = document.getElementById('tour-next-btn');
        
        if (prevBtn) prevBtn.disabled = sectionIndex === 0;
        if (nextBtn) {
            if (sectionIndex === this.tourState.sections.length - 1) {
                nextBtn.textContent = 'Finish Tour';
                nextBtn.innerHTML = 'Finish Tour <i class="fas fa-flag-checkered"></i>';
            } else {
                nextBtn.innerHTML = 'Next <i class="fas fa-arrow-right"></i>';
            }
        }
        
        // Update butler message
        const messages = [
            "Let's start with understanding what makes your intelligence platform special.",
            "Privacy is at the heart of everything. You control what information AI can access.",
            "Here are the key features that make your work more intelligent and efficient.",
            "Let me show you how this fits into your daily knowledge work routine.",
            "These are the essential tools you'll use to harness your AI intelligence."
        ];
        
        this.updateButlerMessage(messages[sectionIndex] || "Welcome to your tour!");
    }

    nextTourSection() {
        if (this.tourState.currentSection < this.tourState.sections.length - 1) {
            this.tourState.currentSection++;
            this.showTourSection(this.tourState.currentSection);
        } else {
            this.finishTour();
        }
    }

    previousTourSection() {
        if (this.tourState.currentSection > 0) {
            this.tourState.currentSection--;
            this.showTourSection(this.tourState.currentSection);
        }
    }

    finishTour() {
        const tourCompletion = document.querySelector('.tour-completion');
        const tourSections = document.querySelector('.tour-sections');
        const tourNavigation = document.querySelector('.tour-navigation');
        
        if (tourCompletion) tourCompletion.style.display = 'block';
        if (tourSections) tourSections.style.display = 'none';
        if (tourNavigation) tourNavigation.style.display = 'none';
        
        this.updateButlerMessage("Congratulations! You're now ready to use your AI intelligence platform. Happy knowledge building!");
        
        this.showNotification('success', 'Tour Complete', 'You\'re now ready to use Sefirot!');
    }

    replayTour() {
        const tourCompletion = document.querySelector('.tour-completion');
        const tourSections = document.querySelector('.tour-sections');
        const tourNavigation = document.querySelector('.tour-navigation');
        
        if (tourCompletion) tourCompletion.style.display = 'none';
        if (tourSections) tourSections.style.display = 'block';
        if (tourNavigation) tourNavigation.style.display = 'flex';
        
        this.startTour();
    }

    updateButlerMessage(message) {
        const butlerMessage = document.getElementById('butler-message');
        if (butlerMessage) {
            butlerMessage.textContent = message;
        }
    }

    // Notification System
    showNotification(type, title, message, duration = 5000) {
        const container = document.getElementById('notification-container');
        if (!container) return;
        
        const notification = document.createElement('div');
        notification.className = `notification ${type}`;
        
        const icons = {
            success: 'fa-check-circle',
            error: 'fa-exclamation-circle',
            warning: 'fa-exclamation-triangle',
            info: 'fa-info-circle'
        };
        
        notification.innerHTML = `
            <div class="notification-content">
                <div class="notification-icon">
                    <i class="fas ${icons[type] || icons.info}"></i>
                </div>
                <div class="notification-text">
                    <div class="notification-title">${title}</div>
                    <div class="notification-message">${message}</div>
                </div>
                <button class="notification-close">
                    <i class="fas fa-times"></i>
                </button>
            </div>
        `;
        
        // Add close functionality
        const closeBtn = notification.querySelector('.notification-close');
        closeBtn.addEventListener('click', () => {
            notification.remove();
        });
        
        container.appendChild(notification);
        
        // Auto-remove after duration
        if (duration > 0) {
            setTimeout(() => {
                if (notification.parentNode) {
                    notification.remove();
                }
            }, duration);
        }
    }

    // Utility Methods
    showLoading(message = 'Processing...') {
        const overlay = document.getElementById('loading-overlay');
        const loadingMessage = document.getElementById('loading-message');
        
        if (overlay) overlay.style.display = 'flex';
        if (loadingMessage) loadingMessage.textContent = message;
    }

    hideLoading() {
        const overlay = document.getElementById('loading-overlay');
        if (overlay) overlay.style.display = 'none';
    }
}

// Global helper functions
function toggleExpandable(header) {
    const section = header.closest('.expandable');
    if (section) {
        section.classList.toggle('expanded');
    }
}

// Initialize app when DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
    window.sefirotApp = new SefirotApp();
});

// Handle window events
window.addEventListener('beforeunload', () => {
    // Cleanup if needed
    console.log('Sefirot app shutting down...');
});