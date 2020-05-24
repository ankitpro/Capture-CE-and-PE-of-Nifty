var ctx = document.getElementById("myChart").getContext("2d");
var csvData = {};
function getRandomColor() {
  var letters = "0123456789ABCDEF";
  var color = "#";
  for (var i = 0; i < 6; i++) {
    color += letters[Math.floor(Math.random() * 16)];
  }
  return color;
}

function handleFiles(files) {
  // Check for the various File API support.
  if (window.FileReader) {
    // FileReader are supported.
    var fileExtensions = document.querySelector("input[type='file']").accept;
    var fileName = files[0].name;
    var sFileNameExtns = fileName.split(".");
    var definedExtn = fileExtensions.includes(sFileNameExtns[sFileNameExtns.length-1]);
    if(definedExtn){
      getAsText(files[0]);
      document.getElementById("selected-file-name").textContent = fileName;
    }
    else{
      alert("Please select file with following extensions :" + fileExtensions);
      document.querySelector("input[type='file']").value = "";
    }
  } else {
    alert("FileReader are not supported in this browser.");
  }
}

function getAsText(fileToRead) {
  var reader = new FileReader();
  // Read file into memory as UTF-8
  reader.readAsText(fileToRead);
  // Handle errors load
  reader.onload = loadHandler;
  // reader.onerror = errorHandler;
}

function loadHandler(event) {
  // reading csv data
  var csv = event.target.result;
  // resetting input file to let user select same file again
  document.querySelector("input[type='file']").value = "";
  // parsing csv data into JSOn
  csvData = d3.csvParse(csv);
  // making all column headers selectable as xlabels
  var fields = Object.keys(csvData[0]);
  var xLabelsDropdown = fields.map(function(field){
    return "<option value='"+ field +"'>"+ field+"</option>";
  });

  document.getElementById("xLabels-select").innerHTML = xLabelsDropdown.join("");
  obtainChartData();
}

function obtainChartData() {
  var datasets = [];
  var dataHeaderMapping = {};
  var selectedXlabel = document.getElementById("xLabels-select").value;

  //createing a data mapping for values with respect to headers;
  csvData.map(function(row) {
    Object.keys(row).forEach(function(rowKey){
      dataHeaderMapping[rowKey] = dataHeaderMapping[rowKey] || [];
      dataHeaderMapping[rowKey].push(row[rowKey]);
      
    });
  });
  
  // creating dataset object and xlabels for plotting chart;
  Object.keys(dataHeaderMapping).forEach(function(key) {
    if(key !== selectedXlabel) {
      datasets.push({
        label: key,
        data: dataHeaderMapping[key],
        fill: false,
        backgroundColor: getRandomColor(),
        borderColor: getRandomColor(),
        borderWidth: 1,
      });
    }
  });
  var xlabels = dataHeaderMapping[selectedXlabel];

  plotChart({labels: xlabels, datasets});
}
 
function onXlabelsFieldSelect() {
  obtainChartData()
}

function plotChart(data) {
  new Chart(ctx, {
    type: "line",
    data,
    options: {
      scales: {
        yAxes: [
          {
            ticks: {
              beginAtZero: true,
            },
          },
        ],
      },
    },
  });
}
