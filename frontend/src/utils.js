function komaMRIsim(phantom, seq_json, scanner_json){

    const scannerObj = JSON.parse(scanner_json);
    const seqObj     = JSON.parse(seq_json);

    var params = {
        phantom: phantom,
        sequence: seqObj,
        scanner: scannerObj
    }

    document.getElementById('sim-result').style.visibility  = "hidden";

    // HTTP Status Codes:
    // 200: OK
    // 202: Accepted
    // 303: See other

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
    fetch(loc + "?" + new URLSearchParams({
        width:  document.getElementById("sim-result").offsetWidth,
        height: document.getElementById("sim-result").offsetHeight
    }).toString())
    .then(res => {
        if (res.redirected) {
            // Caso en que se recibe un 303 (redirect)
            document.getElementById("simProgress").style.visibility = "visible";
            document.getElementById('response').style.visibility    = "visible";
            
            return res.json().then(json => {
                if (json === -1) {
                    document.getElementById('response').innerHTML = "Starting simulation...";
                } else {
                    // Status Bar
                    document.getElementById('response').innerHTML = json + "%";
                    document.getElementById('myProgress').style.visibility = "visible";
                    var elem = document.getElementById("myBar");
                    elem.style.width = json + "%";
                }
                if (json < 100) {
                    setTimeout(function() { requestResult(loc); }, 500);
                } else if (json === 100) {
                    // Status Bar
                    document.getElementById('response').innerHTML = "Reconstructing...";
                    document.getElementById('myProgress').style.visibility = "collapse";
                    setTimeout(function() { requestResult(loc); }, 500);
                }
            }).then(() => { return; });  // 🔹 IMPORTANTE: Evita que el flujo siga al siguiente .then()
        } 
        if (res.ok) {
            document.getElementById("simProgress").style.visibility = "collapse";
            document.getElementById('response').style.visibility    = "collapse";
            document.getElementById('myProgress').style.visibility  = "collapse";
            document.getElementById("myBar").style.width            = "0%";
            return res.text();
        }      
        throw new Error('Request error');
    })
    .then(html => {
        if (!html) return;
        var iframe = document.getElementById("sim-result")
        iframe.srcdoc = html;
        iframe.onload = function() {
            iframe.style.visibility = "visible";
        };
    })
    .catch(error => {
        console.error("Error in the request:", error);
    });   
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
        sequence: seqObj,
        height: document.getElementById("seq-diagram").offsetHeight,
        width: document.getElementById("seq-diagram").offsetWidth,
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
