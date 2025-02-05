
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
    if (window.innerWidth > 1300 && window.innerHeight > 680) {
        // Si es escritorio, mostrar los divs
        var tabs = document.getElementsByClassName("box");
        for (var i = 0; i < tabs.length; i++) {
            tabs[i].style.display = "block";
        }
        document.querySelector(".tabs-mobile").style.display = "none";
    } else {
        document.querySelector(".tabs-mobile").style.display = "block";
        // Agrega la clase 'tab-active' al botón/tab activo
        document.getElementById("btn-" + "screenEditor").classList.add("tab-active");
    }
}

function initTabs(){
    if (window.innerWidth > 1300 && window.innerHeight > 680) {
        // Si es escritorio, mostrar los divs
        var tabs = document.getElementsByClassName("box");
        for (var i = 0; i < tabs.length; i++) {
          tabs[i].style.display = "block";
        }
        document.querySelector(".tabs-mobile").style.display = "none";
    } else {
        // Si es móvil, ocultar los divs y mostrar las pestañas
        document.querySelector(".tabs-mobile").style.display = "block";
        // Agrega la clase 'tab-active' al botón/tab activo
        document.getElementById("btn-" + "screenEditor").classList.add("tab-active");
    }
}

// Manejar el cambio de tamaño de pantalla
window.addEventListener("resize", handleResize);

// Disable long-press text selection inside wasm View
function absorbEvent(event) {
    event.returnValue = false;
}
  
let div1 = document.querySelector("#screenEditor");
div1.addEventListener("touchstart", absorbEvent);
div1.addEventListener("touchend", absorbEvent);
div1.addEventListener("touchmove", absorbEvent);
div1.addEventListener("touchcancel", absorbEvent);

export { openScreen, initTabs }
