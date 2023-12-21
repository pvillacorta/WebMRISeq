import '@kitware/vtk.js/favicon';

// Load the rendering pieces we want to use (for both WebGL and WebGPU)
import '@kitware/vtk.js/Rendering/Profiles/Volume';

// Force DataAccessHelper to have access to various data source
import '@kitware/vtk.js/IO/Core/DataAccessHelper/HtmlDataAccessHelper';
import '@kitware/vtk.js/IO/Core/DataAccessHelper/HttpDataAccessHelper';
import '@kitware/vtk.js/IO/Core/DataAccessHelper/JSZipDataAccessHelper';

import vtkFullScreenRenderWindow from '@kitware/vtk.js/Rendering/Misc/FullScreenRenderWindow';
import vtkRenderWindow from '@kitware/vtk.js/Rendering/Core/RenderWindow';
import vtkHttpDataSetReader from '@kitware/vtk.js/IO/Core/HttpDataSetReader';
import vtkImageMapper from '@kitware/vtk.js/Rendering/Core/ImageMapper';
import vtkImageSlice from '@kitware/vtk.js/Rendering/Core/ImageSlice';
import vtkOpenGLRenderWindow from '@kitware/vtk.js/Rendering/OpenGL/RenderWindow';
import vtkRenderWindowInteractor from '@kitware/vtk.js/Rendering/Core/RenderWindowInteractor';
import vtkRenderer from '@kitware/vtk.js/Rendering/Core/Renderer';
import vtkInteractorStyleTrackballCamera from '@kitware/vtk.js/Interaction/Style/InteractorStyleTrackballCamera';

import controlPanel from './controlPanel.html';

// const fullScreenRenderWindow = vtkFullScreenRenderWindow.newInstance({
//   background: [0, 0, 0],
// });
// const renderWindow = fullScreenRenderWindow.getRenderWindow();
// const renderer = fullScreenRenderWindow.getRenderer();
// fullScreenRenderWindow.addController(controlPanel);

const renderWindow = vtkRenderWindow.newInstance();
const renderer = vtkRenderer.newInstance({ background: [0.2, 0.3, 0.4] });
renderWindow.addRenderer(renderer);
// renderWindow.addController(controlPanel);

const imageActorI = vtkImageSlice.newInstance();
const imageActorJ = vtkImageSlice.newInstance();
const imageActorK = vtkImageSlice.newInstance();

renderer.addActor(imageActorK);
renderer.addActor(imageActorJ);
renderer.addActor(imageActorI);
renderer.resetCamera();

const openGLRenderWindow = vtkOpenGLRenderWindow.newInstance();
renderWindow.addView(openGLRenderWindow);

const container = document.getElementById("prueba");
openGLRenderWindow.setContainer(container);

const { width, height } = container.getBoundingClientRect();
openGLRenderWindow.setSize(width, height);

const interactor = vtkRenderWindowInteractor.newInstance();
interactor.setView(openGLRenderWindow);
interactor.initialize();
interactor.bindEvents(container);

interactor.setInteractorStyle(vtkInteractorStyleTrackballCamera.newInstance());

// function updateColorLevel(e) {
//   const colorLevel = Number(
//     (e ? e.target : document.querySelector('.colorLevel')).value
//   );
//   imageActorI.getProperty().setColorLevel(colorLevel);
//   imageActorJ.getProperty().setColorLevel(colorLevel);
//   imageActorK.getProperty().setColorLevel(colorLevel);
//   renderWindow.render();
// }

// function updateColorWindow(e) {
//   const colorLevel = Number(
//     (e ? e.target : document.querySelector('.colorWindow')).value
//   );
//   imageActorI.getProperty().setColorWindow(colorLevel);
//   imageActorJ.getProperty().setColorWindow(colorLevel);
//   imageActorK.getProperty().setColorWindow(colorLevel);
//   renderWindow.render();
// }

const reader = vtkHttpDataSetReader.newInstance({fetchGzip: true});
reader
  .setUrl(`http://localhost:8080/data/volume/headsq.vti`, { loadData: true })
  .then(() => {
    const data = reader.getOutputData();
    const dataRange = data.getPointData().getScalars().getRange();
    const extent = data.getExtent();

    console.log(dataRange)

    const imageMapperK = vtkImageMapper.newInstance();
    imageMapperK.setInputData(data);
    imageMapperK.setKSlice((extent[2 * 2 + 1]-extent[2 * 2 + 0])/2);
    imageActorK.setMapper(imageMapperK);

    const imageMapperJ = vtkImageMapper.newInstance();
    imageMapperJ.setInputData(data);
    imageMapperJ.setJSlice((extent[1 * 2 + 1]-extent[1 * 2 + 0])/2);
    imageActorJ.setMapper(imageMapperJ);

    const imageMapperI = vtkImageMapper.newInstance();
    imageMapperI.setInputData(data);
    imageMapperI.setISlice((extent[0 * 2 + 1]-extent[0 * 2 + 0])/2);
    imageActorI.setMapper(imageMapperI);

    renderer.resetCamera();
    renderer.resetCameraClippingRange();
    renderWindow.render();

    // ['.sliceI', '.sliceJ', '.sliceK'].forEach((selector, idx) => {
    //   const el = document.querySelector(selector);
    //   el.setAttribute('min', extent[idx * 2 + 0]);
    //   el.setAttribute('max', extent[idx * 2 + 1]);
    //   el.setAttribute('value', (el.getAttribute('max')-el.getAttribute('min'))/2);
    // });

    // ['.colorLevel', '.colorWindow'].forEach((selector) => {
    //   document.querySelector(selector).setAttribute('max', dataRange[1]);
    //   document.querySelector(selector).setAttribute('value', dataRange[1]);
    // });
    // document
    //   .querySelector('.colorLevel')
    //   .setAttribute('value', (dataRange[0] + dataRange[1]) / 2);
    // updateColorLevel();
    // updateColorWindow();
  });

// document.querySelector('.sliceI').addEventListener('input', (e) => {
//   imageActorI.getMapper().setISlice(Number(e.target.value));
//   renderWindow.render();
// });

// document.querySelector('.sliceJ').addEventListener('input', (e) => {
//   imageActorJ.getMapper().setJSlice(Number(e.target.value));
//   renderWindow.render();
// });

// document.querySelector('.sliceK').addEventListener('input', (e) => {
//   imageActorK.getMapper().setKSlice(Number(e.target.value));
//   renderWindow.render();
// });

// document
//   .querySelector('.colorLevel')
//   .addEventListener('input', updateColorLevel);
// document
//   .querySelector('.colorWindow')
//   .addEventListener('input', updateColorWindow);

// global.fullScreen = fullScreenRenderWindow;
global.imageActorI = imageActorI;
global.imageActorJ = imageActorJ;
global.imageActorK = imageActorK;