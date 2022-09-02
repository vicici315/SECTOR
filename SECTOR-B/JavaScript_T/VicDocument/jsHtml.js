function changeImage(){
	element=document.getElementById("myimage");	//通过id"myimage"获取html里的元素
	if(element.width==("60")){	//获取图片宽度作为判断当前显示的是大图还是小图,做来回切换
		element.src="resource\\listIcon.png";
		element.width="306";
		element.height="306";
	}else{
		element.src="resource\\listIcon.png";
		element.width="60";
		element.height="60";
	}
}

function winAlert(){
	window.alert("弹窗内容："+(5+6));	//alert输出弹窗警告内容
}

function innerHtml(){
	document.getElementById("demo").innerHTML="innerHtml段落已修改";
}

function writeHtml(){
	document.write(Date());		//整个网页写入，Date函数获取当前时间日期
}

function writeToConsole(){
	console.log("把内容写入console.log");
}
//Lesson2
function printVar(){
	document.getElementById("var1").innerHTML = "var x = 7;";
}
function printStringVar(){
	document.getElementById("var2").innerHTML = '"var perosn = "String";';
}
var y = 7;
function welcomeFun(name,job){
	var x = 5;
	alert("Welcome "+name+", the "+job);
}
