var types = ["scripts","sprites","fangames"]
window.onload = function(){
	var elements = document.getElementsByClassName("mainButton");
	for(var i = 0; i < elements.length; i++){
		elements[i].addEventListener("mouseover",mouseDown);
		elements[i].addEventListener("mouseout",mouseUp);
		elements[i].addEventListener("click",vanishCurrentTab(types[i]));
	};
};

var frames   = 50;
var vanishCurrentTab = function(section){
	var vanishable = document.getElementsByClassName("vanishable");
	var i = 0;
	var opacity = 1.0;
	var myInterval = setInterval(function(){
		if (i == frames){ 
			for(var k = 0; k < vanishable.length; k++){ vanishable[k].remove(); }//style.display = "none"; }
			readJsonMethod(section)
			clearInterval(myInterval);
		}
		else{
			opacity -= 1.0/frames;
			for(var k = 0; k < vanishable.length; k++){ vanishable[k].style.opacity = opacity; }
			i++;
		}
	},10);
};

var readJsonMethod = function(section){
	fetch("metadata/"+section+".json")
		.then(results => results.json())
		.then(function(data){
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
	row.className = "row vanishable";
	document.getElementsByClassName("mainContainer")[0].append(row);
};

/*
<div class="col col-md-6">
	<div class="resourcePanel">
		<div class="col-xs-2">
			<img class="resourceIcon" width="100%" src="./img/main/fangamesIcon.png">
		</div>
		<div class="col-xs-10 col-md-10">
			<div class="row">Somersault Utilities Script</div>
			<div class="row descField">This is just a script with lots of different things to be done and what not. AKA, lorem ipsum dolor dit amet.</div>
		</div>
	</div>
</div>
*/
function createItemBox(section,data,rowId){
	console.log(data);
	var container = document.createElement("div");
	container.className += "col col-md-6 vanishable";
	
	var box = document.createElement("div");
	box.id = data["ID"];
	box.className += "resourcePanel";
	
	var iconCol = document.createElement("div");
	iconCol.className += "col-xs-2";
	iconCol.id = "iconCol"+rowId;
	
	var icon = document.createElement("img");
	icon.className += "resourceIcon";
	icon.setAttribute("width","100%");
	var iconName = data["icon"] == "default" ? data["icon"]+".png" : data["ID"]+"/"+data["icon"]
	icon.src = "img/"+section+"/"+iconName;
	icon.id = "icon"+rowId;
	
	var dataCol = document.createElement("div");
	dataCol.className += "col-xs-10 col-md-10";
	dataCol.id = "dataCol"+rowId;
	
	var title = document.createElement("div");
	title.className += "row";
	title.innerHTML += data["name"];
	title.id = "title"+rowId;
	
	var desc = document.createElement("div");
	desc.className += "row descField";
	desc.innerHTML += data["desc"];
	desc.id = "desc"+rowId;
	
	container.append(box);
	box.append(iconCol);
	box.append(dataCol);
	iconCol.append(icon);
	dataCol.append(title);
	dataCol.append(desc);
	
	console.log("row: resourceRow"+rowId);
	document.getElementById("resourceRow"+rowId).append(container); 
};

var moveY = 5;
var posY = 10;
var mouseDown = function() {
	this.style["background-color"]="rgba(231,199,110,1.00)";
	this.style["box-shadow"] = "0px 5px 5px rgba(20,20,20,0.4)";
	this.style["border-style"] = "solid";
	this.style.top = posY;
	
	var elem = document.getElementById(this.id);
	elem.getElementsByClassName("mainBtnIcon")[0].style.display = "inline";
	if (screen.width <= 767){ elem.getElementsByTagName("p")[0].style.display = "none"; }
	/*var y = parseInt(this.style.top);
	var i = 0;
	var myInterval = setInterval(function(){
		if (i == moveY || parseInt(elem.style.top) == posY-moveY){ clearInterval(myInterval); }
		else{
			y--;
			i++;
			elem.style.top = y+'px';
		}
	},10);*/
};

var mouseUp = function() {
	this.style["background-color"]="rgba(208,175,83,1.00)";
	this.style["box-shadow"] = "0px 0px 0px rgba(0,0,0,0)";
	this.style["border-style"] = "none";
	this.style.top = posY-moveY;
	
	var elem = document.getElementById(this.id);
	elem.getElementsByClassName("mainBtnIcon")[0].style.display = "none";
	elem.getElementsByTagName("p")[0].style.display = "inline";
/*	var y = parseInt(this.style.top);
	var i = 0;
	var myInterval = setInterval(function(){
		if (i == moveY || parseInt(elem.style.top) == posY){ clearInterval(myInterval); }
		else{
			y++;
			i++;
			elem.style.top = y+'px';
		}
	},10);*/
};