const { app, BrowserWindow, ipcMain, screen } = require('electron');
const path = require('path');

// 单实例锁：只允许运行一个窗口，重复启动则激活已有窗口
const gotTheLock = app.requestSingleInstanceLock();
if (!gotTheLock) {
  app.quit();
} else {
  app.on('second-instance', () => {
    if (mainWindow) {
      if (mainWindow.isMinimized()) mainWindow.restore();
      mainWindow.focus();
      mainWindow.show();
    }
  });
}

let mainWindow;

// 窗口尺寸
const COLLAPSED_SIZE = { width: 90, height: 90 };
const EXPANDED_SIZE = { width: 370, height: 540 };

function getWindowPosition() {
  const display = screen.getPrimaryDisplay();
  const { width, height } = display.workAreaSize;
  return {
    x: width - COLLAPSED_SIZE.width - 30,
    y: height - COLLAPSED_SIZE.height - 40
  };
}

function createWindow() {
  const pos = getWindowPosition();

  mainWindow = new BrowserWindow({
    x: pos.x,
    y: pos.y,
    width: COLLAPSED_SIZE.width,
    height: COLLAPSED_SIZE.height,
    frame: false,
    transparent: true,
    alwaysOnTop: true,
    resizable: false,
    hasShadow: false,
    skipTaskbar: false,
    focusable: true,
    acceptFirstMouse: true,
    webPreferences: {
      nodeIntegration: false,
      contextIsolation: true,
      preload: path.join(__dirname, 'preload.js')
    }
  });

  mainWindow.loadFile('todo-widget.html');

  // 确保鼠标事件不被穿透：设置窗口区域为不可穿透
  mainWindow.setIgnoreMouseEvents(false);
  // 监听窗口焦点变化，焦点丢失时重新确保鼠标事件
  mainWindow.on('blur', () => {
    if (mainWindow && !mainWindow.isDestroyed()) {
      mainWindow.setIgnoreMouseEvents(false);
    }
  });

  // 防止窗口被最小化时消失
  mainWindow.on('minimize', (e) => {
    e.preventDefault();
    mainWindow.show();
  });
}

// IPC: 展开窗口
ipcMain.on('expand', () => {
  if (!mainWindow) return;
  const display = screen.getPrimaryDisplay();
  const { width: sw, height: sh } = display.workAreaSize;

  const [currentX, currentY] = mainWindow.getPosition();

  // 新窗口位置（保持在屏幕内）
  let newX = currentX - (EXPANDED_SIZE.width - COLLAPSED_SIZE.width) / 2;
  let newY = currentY - (EXPANDED_SIZE.height - COLLAPSED_SIZE.height) / 2;
  newX = Math.max(10, Math.min(newX, sw - EXPANDED_SIZE.width - 10));
  newY = Math.max(10, Math.min(newY, sh - EXPANDED_SIZE.height - 10));

  mainWindow.setBounds({
    x: Math.round(newX),
    y: Math.round(newY),
    width: EXPANDED_SIZE.width,
    height: EXPANDED_SIZE.height
  }, true); // animate
});

// IPC: 收起窗口
ipcMain.on('collapse', () => {
  if (!mainWindow) return;

  const [currentX, currentY] = mainWindow.getPosition();

  // 新位置以当前窗口中心为基准
  let newX = currentX + (EXPANDED_SIZE.width - COLLAPSED_SIZE.width) / 2;
  let newY = currentY + (EXPANDED_SIZE.height - COLLAPSED_SIZE.height) / 2;

  mainWindow.setBounds({
    x: Math.round(newX),
    y: Math.round(newY),
    width: COLLAPSED_SIZE.width,
    height: COLLAPSED_SIZE.height
  }, true); // animate
});

app.whenReady().then(createWindow);

app.on('window-all-closed', () => {
  app.quit();
});

app.on('activate', () => {
  if (BrowserWindow.getAllWindows().length === 0) {
    createWindow();
  }
});
