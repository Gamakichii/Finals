console.log('MV3 Hello service worker started');
self.addEventListener('install', () => {
  console.log('MV3 Hello installed');
});
self.addEventListener('activate', () => {
  console.log('MV3 Hello activated');
});
