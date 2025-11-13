const img = document.getElementById('frame') as HTMLImageElement;
const fpsEl = document.getElementById('fps') as HTMLElement;
const resEl = document.getElementById('res') as HTMLElement;

let last = performance.now();
let frameCount = 0;

function update() {
  frameCount++;
  const now = performance.now();
  if (now - last >= 1000) {
    fpsEl.textContent = String(frameCount);
    frameCount = 0;
    last = now;
    if (img.naturalWidth && img.naturalHeight) {
      resEl.textContent = `${img.naturalWidth}x${img.naturalHeight}`;
    }
  }
  requestAnimationFrame(update);
}

img.onload = () => {
  // start FPS counter
  requestAnimationFrame(update);
};