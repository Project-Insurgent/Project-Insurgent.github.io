/*var loadTab = function(url){
	window.open(url, 'mainTab');
	iFrameResize({log: true }, "#mainTabs");
	setTimeout(function(){document.getElementById("mainTabs").style.display = "inline";},200);};*/
window.onload = function(){
	var elements = document.getElementsByClassName("mainButton");
	for(var i = 0; i < elements.length; i++){
		elements[i].addEventListener("click",vanishCurrentTab);
		elements[i].addEventListener("mouseover",mouseDown);
		elements[i].addEventListener("mouseout",mouseUp);
	}

	var vanishables = document.getElementsByClassName("vanishable");
	for(var k = 0; k < vanishables.length; k++){ vanishables[k].style.opacity = 1; }
};

var _frames   = 30;
var currentType = "";
var vanishCurrentTab = function(){
	if (this.classList.contains("mainButton")){ currentType = this.id; }
	var vanishable = document.getElementsByClassName("vanishable");
	var i = 0;
	var opacity = 1.0;
	var myInterval = setInterval(function(){
		if (i === _frames){ 
			for(var k = 0; k < vanishable.length; k++){ vanishable[k].remove(); }
			readJsonMethod(currentType);
			appearCurrentTab();
			clearInterval(myInterval);
		}
		else{
			opacity -= 1.0/_frames;
			for(var h = 0; h < vanishable.length; h++){ vanishable[h].style.opacity = opacity; }
			i++;
		}
	},10);
};

var appearCurrentTab = function(){
	var vanishables = document.getElementsByClassName("vanishable");
	for(var j = 0; j < vanishables.length; j++){ vanishables[j].style.display = "block"; }
	var i = 0;
	var opacity = 0.0;
	var myInterval = setInterval(function(){
		if (i === _frames){ clearInterval(myInterval); }
		else{
			opacity += 1.0/_frames;
			for(var k = 0; k < vanishables.length; k++){ vanishables[k].style.opacity = opacity; }
			i++;
		}
	},10);
};

var dataHash = {};
var readJsonMethod = function(section){
	fetch("metadata/"+section+".json")
		.then(results => results.json())
		.then(function(data){
			console.log(data.toString());
			for (var i = 0; i < data.length; i++){
				if (i % 2 === 0){ createRow(Math.floor(i/2)); }
				createItemBox(section,data[i],Math.floor(i/2).toString());
			}
			dataHash[section] = data;
		}
	);
};

function createRow(id){
	var row = document.createElement("div");
	row.id = "resourceRow"+id.toString();
	row.className += "row vanishable";
	//row.style.display = "block";
	document.getElementsByClassName("mainContainer")[0].append(row);
}

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
	var iconName = data["icon"] ? data["ID"]+"/"+data["icon"] : "default.png"; // === "default"; "S.A. Somersault"
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
	container.addEventListener("click",() => showDetailsTab(data));
}

var site = "https://github.com/Project-Insurgent/project-insurgent.github.com/tree/main/Somersault/";

var downloadNote = function() {
	return "<strong>Note:</strong> For getting the zip file, install this <a  class='myLink' href='https://stackoverflow.com/questions/7106012/download-a-single-folder-or-directory-from-a-github-repo/33753575#33753575' target=_blank>extension</a>. Then right click anywhere on the directory and click <strong>'gitZip Download'->' Current folder - vX.X'</strong>.<br />";
};

var defaultInstr = function(resource,version,idx) {
	return ""+
	(idx).toString()+". Download this <a class='myLink' href="+site+currentType+'/'+resource+'/'+version+" target=_blank>zip</a>.<br />"+
	(idx+1).toString()+". Select all the folders in the zip but the READMEs.<br />"+
	(idx+2).toString()+". Uncompress them directly into your game root folder.<br />";
};

var createInstructionBody = function(data) {
	var ret = document.createElement("div");
	ret.className += "col-xs-12 content";
	
	resource = data["ID"];
	var instr = "";
	var idx = 0;
	if (data["deps"]) {
		idx = data["deps"].length;
		for(var k = 0; k < idx; k++){ instr += k.toString()+". Install " + data["deps"][k] + ".<br />"; }	
	}
	
	
	if (data["instr"]){
		if (data["addDefInstr"]){ instr += defaultInstr(data["ID"],data["version"],idx); idx += 3; }
		for(var k = 0; k < data["instr"].length; k++){
			instr += idx.toString()+". "+data["instr"][k] + "<br />";
			idx += 1;
		}
		
		if (data["notes"]){
			for(var k = 0; k < data["instr"].length; k++){ instr += "<strong>Note:</strong> "+data["notes"][k] + "<br />"; }
		}
		if (data["addDefInstr"]){ instr += downloadNote(); }
	}
	else{ instr += defaultInstr(data["ID"],data["version"],idx)+downloadNote(); }

	
	ret.innerHTML += instr;
	if (!data["instr"] || data["addDefInstr"]) { 
		var imgCol = document.createElement("div");
		imgCol.className += "col-xs-12 col-md-10 col-md-offset-2";
		var img = document.createElement("img");
		img.className += "downloadNoteImg";
		img.setAttribute("src","img/downloadNote.png");
		ret.append(imgCol);
		imgCol.append(img);
	}
	var thatsIt = document.createElement("div");
	thatsIt.className += "col-xs-12";
	thatsIt.innerHTML += "<br /><strong>AND THAT'S IT!</strong>";
	ret.append(thatsIt);
	
	return ret;
};

var showDetailsTab = function(data){
	var authorName = "S.A. Somersault";
	if (data["addDefInstr"] == null ) {data["addDefInstr"] = true;}
	if (data["credits"] == null){ data["credits"] = []; }
	if (data["credits"][0] !== authorName) { data["credits"].unshift(authorName); }
	
	
	var detailsTab = document.createElement("div");
	detailsTab.id  = "detailsTab";
	detailsTab.className += "detailsTab";
	detailsTab.style.display = "inline";
	
	var headerTab = document.createElement("div");
	headerTab.className += "dtBasic row detailsTabHeader";

	var dataTab = document.createElement("div");
	dataTab.className = "dtBasic row detailsTabBody";
	
	var buttonCol = document.createElement("div");
	buttonCol.className += "dtBasic col-Xbutton col-xs-1 col-xs-offset-11";
	
	var xButton = document.createElement("button");
	xButton.className += "dtBasic closeButtonBtn";
	xButton.id = "xButton";
	xButton.addEventListener("click",() => document.getElementById("detailsTab").remove());
	
	var xIcon = document.createElement("span");
	xIcon.className += "dtBasic glyphicon glyphicon-remove closeButtonBtn";
	xIcon["aria-hidden"]="true";
	
	detailsTab.append(headerTab);
	detailsTab.append(dataTab);
	headerTab.append(buttonCol);
	buttonCol.append(xButton);
	xButton.append(xIcon);
	document.getElementById("resourcesContainer").append(detailsTab);
	//------------------------------------------------------
	
	var container = document.createElement("div");
	container.className += "col-xs-12";
	
	var title = document.createElement("div");
	title.className += "resourceTitle";
	title.innerHTML += data["name"];
	
	headerTab.append(container);
	container.append(title);
	
	if (data["longDesc"]){	
		var descRow = document.createElement("div");
		descRow.className += "row detailRow";
		
		var descTitle = document.createElement("div");
		descTitle.className += "col-xs-12 title";
		descTitle.innerHTML += "Description:";
		
		var descBody = document.createElement("div");
		descBody.className += "col-xs-12 content";
		descBody.innerHTML += data["longDesc"];
		
		descRow.append(descTitle);
		descRow.append(descBody);
		dataTab.append(descRow);
	}
	
	var creditsRow = document.createElement("div");
	creditsRow.className += "row detailRow";
	
	var creditsTitle = document.createElement("div");
	creditsTitle.className += "col-xs-12 title";
	creditsTitle.innerHTML += "Credits:";
	
	var credits = document.createElement("div");
	credits.className += "col-xs-12 content";
	for(var k = 0; k < data["credits"].length; k++){ credits.innerHTML += data["credits"][k]+"<br />"; }
	dataTab.append(creditsRow);
	creditsRow.append(creditsTitle);
	creditsRow.append(credits);
	
	var docRow = document.createElement("div");
	docRow.className += "row detailRow";
	
	var docTitle = document.createElement("div");
	docTitle.className += "col-xs-12 title";
	docTitle.innerHTML += "Documentation:";
	
	var documentation = document.createElement("div");
	documentation.className += "col-xs-12 content";
	documentation.innerHTML += "For the full documentation of this plugin, click <a class='myLink' href="+site+currentType+'/'+data["ID"]+'/'+"README.pdf target=_blank>here</a>";
	dataTab.append(docRow);
	docRow.append(docTitle);
	docRow.append(documentation);
	
	if (data["instr"] || data["addDefInstr"]){
		var instrRow = document.createElement("div");
		instrRow.className += "row detailRow";
		
		var instrTitle = document.createElement("div");
		instrTitle.className += "col-xs-12 title";
		instrTitle.innerHTML += "Installation Instructions:";
		
		var instrBody = createInstructionBody(data);
		instrRow.append(instrTitle);
		instrRow.append(instrBody);
		dataTab.append(instrRow);
	}
	
	if (data["img"]){
		var imgRow = document.createElement("div");
		imgRow.className += "row detailRow";
		dataTab.append(imgRow);
		
		var imgTitle = document.createElement("div");
		imgTitle.className += "col-xs-12 title";
		imgTitle.innerHTML += "Screenshots:";
		imgRow.append(imgTitle);
		
		for (var i = 0; i < data["img"].length;i++){
			var imgBody = document.createElement("div");
			imgBody.className += "col-xs-12 col-md-4";
			
			var img = document.createElement("img");
			img.style.width= "100%";
			img.setAttribute("src","img/"+currentType+"/"+data["ID"]+"/"+data["img"][i]+".png");
			
			imgBody.append(img);
			imgRow.append(imgBody);
		}
	}
	
	headerTab.style["background-image"] =  "url('img//"+currentType+"//"+data["ID"]+"//banner.png')";
};

/*
const removeChilds = (parent,exception) => { 
	var itemsList = parent.children;
	var parentStr = parent.id.toString();
	//var nthChild = //document.querySelector("#"+parentStr+' :nth-child('+counter.toString()+")");
	for (var i = 0; i < itemsList.length;i++) { 
		removeChilds(parent.children[i],exception);
		if (!parent.children[i].classList.contains(exception)) { parent.removeChild(parent.children[i]); };
		//nthChild = //document.querySelector("#"+parentStr+' :nth-child('+counter.toString()+")");
	};
};*/

var mouseDown = function() {
	this.style["background-color"]="rgba(231,199,110,1.00)";
	this.style["box-shadow"] = "0px 5px 5px rgba(20,20,20,0.4)";
	this.style["border-style"] = "solid";
	
	//this.style.top = posY; highlightable
	if (this.classList.contains("mainButton")){
		var elem = document.getElementById(this.id);
		elem.getElementsByClassName("mainBtnIcon")[0].style.display = "inline";
		if (screen.width <= 767){ elem.getElementsByTagName("p")[0].style.display = "none"; }
	}
};

var mouseUp = function() {
	this.style["background-color"]="rgba(208,175,83,1.00)";
	this.style["box-shadow"] = "0px 0px 0px rgba(0,0,0,0)";
	this.style["border-style"] = "none";
	//this.style.top = posY-moveY;
	if (this.classList.contains("mainButton")){
		var elem = document.getElementById(this.id);
		elem.getElementsByClassName("mainBtnIcon")[0].style.display = "none";
		elem.getElementsByTagName("p")[0].style.display = "inline";
	}
};

//python -m http.server 8000 -b [ip]