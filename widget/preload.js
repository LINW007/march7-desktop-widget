const { contextBridge, ipcRenderer } = require('electron');

contextBridge.exposeInMainWorld('widgetAPI', {
  expand: () => ipcRenderer.send('expand'),
  collapse: () => ipcRenderer.send('collapse')
  // 拖拽由 -webkit-app-region: drag 原生处理，无需 IPC
});
