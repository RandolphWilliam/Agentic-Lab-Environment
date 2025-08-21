const { contextBridge, ipcRenderer } = require('electron');

// Expose protected methods that allow the renderer process to use
// the ipcRenderer without exposing the entire object
contextBridge.exposeInMainWorld('electronAPI', {
  // System and app info
  getAppInfo: () => ipcRenderer.invoke('get-app-info'),
  
  // System requirements
  checkSystemRequirements: () => ipcRenderer.invoke('check-system-requirements'),
  
  // Credentials management
  saveCredentials: (credentials) => ipcRenderer.invoke('save-credentials', credentials),
  loadCredentials: () => ipcRenderer.invoke('load-credentials'),
  
  // Installation control
  startInstallation: () => ipcRenderer.invoke('start-installation'),
  getInstallationStatus: () => ipcRenderer.invoke('get-installation-status'),
  
  // External actions
  openExternal: (url) => ipcRenderer.invoke('open-external', url),
  openPath: (path) => ipcRenderer.invoke('open-path', path),
  
  // Launch Sefirot tools
  launchSefirotCLI: () => ipcRenderer.invoke('launch-sefirot-cli'),
  launchObsidianVault: () => ipcRenderer.invoke('launch-obsidian-vault'),
  
  // Event listeners for installation progress
  onSystemRequirementsResult: (callback) => {
    ipcRenderer.on('system-requirements-result', callback);
  },
  
  onInstallationStepStart: (callback) => {
    ipcRenderer.on('installation-step-start', callback);
  },
  
  onInstallationStepComplete: (callback) => {
    ipcRenderer.on('installation-step-complete', callback);
  },
  
  onInstallationStepError: (callback) => {
    ipcRenderer.on('installation-step-error', callback);
  },
  
  onInstallationProgress: (callback) => {
    ipcRenderer.on('installation-progress', callback);
  },
  
  onInstallationLog: (callback) => {
    ipcRenderer.on('installation-log', callback);
  },
  
  onInstallationComplete: (callback) => {
    ipcRenderer.on('installation-complete', callback);
  },
  
  // Remove listeners
  removeAllListeners: (channel) => {
    ipcRenderer.removeAllListeners(channel);
  }
});