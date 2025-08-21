// Sefirot Intelligence Platform - Interactive Tour System

class SefirotTour {
    constructor() {
        this.sections = [
            {
                id: 'introduction',
                title: 'Meet Your AI Intelligence',
                butlerMessage: "Welcome! Let's explore what makes your Sefirot platform so powerful. Think of it as your personal AI that learns how YOU think.",
                duration: 30000, // 30 seconds auto-advance
                interactions: [
                    {
                        type: 'highlight',
                        selector: '.tour-section[data-section="introduction"] ul',
                        message: 'These four technologies work together seamlessly'
                    }
                ]
            },
            {
                id: 'privacy',
                title: 'Understanding Privacy Tiers',
                butlerMessage: "Privacy isn't just a feature - it's the foundation. You control exactly what information AI can access and how it's used.",
                duration: 45000, // 45 seconds
                interactions: [
                    {
                        type: 'animate',
                        selector: '.tier-card',
                        animation: 'slideInFromLeft',
                        delay: 500
                    },
                    {
                        type: 'pulse',
                        selector: '.tier-card.tier-3',
                        message: 'Your most sensitive data never leaves your Mac'
                    }
                ]
            },
            {
                id: 'features',
                title: 'Key Features Demo',
                butlerMessage: "Here's where the magic happens. Watch how intelligent search and automatic classification make your work effortless.",
                duration: 60000, // 1 minute
                interactions: [
                    {
                        type: 'typeText',
                        selector: '.search-box input',
                        text: 'AI projects from last quarter',
                        speed: 100
                    },
                    {
                        type: 'simulate',
                        action: 'searchDemo',
                        delay: 2000
                    }
                ]
            },
            {
                id: 'workflow',
                title: 'Your Daily Workflow',
                butlerMessage: "Let me show you how this fits into your daily routine. It's designed to enhance your natural thinking process, not replace it.",
                duration: 50000, // 50 seconds
                interactions: [
                    {
                        type: 'progressiveReveal',
                        selector: '.workflow-step',
                        interval: 3000
                    }
                ]
            },
            {
                id: 'tools',
                title: 'Essential Tools',
                butlerMessage: "These are your power tools. Master these and you'll have unprecedented control over your knowledge work.",
                duration: 40000, // 40 seconds
                interactions: [
                    {
                        type: 'codeHighlight',
                        selector: '.tool-card code',
                        interval: 2000
                    }
                ]
            }
        ];
        
        this.currentSection = 0;
        this.isPlaying = false;
        this.autoAdvanceTimer = null;
        this.interactionTimers = [];
        
        this.init();
    }

    init() {
        console.log('🎓 Sefirot Tour system initialized');
        this.setupTourControls();
        this.setupKeyboardControls();
    }

    setupTourControls() {
        // Auto-pause on hover
        const tourContainer = document.querySelector('.tour-container');
        if (tourContainer) {
            tourContainer.addEventListener('mouseenter', () => {
                if (this.isPlaying) {
                    this.pauseAutoAdvance();
                }
            });
            
            tourContainer.addEventListener('mouseleave', () => {
                if (this.isPlaying) {
                    this.resumeAutoAdvance();
                }
            });
        }

        // Progress dot navigation
        const progressDots = document.querySelectorAll('.progress-dots .dot');
        progressDots.forEach((dot, index) => {
            dot.addEventListener('click', () => {
                this.goToSection(index);
            });
            
            // Add tooltip
            dot.title = this.sections[index]?.title || '';
        });
    }

    setupKeyboardControls() {
        document.addEventListener('keydown', (event) => {
            // Only handle keys when tour is active
            if (!document.getElementById('tour-phase')?.classList.contains('active')) {
                return;
            }
            
            switch (event.key) {
                case 'ArrowLeft':
                case 'ArrowUp':
                    event.preventDefault();
                    this.previousSection();
                    break;
                    
                case 'ArrowRight':
                case 'ArrowDown':
                case ' ':
                    event.preventDefault();
                    this.nextSection();
                    break;
                    
                case 'Escape':
                    event.preventDefault();
                    this.pauseAutoAdvance();
                    break;
                    
                case 'Home':
                    event.preventDefault();
                    this.goToSection(0);
                    break;
                    
                case 'End':
                    event.preventDefault();
                    this.goToSection(this.sections.length - 1);
                    break;
            }
        });
    }

    startTour(fromSection = 0) {
        console.log('🚀 Starting Sefirot tour');
        
        this.currentSection = fromSection;
        this.isPlaying = true;
        
        // Show tour controls hint
        this.showTourHint();
        
        // Start first section
        this.goToSection(fromSection);
    }

    goToSection(sectionIndex) {
        if (sectionIndex < 0 || sectionIndex >= this.sections.length) {
            return;
        }
        
        console.log(`📍 Tour section ${sectionIndex + 1}: ${this.sections[sectionIndex].title}`);
        
        // Clear any existing timers
        this.clearTimers();
        
        // Update current section
        this.currentSection = sectionIndex;
        const section = this.sections[sectionIndex];
        
        // Hide all sections
        const tourSections = document.querySelectorAll('.tour-section');
        tourSections.forEach(s => s.classList.remove('active'));
        
        // Show target section with animation
        const targetSection = document.querySelector(`[data-section="${section.id}"]`);
        if (targetSection) {
            targetSection.classList.add('active');
            this.animateSection(targetSection);
        }
        
        // Update progress dots
        this.updateProgressDots();
        
        // Update navigation buttons
        this.updateNavigationButtons();
        
        // Update butler message
        this.updateButlerMessage(section.butlerMessage);
        
        // Start section interactions
        this.startSectionInteractions(section);
        
        // Set auto-advance timer
        if (this.isPlaying && section.duration) {
            this.setAutoAdvanceTimer(section.duration);
        }
    }

    nextSection() {
        if (this.currentSection < this.sections.length - 1) {
            this.goToSection(this.currentSection + 1);
        } else {
            this.completeTour();
        }
    }

    previousSection() {
        if (this.currentSection > 0) {
            this.goToSection(this.currentSection - 1);
        }
    }

    completeTour() {
        console.log('🎉 Tour completed');
        
        this.isPlaying = false;
        this.clearTimers();
        
        // Show completion state
        const tourCompletion = document.querySelector('.tour-completion');
        const tourSections = document.querySelector('.tour-sections');
        const tourNavigation = document.querySelector('.tour-navigation');
        
        if (tourCompletion) tourCompletion.style.display = 'block';
        if (tourSections) tourSections.style.display = 'none';
        if (tourNavigation) tourNavigation.style.display = 'none';
        
        // Final butler message
        this.updateButlerMessage("Congratulations! You're now ready to harness the full power of your AI intelligence platform. Remember, I'm always here to help!");
        
        // Celebration animation
        this.showCelebrationAnimation();
        
        // Analytics (if implemented)
        this.trackTourCompletion();
    }

    replayTour() {
        console.log('🔄 Replaying tour');
        
        // Reset completion state
        const tourCompletion = document.querySelector('.tour-completion');
        const tourSections = document.querySelector('.tour-sections');
        const tourNavigation = document.querySelector('.tour-navigation');
        
        if (tourCompletion) tourCompletion.style.display = 'none';
        if (tourSections) tourSections.style.display = 'block';
        if (tourNavigation) tourNavigation.style.display = 'flex';
        
        // Restart from beginning
        this.startTour(0);
    }

    pauseAutoAdvance() {
        if (this.autoAdvanceTimer) {
            clearTimeout(this.autoAdvanceTimer);
            this.autoAdvanceTimer = null;
        }
        
        this.showPauseIndicator();
    }

    resumeAutoAdvance() {
        const section = this.sections[this.currentSection];
        if (section && section.duration) {
            this.setAutoAdvanceTimer(section.duration);
        }
        
        this.hidePauseIndicator();
    }

    setAutoAdvanceTimer(duration) {
        this.autoAdvanceTimer = setTimeout(() => {
            if (this.isPlaying) {
                this.nextSection();
            }
        }, duration);
    }

    clearTimers() {
        if (this.autoAdvanceTimer) {
            clearTimeout(this.autoAdvanceTimer);
            this.autoAdvanceTimer = null;
        }
        
        this.interactionTimers.forEach(timer => clearTimeout(timer));
        this.interactionTimers = [];
    }

    updateProgressDots() {
        const dots = document.querySelectorAll('.progress-dots .dot');
        dots.forEach((dot, index) => {
            dot.classList.toggle('active', index === this.currentSection);
            
            // Add completion indicator
            if (index < this.currentSection) {
                dot.classList.add('completed');
            } else {
                dot.classList.remove('completed');
            }
        });
    }

    updateNavigationButtons() {
        const prevBtn = document.getElementById('tour-prev-btn');
        const nextBtn = document.getElementById('tour-next-btn');
        
        if (prevBtn) {
            prevBtn.disabled = this.currentSection === 0;
        }
        
        if (nextBtn) {
            if (this.currentSection === this.sections.length - 1) {
                nextBtn.innerHTML = 'Finish Tour <i class="fas fa-flag-checkered"></i>';
            } else {
                nextBtn.innerHTML = 'Next <i class="fas fa-arrow-right"></i>';
            }
        }
    }

    updateButlerMessage(message) {
        const butlerMessage = document.getElementById('butler-message');
        if (butlerMessage) {
            // Type out the message with animation
            this.typeOutMessage(butlerMessage, message);
        }
    }

    typeOutMessage(element, message, speed = 50) {
        element.textContent = '';
        let index = 0;
        
        const typeChar = () => {
            if (index < message.length) {
                element.textContent += message.charAt(index);
                index++;
                
                const timer = setTimeout(typeChar, speed);
                this.interactionTimers.push(timer);
            }
        };
        
        typeChar();
    }

    animateSection(sectionElement) {
        // Add entrance animation
        sectionElement.style.animation = 'none';
        sectionElement.offsetHeight; // Force reflow
        sectionElement.style.animation = 'slideInFromRight 0.5s ease forwards';
    }

    startSectionInteractions(section) {
        if (!section.interactions) return;
        
        section.interactions.forEach((interaction, index) => {
            const delay = interaction.delay || (index * 1000);
            
            const timer = setTimeout(() => {
                this.executeInteraction(interaction);
            }, delay);
            
            this.interactionTimers.push(timer);
        });
    }

    executeInteraction(interaction) {
        switch (interaction.type) {
            case 'highlight':
                this.highlightElement(interaction.selector, interaction.message);
                break;
                
            case 'animate':
                this.animateElement(interaction.selector, interaction.animation);
                break;
                
            case 'pulse':
                this.pulseElement(interaction.selector, interaction.message);
                break;
                
            case 'typeText':
                this.typeIntoInput(interaction.selector, interaction.text, interaction.speed);
                break;
                
            case 'simulate':
                this.simulateAction(interaction.action);
                break;
                
            case 'progressiveReveal':
                this.progressiveReveal(interaction.selector, interaction.interval);
                break;
                
            case 'codeHighlight':
                this.highlightCode(interaction.selector, interaction.interval);
                break;
        }
    }

    highlightElement(selector, message) {
        const element = document.querySelector(selector);
        if (!element) return;
        
        element.style.position = 'relative';
        element.style.zIndex = '10';
        
        // Add highlight overlay
        const highlight = document.createElement('div');
        highlight.className = 'tour-highlight';
        highlight.style.cssText = `
            position: absolute;
            top: -5px;
            left: -5px;
            right: -5px;
            bottom: -5px;
            background: rgba(79, 70, 229, 0.2);
            border: 2px solid #4F46E5;
            border-radius: 8px;
            pointer-events: none;
            animation: highlightPulse 2s ease-in-out infinite;
        `;
        
        element.appendChild(highlight);
        
        // Show message tooltip
        if (message) {
            this.showTooltip(element, message);
        }
        
        // Remove after 5 seconds
        setTimeout(() => {
            if (highlight.parentNode) {
                highlight.remove();
            }
        }, 5000);
    }

    animateElement(selector, animationName) {
        const elements = document.querySelectorAll(selector);
        elements.forEach((element, index) => {
            setTimeout(() => {
                element.style.animation = `${animationName} 0.6s ease forwards`;
            }, index * 200);
        });
    }

    pulseElement(selector, message) {
        const element = document.querySelector(selector);
        if (!element) return;
        
        element.style.animation = 'tourPulse 1s ease-in-out 3';
        
        if (message) {
            this.showTooltip(element, message);
        }
    }

    typeIntoInput(selector, text, speed = 100) {
        const input = document.querySelector(selector);
        if (!input) return;
        
        input.value = '';
        input.focus();
        
        let index = 0;
        const typeChar = () => {
            if (index < text.length) {
                input.value += text.charAt(index);
                index++;
                
                // Trigger input event
                input.dispatchEvent(new Event('input', { bubbles: true }));
                
                const timer = setTimeout(typeChar, speed);
                this.interactionTimers.push(timer);
            }
        };
        
        typeChar();
    }

    simulateAction(action) {
        switch (action) {
            case 'searchDemo':
                this.simulateSearchDemo();
                break;
        }
    }

    simulateSearchDemo() {
        const searchButton = document.querySelector('.search-box button');
        const demoResult = document.querySelector('.demo-result');
        
        if (searchButton) {
            // Simulate button click
            searchButton.style.background = '#3730A3';
            
            setTimeout(() => {
                searchButton.style.background = '#4F46E5';
                
                // Show "searching" state
                if (demoResult) {
                    demoResult.textContent = 'Searching...';
                    
                    setTimeout(() => {
                        demoResult.textContent = 'Found 12 related documents by meaning, not just keywords';
                        demoResult.style.color = '#10B981';
                    }, 1500);
                }
            }, 500);
        }
    }

    progressiveReveal(selector, interval) {
        const elements = document.querySelectorAll(selector);
        
        // Initially hide all elements
        elements.forEach(element => {
            element.style.opacity = '0';
            element.style.transform = 'translateX(-20px)';
            element.style.transition = 'all 0.5s ease';
        });
        
        // Reveal each element progressively
        elements.forEach((element, index) => {
            const timer = setTimeout(() => {
                element.style.opacity = '1';
                element.style.transform = 'translateX(0)';
            }, index * interval);
            
            this.interactionTimers.push(timer);
        });
    }

    highlightCode(selector, interval) {
        const codeElements = document.querySelectorAll(selector);
        
        codeElements.forEach((element, index) => {
            const timer = setTimeout(() => {
                element.style.background = 'rgba(79, 70, 229, 0.2)';
                element.style.transition = 'background 0.3s ease';
                
                setTimeout(() => {
                    element.style.background = '';
                }, 2000);
            }, index * interval);
            
            this.interactionTimers.push(timer);
        });
    }

    showTooltip(element, message) {
        const tooltip = document.createElement('div');
        tooltip.className = 'tour-tooltip';
        tooltip.textContent = message;
        tooltip.style.cssText = `
            position: absolute;
            top: -40px;
            left: 50%;
            transform: translateX(-50%);
            background: #1F2937;
            color: white;
            padding: 8px 12px;
            border-radius: 6px;
            font-size: 14px;
            white-space: nowrap;
            z-index: 1000;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.3);
        `;
        
        // Add arrow
        const arrow = document.createElement('div');
        arrow.style.cssText = `
            position: absolute;
            top: 100%;
            left: 50%;
            transform: translateX(-50%);
            width: 0;
            height: 0;
            border-left: 6px solid transparent;
            border-right: 6px solid transparent;
            border-top: 6px solid #1F2937;
        `;
        
        tooltip.appendChild(arrow);
        element.appendChild(tooltip);
        
        // Remove after 3 seconds
        setTimeout(() => {
            if (tooltip.parentNode) {
                tooltip.remove();
            }
        }, 3000);
    }

    showTourHint() {
        if (window.sefirotApp) {
            window.sefirotApp.showNotification('info', 'Tour Controls', 
                'Use arrow keys to navigate, spacebar to advance, or ESC to pause. Click progress dots to jump to sections.');
        }
    }

    showPauseIndicator() {
        const indicator = document.createElement('div');
        indicator.id = 'tour-pause-indicator';
        indicator.innerHTML = '<i class="fas fa-pause"></i> Paused';
        indicator.style.cssText = `
            position: fixed;
            top: 20px;
            right: 20px;
            background: rgba(245, 158, 11, 0.9);
            color: white;
            padding: 8px 16px;
            border-radius: 20px;
            font-size: 14px;
            z-index: 1000;
            display: flex;
            align-items: center;
            gap: 8px;
        `;
        
        document.body.appendChild(indicator);
    }

    hidePauseIndicator() {
        const indicator = document.getElementById('tour-pause-indicator');
        if (indicator) {
            indicator.remove();
        }
    }

    showCelebrationAnimation() {
        // Create confetti effect
        const colors = ['#4F46E5', '#06B6D4', '#10B981', '#F59E0B', '#EF4444'];
        
        for (let i = 0; i < 50; i++) {
            setTimeout(() => {
                this.createConfetti(colors[Math.floor(Math.random() * colors.length)]);
            }, i * 100);
        }
    }

    createConfetti(color) {
        const confetti = document.createElement('div');
        confetti.style.cssText = `
            position: fixed;
            top: -10px;
            left: ${Math.random() * window.innerWidth}px;
            width: 10px;
            height: 10px;
            background: ${color};
            border-radius: 50%;
            pointer-events: none;
            z-index: 1000;
            animation: confettiFall ${2 + Math.random() * 3}s linear forwards;
        `;
        
        document.body.appendChild(confetti);
        
        setTimeout(() => {
            confetti.remove();
        }, 5000);
    }

    trackTourCompletion() {
        // Analytics placeholder
        console.log('📊 Tour completion tracked');
        
        // Could send analytics data here
        const completionData = {
            timestamp: new Date().toISOString(),
            totalTime: Date.now() - this.startTime,
            sectionsViewed: this.sections.length,
            tourVersion: '1.0'
        };
        
        // Store locally for now
        localStorage.setItem('sefirot_tour_completion', JSON.stringify(completionData));
    }
}

// Add required CSS animations
const tourStyles = `
@keyframes highlightPulse {
    0%, 100% { opacity: 0.3; }
    50% { opacity: 0.7; }
}

@keyframes tourPulse {
    0%, 100% { transform: scale(1); }
    50% { transform: scale(1.05); }
}

@keyframes slideInFromRight {
    from { opacity: 0; transform: translateX(30px); }
    to { opacity: 1; transform: translateX(0); }
}

@keyframes slideInFromLeft {
    from { opacity: 0; transform: translateX(-30px); }
    to { opacity: 1; transform: translateX(0); }
}

@keyframes confettiFall {
    0% { transform: translateY(0) rotate(0deg); opacity: 1; }
    100% { transform: translateY(100vh) rotate(360deg); opacity: 0; }
}

.tour-highlight {
    animation: highlightPulse 2s ease-in-out infinite;
}

.progress-dots .dot.completed {
    background: #10B981 !important;
    position: relative;
}

.progress-dots .dot.completed::after {
    content: '✓';
    position: absolute;
    top: 50%;
    left: 50%;
    transform: translate(-50%, -50%);
    font-size: 10px;
    color: white;
    font-weight: bold;
}
`;

// Inject tour styles
const tourStyleSheet = document.createElement('style');
tourStyleSheet.textContent = tourStyles;
document.head.appendChild(tourStyleSheet);

// Export for use in other modules
if (typeof module !== 'undefined' && module.exports) {
    module.exports = SefirotTour;
} else {
    window.SefirotTour = SefirotTour;
}