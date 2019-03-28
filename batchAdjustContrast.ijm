imgList = getList("image.titles");

allImgMax = 0;
allImgMin = 65536;
for(i=0; i<imgList.length; i++) {
	theImg = imgList[i];
	selectWindow(theImg);
	for(s=1; s<nSlices(); s++){
		setSlice(s);
		getStatistics(area, mean, min, max, std);
		if(max>allImgMax) allImgMax=max;
		if(min<allImgMin) allImgMin=min;
	}
}


for(i=0; i<imgList.length; i++) {
	theImg = imgList[i];
	selectWindow(theImg);
	run("Subtract...", "value=483 stack");
	run("Grouped Z Project...", "projection=[Max Intensity] group="+nSlices());
	/*if(startsWith(theImg,"MAX")) {
		run("Subtract...", "value=483"); //subtract average camera offset
		setMinAndMax(0, 1000);
	}*/
	setMinAndMax(allImgMin-483, allImgMax+1);
	open("/home/andreas/Documents/bead.lut");
	run("RGB Color");
	
	saveAs("/home/andreas/Documents/"+theImg+"-RGB.tif");
	close();
	selectWindow(theImg);
	close();
}
