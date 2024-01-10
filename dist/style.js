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



// ---------------------- Mobile tabs handling ----------------------------
function openScreen(screenId) {
    // Oculta todos los divs
    var tabs = document.getElementsByClassName("box");
    for (var i = 0; i < tabs.length; i++) {
      tabs[i].style.display = "none";
    }
  
    // Muestra el div seleccionado
    document.getElementById(screenId).style.display = "table";
}

// Función para manejar el cambio de tamaño de pantalla
function handleResize() {
    if (window.innerWidth > 1275) {
      // Si es escritorio, mostrar los divs
      var tabs = document.getElementsByClassName("box");
      for (var i = 0; i < tabs.length; i++) {
        tabs[i].style.display = "table";
      }
      document.querySelector(".tabs-mobile").style.display = "none";
    } else {
      // Si es móvil, ocultar los divs y mostrar las pestañas
      var tabs = document.getElementsByClassName("box");
      for (var i = 0; i < tabs.length; i++) {
        tabs[i].style.display = "none";
      }
      document.getElementById("screenEditor").style.display = "table";
      document.querySelector(".tabs-mobile").style.display = "block";
    }
}

// Manejar el cambio de tamaño de pantalla
window.addEventListener("resize", handleResize);

// Llamar a la función al cargar la página para establecer el estado inicial
handleResize();

function loadSequence(){
    document.getElementById('my_file').click();
}

