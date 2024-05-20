import * as css from "./styles.css";
import * as utils from "./utils";
import { openScreen, initTabs } from "./style"


import "@kitware/vtk.js/Rendering/Profiles/All"
import vtkGenericRenderWindow from "@kitware/vtk.js/Rendering/Misc/GenericRenderWindow"
import "@kitware/vtk.js/IO/Core/DataAccessHelper/HttpDataAccessHelper"
import DataAccessHelper from "@kitware/vtk.js/IO/Core/DataAccessHelper"
import { niftiReadImage } from "@itk-wasm/image-io"
import vtkITKHelper from "@kitware/vtk.js/Common/DataModel/ITKHelper"
import vtkImageSlice from "@kitware/vtk.js/Rendering/Core/ImageSlice"
import vtkInteractorStyleImage from "@kitware/vtk.js/Interaction/Style/InteractorStyleImage"
import vtkImageResliceMapper from "@kitware/vtk.js/Rendering/Core/ImageResliceMapper"
import vtkPlane from "@kitware/vtk.js/Common/DataModel/Plane"
import { SlabTypes } from "@kitware/vtk.js/Rendering/Core/ImageResliceMapper/Constants"
import vtkImplicitPlaneRepresentation from '@kitware/vtk.js/Widgets/Representations/ImplicitPlaneRepresentation';

const niftiFile = "cadera.nii.gz"
const niftiUrl = `../public/${niftiFile}`

let imageData
let renderer3d
let renderWindow3d

let planeNormal = [0, 0, -1]
let planeCenter = [0, 0, 0]

function setup() {
  const genericRenderer3d = vtkGenericRenderWindow.newInstance({
    background: [ 0.129,
                  0.145,
                  0.161] 
  })
  genericRenderer3d.setContainer(document.querySelector("#screenVtk"))
  genericRenderer3d.resize()
  renderer3d = genericRenderer3d.getRenderer()
  renderWindow3d = genericRenderer3d.getRenderWindow()
}

async function loadNifti() {
  const dataAccessHelper = DataAccessHelper.get("http")
  // @ts-ignore - bad typings
  const niftiArrayBuffer = await dataAccessHelper.fetchBinary(niftiUrl)
  const { image: itkImage, webWorker } = await niftiReadImage({
    data: new Uint8Array(niftiArrayBuffer),
    // tienes que darle el nombre del archivo, no sé muy bien por qué
    path: niftiFile
  })
  webWorker.terminate()
  // convertir formato itk a vtk
  imageData = vtkITKHelper.convertItkToVtkImage(itkImage)
}

// i, j, k planes
const iPlane = vtkPlane.newInstance()
const jPlane = vtkPlane.newInstance()
const kPlane = vtkPlane.newInstance()
iPlane.setNormal([1, 0, 0])
jPlane.setNormal([0, 1, 0])
kPlane.setNormal([0, 0, 1])
const iMapper = vtkImageResliceMapper.newInstance()
const jMapper = vtkImageResliceMapper.newInstance()
const kMapper = vtkImageResliceMapper.newInstance()
const iActor3d = vtkImageSlice.newInstance()
const jActor3d = vtkImageSlice.newInstance()
const kActor3d = vtkImageSlice.newInstance()

// Selected plane
const slicePlane = vtkPlane.newInstance()
slicePlane.setNormal(planeNormal)
const resliceActor = vtkImageSlice.newInstance()
const resliceMapper = vtkImageResliceMapper.newInstance()
const resliceActor3d = vtkImageSlice.newInstance()

// Outline (vtkImplicitPlaneRepresentation)
const representation = vtkImplicitPlaneRepresentation.newInstance();
const state = vtkImplicitPlaneRepresentation.generateState();
slicePlane.setNormal(planeNormal);

function addReslicerToRenderer() {
  planeCenter = imageData.getCenter()

  // i, j, k planes
  iPlane.setOrigin(planeCenter)
  jPlane.setOrigin(planeCenter)
  kPlane.setOrigin(planeCenter)

  iMapper.setSlabType(SlabTypes.MEAN)
  jMapper.setSlabType(SlabTypes.MEAN)
  kMapper.setSlabType(SlabTypes.MEAN)

  iMapper.setSlabThickness(1)
  jMapper.setSlabThickness(1)
  kMapper.setSlabThickness(1)

  iMapper.setSlicePlane(iPlane)
  jMapper.setSlicePlane(jPlane)
  kMapper.setSlicePlane(kPlane)

  iMapper.setInputData(imageData)
  jMapper.setInputData(imageData)
  kMapper.setInputData(imageData)

  iActor3d.setMapper(iMapper)
  jActor3d.setMapper(jMapper)
  kActor3d.setMapper(kMapper)

  renderer3d.addActor(iActor3d)
  renderer3d.addActor(jActor3d)
  renderer3d.addActor(kActor3d)
  

  // Selected plane
  slicePlane.setOrigin(planeCenter)

  resliceMapper.setSlabType(SlabTypes.MEAN)
  resliceMapper.setSlabThickness(1)
  resliceMapper.setSlicePlane(slicePlane)

  resliceMapper.setInputData(imageData)
  resliceActor.setMapper(resliceMapper)
  resliceActor3d.setMapper(resliceMapper)

  renderer3d.addActor(resliceActor3d)

  const bounds = imageData.getBounds()
  state.setOrigin(planeCenter)
  state.placeWidget(bounds);
  representation.setInputData(state);
  representation.getActors().forEach(renderer3d.addActor);
  
  renderer3d.resetCamera()
  renderer3d.resetCameraClippingRange()
}

function updateCameraBounds() {
  // si quieres que la cámara se ajuste a los límites de la imagen
  // por defecto se ajusta a la esfera que contiene todos los puntos
  const bounds = imageData.getBounds()
  const parallelScale = (bounds[3] - bounds[2]) / 2
  renderWindow3d.render()
}

async function main() {
  initTabs()

  setup()
  await loadNifti()
  addReslicerToRenderer()
  updateCameraBounds()

  document.getElementById("btn-screenEditor").onclick = function() {openScreen('screenEditor')}
  document.getElementById("btn-screenSeq").onclick = function() {openScreen('screenSeq')}
  document.getElementById("btn-screenVtk").onclick = function() {openScreen('screenVtk')}
}

main()

