const { contextBridge, ipcRenderer } = require('electron');

contextBridge.exposeInMainWorld('widgetAPI', {
  expand: () => ipcRenderer.send('expand'),
  collapse: () => ipcRenderer.send('collapse'),
  moveWindow: (deltaX, deltaY) => ipcRenderer.send('move-window', { deltaX, deltaY })
});
