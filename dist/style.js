// Sequence Editor Menu Bar -----------------------------------------
function openDropDownMenu(id){
    closeAllDropDownMenu();
    var content = document.getElementById(id);
    content.style.display = "block";
}

function closeAllDropDownMenu(){
    var dropdowns = document.getElementsByClassName("dropdown-content");
    var i;
    for (i = 0; i < dropdowns.length; i++) {
        dropdowns[i].style.display = "none";
    }
}

function isMenuOpened() {
    var dropdowns = document.getElementsByClassName("dropdown-content");
    var i;
    for (i = 0; i < dropdowns.length; i++) {
        if(dropdowns[i].style.display == "block"){
            return true;
        }
    }
    return false;
}

function menuHovered(id){
    if (isMenuOpened()){
        openDropDownMenu(id);
    }
}

// Close the dropdown if the user clicks outside of it
window.onclick = function(event) {
    if (!event.target.matches('.dropbtn')) {
        closeAllDropDownMenu();
    }
}

// -----------------------------------------------------------------------



// Responsive Wasm window size
function wasmInitSize() {
    var div = document.getElementById('screenWasm');
    manageWasmHeight(div);
}

window.addEventListener('resize', function() {
    var divWasm = document.getElementById('screenWasm');
    manageWasmHeight(divWasm);
  });


function manageWasmHeight(div){
var divWidth = div.offsetWidth; // Ancho actual del div
    if (divWidth >= 1100) {  
            div.style.height = '470px'; 
    } else if (divWidth >= 660){
        div.style.height = '630px';    
    } else {
        div.style.height = '710px';
    }
}


function loadSequence(){
    document.getElementById('my_file').click();
}



