import './styles.css'
import { openScreen } from "./style"
import "./vtkjs/index"

document.getElementById("btn-screenEditor").onclick = function() {openScreen('screenEditor')}
document.getElementById("btn-screenSeq").onclick = function() {openScreen('screenSeq')}
// document.getElementById("btn-screenVtk").onclick = function() {openScreen('screenVtk')}


 