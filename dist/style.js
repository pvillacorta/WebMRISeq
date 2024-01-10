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
    document.getElementById(screenId).style.display = "block";

    // Elimina la clase 'tab-active' de todos los botones
    var buttons = document.querySelectorAll(".tabs-mobile button");
    for (var i = 0; i < buttons.length; i++) {
        buttons[i].classList.remove("tab-active");
    }
    // Agrega la clase 'tab-active' al botón/tab activo
    document.getElementById("btn-" + screenId).classList.add("tab-active");
}

// Función para manejar el cambio de tamaño de pantalla
function handleResize() {
    if (window.innerWidth > 1275) {
      // Si es escritorio, mostrar los divs
      var tabs = document.getElementsByClassName("box");
      for (var i = 0; i < tabs.length; i++) {
        tabs[i].style.display = "block";
      }
      document.querySelector(".tabs-mobile").style.display = "none";
    } else {
    //   // Si es móvil, ocultar los divs y mostrar las pestañas
    //   var tabs = document.getElementsByClassName("box");
    //   for (var i = 0; i < tabs.length; i++) {
    //     tabs[i].style.display = "none";
    //   }

        document.querySelector(".tabs-mobile").style.display = "block";
    }
}

// Manejar el cambio de tamaño de pantalla
window.addEventListener("resize", handleResize);

// Llamar a la función al cargar la página para establecer el estado inicial
// handleResize();

function loadSequence(){
    document.getElementById('my_file').click();
}

