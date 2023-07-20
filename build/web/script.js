function updateOrientation(gyroX, gyroY, gyroZ) {
    const modelViewerTransform = document.querySelector("model-viewer#transform");
    modelViewerTransform.orientation = `${gyroX} ${gyroY} ${gyroZ}`;
    modelViewerTransform.updateFraming();  
}