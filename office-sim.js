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
}