function komaMRISim(){
    var phantom = document.getElementById("phantom");
    canvas.height = 0; canvas.width = 0;

    // Input parameters: mat (-> Sequence) & vec (-> Scanner)
    // This parameters will come from the sequence editor (GUI) in future versions
    var mat  = [[1,        2,      5],           // cod
                [1e-3,  0.01,      0],           // dur
                [0,        0,      0],           // gx
                [0,        0,      0],           // gy
                [1,        0,      0],           // gz
                [10e-6,    0,      0],           // b1x
                [0,        0,      0],           // b1y
                [0,        0,      0],           // Δf
                [0,        0,      0.25],         // fov
                [0,        0,      201]];        // n

    var vec  =  [1.5,          //B0
                 10e-6,        //B1
                 2e-6,         //Delta_t
                 60e-3,        //Gmax
                 500];         // Smax

    var params = {
        phantom: phantom.value,
        mat: mat,
        vec: vec
    }

    // HTTP Status Codes:
    // 200: OK
    // 202: Accepted
    // 303: See other

    document.getElementById("simButton").disabled = true;

    fetch("/simulate",{
        method: "POST",
        headers:{
            "Content-type": "application/json",
        },
        body: JSON.stringify(params)})
    .then(res => {
            if ((res.status == 202) && (loc = res.headers.get('location'))){
                requestResult(loc)
            }else{
                // Error
            }
        }
    )
}


function requestResult(loc){
    fetch(loc)
        .then(res => {
            if(res.redirected){
            // Redirected indica que la respuesta es fruto de una redirección.
            // Esto quiere decir que el cliente ha recibido un 303 y ha hecho
            // automáticamente la petición a simulate/{simulationId}/status
                document.getElementById('response').style.visibility = "visible";
                res.json()
                .then(json => {
                    if(json == -1){
                        document.getElementById('response').innerHTML = "Starting simulation...";
                    } else {
                        // Status Bar
                        document.getElementById('response').innerHTML = json + "%";

                        document.getElementById('myProgress').style.visibility = "visible";
                        var elem = document.getElementById("myBar");
                        elem.style.width = json + "%";
                    }
                    if(json<100){
                        setTimeout(requestResult(loc),500);
                    } else if (json == 100) {
                        // Status Bar
                        document.getElementById('response').innerHTML = "Reconstructing...";
                        document.getElementById('myProgress').style.visibility = "collapse";
                        setTimeout(requestResult(loc),500);
                    }
                })
            }else{
            // Aquí estaríamos obteniendo el resultado de la simulación
            // El cliente ha recibido un 200 como respuesta al GET simulate/{simulationId}
                let image = []
                res.json()
                .then(json => json.data)
                .then(function(array){
                    N = Math.sqrt(array.length); // Suponemos imágenes cuadradas

                    var canvas = document.getElementById( 'canvas' );
                    canvas.height = N; canvas.width = N;
                    var context = canvas.getContext( '2d' );

                    var imgArray = []
                    for (var i = 0; i < array.length; i++){
                        imgArray[4*i] = array[i];
                        imgArray[4*i+1] = array[i];
                        imgArray[4*i+2] = array[i];
                        imgArray[4*i+3] = 255;
                    }

                    document.getElementById('response').style.visibility = "collapse";

                    document.getElementById('myProgress').style.visibility = "collapse";
                    document.getElementById("myBar").style.width = 0 + "%";

                    const imgData = new ImageData(Uint8ClampedArray.from(imgArray), N, N);
                    context.putImageData(imgData, 0, 0);

                    document.getElementById("simButton").disabled = false;
                })
            }
        })
}


function plot_selected_seq(){
    openFile(function (seq_json) {
        console.log('File content:', seq_json);
        plot_seq(seq_json);
    });
}

function plot_seq(scanner_json, seq_json){
    const scannerObj = JSON.parse(scanner_json);
    const seqObj     = JSON.parse(seq_json);

    // Combina los dos objetos en uno solo
    const combinedObj = {
        scanner: scannerObj,
        sequence: seqObj
    };

    fetch("/plot", {
        method: "POST",
        headers: {
            "Content-type": "application/json",
        },
        body: JSON.stringify(combinedObj)
    })
    .then(res => {
        if (res.ok) {
            return res.text();
        } else {
            throw new Error('Error en la solicitud');
        }
    })
    .then(html => {
        // Establecer el contenido del iframe con el HTML recibido
        var iframe = document.getElementById("seq-diagram")
        iframe.srcdoc = html;
        iframe.style.visibility = "visible";
    })
    .catch(error => {
        console.error("Error en la solicitud:", error);
    });
}


function openFile(callback){
    // Get the file input element
    var fileInput = document.getElementById('fileInput');

    // Check if any file is selected
    if (fileInput.files.length > 0) {
        // Get the selected file
        var selectedFile = fileInput.files[0];

        // Create a new FileReader
        var reader = new FileReader();

        // Set up the FileReader to handle the file content
        reader.onload = function (e) {
            // e.target.result contains the file content
            var fileContent = e.target.result;
            // console.log('File content:', fileContent);
            callback(fileContent); ;

            // You can now do something with the file content, such as display it on the page or process it further.
        };

        // Read the file as text
        reader.readAsText(selectedFile);
    } else {
        console.log('No file selected.');
        return 0;
    }
}
