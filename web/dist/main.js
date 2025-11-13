"use strict";
var img = document.getElementById('frame');
var fpsEl = document.getElementById('fps');
var resEl = document.getElementById('res');
var last = performance.now();
var frameCount = 0;
function update() {
    frameCount++;
    var now = performance.now();
    if (now - last >= 1000) {
        fpsEl.textContent = String(frameCount);
        frameCount = 0;
        last = now;
        if (img.naturalWidth && img.naturalHeight) {
            resEl.textContent = "".concat(img.naturalWidth, "x").concat(img.naturalHeight);
        }
    }
    requestAnimationFrame(update);
}
img.onload = function () {
    // start FPS counter
    requestAnimationFrame(update);
};