const status = document.querySelector('#status');
const board = document.querySelector('#board');
const erase = document.querySelector('#erase');
const host = document.querySelector('#installer');
const supported = window.isSecureContext && 'serial' in navigator;
let loaded = false;
function render() {
  host.replaceChildren();
  if (!supported) { status.textContent = 'Open this HTTPS page in desktop Chrome or Edge on Mac or Windows to use USB installation.'; return; }
  if (!loaded) return;
  if (!board.checked || !erase.checked) { status.textContent = 'Confirm the board and full erase above to enable installation.'; return; }
  status.textContent = 'Ready. Choose the console’s USB serial port when your browser asks.';
  const installer = document.createElement('esp-web-install-button');
  installer.setAttribute('manifest', './manifest.json');
  const button = document.createElement('button');
  button.slot = 'activate'; button.textContent = 'Connect & install';
  installer.append(button); host.append(installer);
}
board.addEventListener('change', render); erase.addEventListener('change', render);
if (supported) {
  status.textContent = 'Loading USB installer…';
  import('./vendor/esp-web-tools-10.1.1/install-button.js').then(() => {
    loaded = true; render();
  }).catch(() => { status.textContent = 'The USB installer could not load. Reload the page or try again later. No console changes were made.'; });
} else render();
