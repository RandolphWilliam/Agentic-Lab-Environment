const { app, BrowserWindow, ipcMain, dialog, shell, Menu } = require('electron');
const path = require('path');
const fs = require('fs');
const { spawn } = require('child_process');
const Store = require('electron-store');
const log = require('electron-log');
const os = require('os');

// Configure logging
log.transports.file.level = 'info';
log.transports.console.level = 'debug';

// Initialize secure storage
const store = new Store({
  name: 'sefirot-config',
  encryptionKey: 'sefirot-encryption-key-' + os.userInfo().username
});

class SefirotInstaller {
  constructor() {
    this.mainWindow = null;
    this.installationState = {
      phase: 'welcome', // welcome, requirements, credentials, installation, completion, tour
      currentStep: 0,
      totalSteps: 5,
      isInstalling: false,
      installationComplete: false,
      errors: [],
      logs: []
    };
    
    this.distributionPath = path.join(__dirname, '..');
    this.sequencedInstallPath = path.join(this.distributionPath, 'SEQUENCED-INSTALLATION');
    
    log.info('Sefirot Installer initialized');
  }

  async createWindow() {
    // Create the browser window
    this.mainWindow = new BrowserWindow({
      width: 1000,
      height: 700,
      minWidth: 900,
      minHeight: 600,
      webPreferences: {
        nodeIntegration: false,
        contextIsolation: true,
        enableRemoteModule: false,
        preload: path.join(__dirname, 'preload.js')
      },
      titleBarStyle: 'hiddenInset',
      show: false,
      icon: path.join(__dirname, 'assets', 'icon.png')
    });

    // Load the app
    await this.mainWindow.loadFile('renderer/index.html');
    
    // Show when ready to prevent visual flash
    this.mainWindow.once('ready-to-show', () => {
      this.mainWindow.show();
      
      // Focus the window on macOS
      if (process.platform === 'darwin') {
        app.focus();
      }
    });

    // Handle window closed
    this.mainWindow.on('closed', () => {
      this.mainWindow = null;
    });

    // Setup menu
    this.createMenu();
    
    // Initialize IPC handlers
    this.setupIPC();
    
    log.info('Main window created and configured');
  }

  createMenu() {
    const template = [
      {
        label: app.getName(),
        submenu: [
          { role: 'about' },
          { type: 'separator' },
          { role: 'services' },
          { type: 'separator' },
          { role: 'hide' },
          { role: 'hideothers' },
          { role: 'unhide' },
          { type: 'separator' },
          { role: 'quit' }
        ]
      },
      {
        label: 'Edit',
        submenu: [
          { role: 'undo' },
          { role: 'redo' },
          { type: 'separator' },
          { role: 'cut' },
          { role: 'copy' },
          { role: 'paste' },
          { role: 'selectall' }
        ]
      },
      {
        label: 'View',
        submenu: [
          { role: 'reload' },
          { role: 'forceReload' },
          { role: 'toggleDevTools' },
          { type: 'separator' },
          { role: 'resetZoom' },
          { role: 'zoomIn' },
          { role: 'zoomOut' },
          { type: 'separator' },
          { role: 'togglefullscreen' }
        ]
      },
      {
        label: 'Window',
        submenu: [
          { role: 'minimize' },
          { role: 'close' }
        ]
      },
      {
        label: 'Help',
        submenu: [
          {
            label: 'Sefirot Documentation',
            click: () => {
              shell.openExternal('https://sefirot.dev/docs');
            }
          },
          {
            label: 'Support',
            click: () => {
              shell.openExternal('mailto:hello@sefirot.dev');
            }
          }
        ]
      }
    ];

    const menu = Menu.buildFromTemplate(template);
    Menu.setApplicationMenu(menu);
  }

  setupIPC() {
    // System requirements check
    ipcMain.handle('check-system-requirements', async () => {
      try {
        log.info('Checking system requirements');
        
        const requirements = await this.checkSystemRequirements();
        
        this.sendToRenderer('system-requirements-result', requirements);
        return requirements;
      } catch (error) {
        log.error('System requirements check failed:', error);
        return { requirementsMet: false, error: error.message };
      }
    });

    // Credentials management
    ipcMain.handle('save-credentials', async (event, credentials) => {
      try {
        log.info('Saving user credentials');
        
        // Validate credentials
        const validationResult = this.validateCredentials(credentials);
        if (!validationResult.valid) {
          return { success: false, error: validationResult.error };
        }

        // Save to secure store
        store.set('credentials', credentials);
        
        // Create credentials file
        await this.createCredentialsFile(credentials);
        
        log.info('Credentials saved successfully');
        return { success: true };
      } catch (error) {
        log.error('Failed to save credentials:', error);
        return { success: false, error: error.message };
      }
    });

    ipcMain.handle('load-credentials', async () => {
      try {
        const credentials = store.get('credentials', {});
        return { success: true, credentials };
      } catch (error) {
        log.error('Failed to load credentials:', error);
        return { success: false, error: error.message };
      }
    });

    // Installation control
    ipcMain.handle('start-installation', async () => {
      try {
        log.info('Starting Sefirot installation');
        
        if (this.installationState.isInstalling) {
          return { success: false, error: 'Installation already in progress' };
        }

        this.installationState.isInstalling = true;
        this.installationState.phase = 'installation';
        this.installationState.currentStep = 1;
        this.installationState.errors = [];
        this.installationState.logs = [];

        // Start installation sequence
        await this.runInstallationSequence();
        
        return { success: true };
      } catch (error) {
        log.error('Failed to start installation:', error);
        this.installationState.isInstalling = false;
        return { success: false, error: error.message };
      }
    });

    // Get installation status
    ipcMain.handle('get-installation-status', () => {
      return this.installationState;
    });

    // Open external links
    ipcMain.handle('open-external', async (event, url) => {
      await shell.openExternal(url);
    });

    // Open file/folder
    ipcMain.handle('open-path', async (event, filePath) => {
      await shell.openPath(filePath);
    });

    // Get app info
    ipcMain.handle('get-app-info', () => {
      return {
        name: app.getName(),
        version: app.getVersion(),
        distributionPath: this.distributionPath,
        userDataPath: app.getPath('userData')
      };
    });

    // Launch Sefirot tools
    ipcMain.handle('launch-sefirot-cli', async () => {
      try {
        const sefirotCLI = path.join(os.homedir(), '.sefirot', 'bin', 'sefirot');
        if (fs.existsSync(sefirotCLI)) {
          spawn('open', ['-a', 'Terminal', sefirotCLI], { detached: true });
          return { success: true };
        } else {
          return { success: false, error: 'Sefirot CLI not found' };
        }
      } catch (error) {
        log.error('Failed to launch Sefirot CLI:', error);
        return { success: false, error: error.message };
      }
    });

    ipcMain.handle('launch-obsidian-vault', async () => {
      try {
        const vaultPath = path.join(os.homedir(), 'SefirotVault');
        if (fs.existsSync(vaultPath)) {
          await shell.openPath(vaultPath);
          return { success: true };
        } else {
          return { success: false, error: 'Sefirot vault not found' };
        }
      } catch (error) {
        log.error('Failed to launch Obsidian vault:', error);
        return { success: false, error: error.message };
      }
    });

    log.info('IPC handlers set up');
  }

  async checkSystemRequirements() {
    return new Promise((resolve, reject) => {
      const pythonScript = path.join(this.distributionPath, 'GUI-INTEGRATION', 'gui_wrapper_api.py');
      
      const process = spawn('python3', [pythonScript, 'check']);
      let output = '';
      let error = '';

      process.stdout.on('data', (data) => {
        output += data.toString();
      });

      process.stderr.on('data', (data) => {
        error += data.toString();
      });

      process.on('close', (code) => {
        if (code === 0) {
          try {
            const requirements = JSON.parse(output);
            resolve(requirements);
          } catch (parseError) {
            reject(new Error('Failed to parse requirements check result'));
          }
        } else {
          reject(new Error(error || 'Requirements check failed'));
        }
      });

      process.on('error', (err) => {
        reject(err);
      });
    });
  }

  validateCredentials(credentials) {
    const required = ['anthropic_api_key', 'openai_api_key'];
    const missing = [];

    for (const field of required) {
      if (!credentials[field] || credentials[field].trim() === '') {
        missing.push(field);
      }
    }

    // Basic API key format validation
    if (credentials.anthropic_api_key && !credentials.anthropic_api_key.startsWith('sk-ant-')) {
      return { valid: false, error: 'Anthropic API key should start with "sk-ant-"' };
    }

    if (credentials.openai_api_key && !credentials.openai_api_key.startsWith('sk-')) {
      return { valid: false, error: 'OpenAI API key should start with "sk-"' };
    }

    if (missing.length > 0) {
      return { valid: false, error: `Missing required credentials: ${missing.join(', ')}` };
    }

    return { valid: true };
  }

  async createCredentialsFile(credentials) {
    const credentialsTemplate = `
anthropic:
  api_key: "${credentials.anthropic_api_key}"
  plan_type: "professional"
  model_preferences:
    primary: "claude-3-5-sonnet-20241022"
    fallback: "claude-3-haiku-20240307"

openai:
  api_key: "${credentials.openai_api_key}"
  model_preferences:
    embeddings: "text-embedding-3-small"
    fallback_llm: "gpt-4"

shopify:
  store_url: "${credentials.shopify_store_url || ''}"
  access_token: "${credentials.shopify_access_token || ''}"
  enabled: ${credentials.shopify_access_token ? 'true' : 'false'}

optional_services:
  runpod:
    api_key: "${credentials.runpod_api_key || ''}"
    enabled: ${credentials.runpod_api_key ? 'true' : 'false'}
  
  paperspace:
    api_key: "${credentials.paperspace_api_key || ''}"
    enabled: ${credentials.paperspace_api_key ? 'true' : 'false'}

  pinecone:
    api_key: "${credentials.pinecone_api_key || ''}"
    environment: "${credentials.pinecone_environment || 'us-east-1-aws'}"
    enabled: ${credentials.pinecone_api_key ? 'true' : 'false'}

privacy_settings:
  data_processing: "local_only"
  cloud_fallback: "with_consent"
  telemetry: "minimal"

configuration:
  created_at: "${new Date().toISOString()}"
  created_by: "sefirot_installer"
  version: "1.0"
`;

    const sefirotDir = path.join(os.homedir(), '.sefirot');
    if (!fs.existsSync(sefirotDir)) {
      fs.mkdirSync(sefirotDir, { recursive: true });
    }

    const credentialsPath = path.join(sefirotDir, 'credentials.yaml');
    fs.writeFileSync(credentialsPath, credentialsTemplate.trim());
    
    // Set secure permissions (macOS/Linux)
    if (process.platform !== 'win32') {
      fs.chmodSync(credentialsPath, '600');
    }
  }

  async runInstallationSequence() {
    const steps = [
      { script: 'step_01_environment_setup.sh', name: 'Environment Setup' },
      { script: 'step_02_python_environment.sh', name: 'Python Environment' },
      { script: 'step_03_chromadb_platform.sh', name: 'ChromaDB Platform' },
      { script: 'step_04_obsidian_integration.sh', name: 'Obsidian Integration' },
      { script: 'step_05_final_configuration.sh', name: 'Final Configuration' }
    ];

    for (let i = 0; i < steps.length; i++) {
      const step = steps[i];
      this.installationState.currentStep = i + 1;
      
      this.sendToRenderer('installation-step-start', {
        step: i + 1,
        name: step.name,
        total: steps.length
      });

      try {
        await this.runInstallationStep(step.script, step.name, i + 1);
        
        this.sendToRenderer('installation-step-complete', {
          step: i + 1,
          name: step.name,
          total: steps.length
        });
        
      } catch (error) {
        log.error(`Installation step ${i + 1} failed:`, error);
        
        this.installationState.errors.push({
          step: i + 1,
          name: step.name,
          error: error.message
        });

        this.sendToRenderer('installation-step-error', {
          step: i + 1,
          name: step.name,
          error: error.message
        });

        // For now, continue with next steps even if one fails
        // In production, you might want to offer retry/skip options
      }
    }

    this.installationState.isInstalling = false;
    this.installationState.installationComplete = true;
    this.installationState.phase = 'completion';
    
    this.sendToRenderer('installation-complete', {
      success: this.installationState.errors.length === 0,
      errors: this.installationState.errors
    });
  }

  runInstallationStep(scriptName, stepName, stepNumber) {
    return new Promise((resolve, reject) => {
      const scriptPath = path.join(this.sequencedInstallPath, scriptName);
      
      if (!fs.existsSync(scriptPath)) {
        reject(new Error(`Installation script not found: ${scriptPath}`));
        return;
      }

      log.info(`Running installation step ${stepNumber}: ${stepName}`);
      
      const process = spawn('/bin/bash', [scriptPath], {
        cwd: this.distributionPath,
        env: { ...process.env, SEFIROT_GUI_MODE: '1' }
      });

      let output = '';
      let currentProgress = 0;

      process.stdout.on('data', (data) => {
        const chunk = data.toString();
        output += chunk;
        
        // Extract progress information
        const lines = chunk.split('\n');
        for (const line of lines) {
          if (line.trim()) {
            this.installationState.logs.push({
              step: stepNumber,
              timestamp: new Date().toISOString(),
              message: line.trim()
            });

            // Send log to renderer
            this.sendToRenderer('installation-log', {
              step: stepNumber,
              message: line.trim()
            });

            // Extract progress
            const progress = this.extractProgress(line);
            if (progress >= 0 && progress !== currentProgress) {
              currentProgress = progress;
              this.sendToRenderer('installation-progress', {
                step: stepNumber,
                progress: currentProgress,
                message: line.trim()
              });
            }
          }
        }
      });

      process.stderr.on('data', (data) => {
        const chunk = data.toString();
        this.installationState.logs.push({
          step: stepNumber,
          timestamp: new Date().toISOString(),
          message: chunk.trim(),
          type: 'error'
        });

        this.sendToRenderer('installation-log', {
          step: stepNumber,
          message: chunk.trim(),
          type: 'error'
        });
      });

      process.on('close', (code) => {
        log.info(`Installation step ${stepNumber} completed with code ${code}`);
        
        if (code === 0) {
          resolve();
        } else {
          reject(new Error(`Installation step failed with exit code ${code}`));
        }
      });

      process.on('error', (error) => {
        log.error(`Installation step ${stepNumber} process error:`, error);
        reject(error);
      });
    });
  }

  extractProgress(line) {
    // Extract progress from installation script output
    const progressPatterns = [
      /Step \d+\.\d+:/,
      /✅.*STEP.*COMPLETED/,
      /❌.*STEP.*FAILED/,
      /(\d+)%/
    ];

    // Look for step sub-progress
    const stepMatch = line.match(/Step \d+\.(\d+):/);
    if (stepMatch) {
      const subStep = parseInt(stepMatch[1]);
      return Math.min(subStep * 10, 90); // Cap at 90% until completion
    }

    // Look for completion markers
    if (line.includes('✅') && line.includes('STEP') && line.includes('COMPLETED')) {
      return 100;
    }

    // Look for percentage
    const percentMatch = line.match(/(\d+)%/);
    if (percentMatch) {
      return parseInt(percentMatch[1]);
    }

    return -1;
  }

  sendToRenderer(channel, data) {
    if (this.mainWindow && !this.mainWindow.isDestroyed()) {
      this.mainWindow.webContents.send(channel, data);
    }
  }
}

// App event handling
const installer = new SefirotInstaller();

app.whenReady().then(async () => {
  await installer.createWindow();
});

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') {
    app.quit();
  }
});

app.on('activate', async () => {
  if (BrowserWindow.getAllWindows().length === 0) {
    await installer.createWindow();
  }
});

// Security: Prevent new window creation
app.on('web-contents-created', (event, contents) => {
  contents.on('new-window', (event, navigationUrl) => {
    event.preventDefault();
    shell.openExternal(navigationUrl);
  });
});

// Handle certificate errors
app.on('certificate-error', (event, webContents, url, error, certificate, callback) => {
  event.preventDefault();
  callback(false);
});