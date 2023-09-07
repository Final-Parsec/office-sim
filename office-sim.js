main();

function main() {
  const canvas = document.querySelector("#glcanvas");
  const canvasContext = canvas.getContext("webgl");

  if (canvasContext == null) {
    alert("Unable to initialize WebGL.");
    return;
  }

  canvasContext.clearColor(0.0, 0.0, 0.0, 1.0);
  canvasContext.clear(canvasContext.COLOR_BUFFER_BIT);

  let boxSize = 100;
  canvasContext.viewport(0, 0, canvasContext.drawingBufferWidth, canvasContext.drawingBufferHeight);
  canvasContext.enable(canvasContext.SCISSOR_TEST);
  let x = canvasContext.drawingBufferWidth / 2 - boxSize / 2;
  let y = canvasContext.drawingBufferHeight / 2 - boxSize / 2;
  canvasContext.scissor(x, y, boxSize, boxSize);
  canvasContext.clearColor(1.0, 0.0, 0.0, 1.0);
  canvasContext.clear(canvasContext.COLOR_BUFFER_BIT);
}