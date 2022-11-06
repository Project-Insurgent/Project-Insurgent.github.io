var loadTab = function(url){
	window.open(url, 'mainTab');
	iFrameResize({log: true }, "#mainTabs");
	setTimeout(function(){document.getElementById("mainTabs").style.display = "inline";},200);
};


window.onload = function(){
	var elements = document.getElementsByClassName("mainButton");
	for(var i = 0; i < elements.length; i++){
		elements[i].addEventListener("click",vanishCurrentTab);
		elements[i].addEventListener("mouseover",mouseDown);
		elements[i].addEventListener("mouseout",mouseUp);
	};

	var vanishables = document.getElementsByClassName("vanishable");
	for(var k = 0; k < vanishables.length; k++){ vanishables[k].style.opacity = 1; };
	//document.getElementById("mainTabs").addEventListener("load",loadTab("mainTab.html"));
};

var frames   = 30;
var currentType = "";
var vanishCurrentTab = function(){
	var curType = currentType;
	var vanishable = document.getElementsByClassName("vanishable");
	var i = 0;
	var opacity = 1.0;
	var myInterval = setInterval(function(){
		if (i == frames){ 
			for(var k = 0; k < vanishable.length; k++){ vanishable[k].remove(); }
			readJsonMethod(curType);
			appearCurrentTab();
			clearInterval(myInterval);
		}
		else{
			opacity -= 1.0/frames;
			for(var k = 0; k < vanishable.length; k++){ vanishable[k].style.opacity = opacity; }
			i++;
		}
	},10);
};

var appearCurrentTab = function(){
	var vanishables = document.getElementsByClassName("vanishable");
	for(var i = 0; i < vanishables.length; i++){ vanishables[i].style.display = "block"; }
	var i = 0;
	var opacity = 0.0;
	var myInterval = setInterval(function(){
		if (i == frames){ clearInterval(myInterval); }
		else{
			opacity += 1.0/frames;
			for(var k = 0; k < vanishables.length; k++){ vanishables[k].style.opacity = opacity; }
			i++;
		}
	},10);
};

var readJsonMethod = function(section){
	fetch("metadata/"+section+".json")
		.then(results => results.json())
		.then(function(data){
			console.log(data.toString());
			for (var i = 0; i < data.length; i++){
				if (i % 2 == 0){ createRow(Math.floor(i/2)); }
				createItemBox(section,data[i],Math.floor(i/2).toString());
			}
		}
	);
};

function createRow(id){
	var row = document.createElement("div");
	row.id = "resourceRow"+id.toString();
	row.className += "row vanishable";
	//row.style.display = "block";
	document.getElementsByClassName("mainContainer")[0].append(row);
};

/*//v2:
    <div class="col col-md-6">
		<div class="resourcePanel">
            <div class="row">
                <div class="col-md-offset-1 col-xs-3 col-xs-offset-1">
                    <img class="resourceIcon" width="100%" src="./img/scripts/default.png">
                </div>
                <div class="col-md-9 col-xs-8">
					<div class="col-xs-12"> Somersault Utilities Script </div>
					<div class="col-xs-12 subtitle"> qwertytrewqwerty </div>
				</div>
            </div>
            <div class="row descField">
                <div class="col-xs-11 col-xs-offset-1">This is just a script with lots of different things to be done.</div>
            </div>
        </div>
	</div>*/
function createItemBox(section,data,rowId){
	console.log(data);
	var container = document.createElement("div");
	container.className += "col col-md-6";
	
	var box = document.createElement("button");
	box.className += "resourcePanel";
	box.id = data["ID"];
	box.addEventListener("mouseover",mouseDown);
	box.addEventListener("mouseout",mouseUp);
	
	var titleRow = document.createElement("div");
	titleRow.className += "row titleRow";
	titleRow.id = "titleRow"+rowId;
		
	var iconCol = document.createElement("div");
	iconCol.className += "col-md-2 col-md-offset-1 col-xs-3 col-xs-offset-1 resourceCol";
	iconCol.id = "iconCol"+rowId;
	
	var icon = document.createElement("img");
	var iconName = data["icon"] == "default" ? data["icon"]+".png" : data["ID"]+"/"+data["icon"]
	icon.className += "resourceIcon";
	icon.src = "img/"+section+"/"+iconName;
	icon.id = "icon"+rowId;
	
	var titleCol = document.createElement("div");
	titleCol.className += "col-md-8 col-xs-8";
	titleCol.id = "titleCol"+rowId;
	
	var title = document.createElement("div");
	title.className += "col-xs-12";
	title.id = "title"+rowId;
	title.innerHTML += data["name"];
	
	var subtitle = document.createElement("div");
	subtitle.className += "col-xs-12 subtitle";
	subtitle.id = "subtitle"+rowId;
	subtitle.innerHTML += data["subtitle"];
	
	//=================================================
	
	var descRow = document.createElement("div");
	descRow.className += "row descField";
	descRow.id = "descRow"+rowId;
	
	var descCol = document.createElement("div");
	descCol.className += "col-xs-10 col-xs-offset-1";
	descCol.id = "dataCol"+rowId;
	descCol.innerHTML += data["desc"];
	descCol.id = "desc"+rowId;
	
	container.append(box);
	box.append(titleRow);
	box.append(descRow);
	titleRow.append(iconCol);
	titleRow.append(titleCol);
	titleCol.append(title);
	titleCol.append(subtitle);
	iconCol.append(icon);
	descRow.append(descCol);

	document.getElementById("resourceRow"+rowId).append(container);
	//container.addEventListener("click",loadTab("../detailsTab.html"));
};

var moveY = 5;
var posY = 10;
var mouseDown = function() {
	this.style["background-color"]="rgba(231,199,110,1.00)";
	this.style["box-shadow"] = "0px 5px 5px rgba(20,20,20,0.4)";
	this.style["border-style"] = "solid";
	currentType = this.id;
	//this.style.top = posY; highlightable
	var elem = document.getElementById(this.id);
	elem.getElementsByClassName("mainBtnIcon")[0].style.display = "inline";
	if (screen.width <= 767){ elem.getElementsByTagName("p")[0].style.display = "none"; }
};

var mouseUp = function() {
	this.style["background-color"]="rgba(208,175,83,1.00)";
	this.style["box-shadow"] = "0px 0px 0px rgba(0,0,0,0)";
	this.style["border-style"] = "none";
	//this.style.top = posY-moveY;
	
	var elem = document.getElementById(this.id);
	elem.getElementsByClassName("mainBtnIcon")[0].style.display = "none";
	elem.getElementsByTagName("p")[0].style.display = "inline";
};

//python -m http.server 8000 -b [ip]