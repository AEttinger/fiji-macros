// specify home directory for saving
saveDir = "/home/andreas/Documents/Projects/03_Xavier_FRAP/analysis/";
// specify home directory with the data
sourceDir = "/media/andreas/ProjectData/03_Xavier_FRAP/Microscopy/FRAP/";
dateDirs = getFileList(sourceDir);

for(i=0; i<dateDirs.length; i++){
	dateDir = dateDirs[i];
	print(dateDir);
	expDirs = getFileList(sourceDir+dateDir);
	for(j=0; j<expDirs.length; j++){
		expDir = expDirs[j];
		if(!matches(expDir,"SingleImage.*")){ // ignore any single image folders
			imgFiles= getFileList(sourceDir+dateDir+expDir);
			for(k=0; k<imgFiles.length; k++){
				if(endsWith(imgFiles[k], ".tif")){
					seriesImg = imgFiles[k];
					print(seriesImg);	
					imgPath = sourceDir+dateDir+expDir+seriesImg;
					firstImg = replace(seriesImg,"_[0-9]{6}.ome.tif","_000001.ome.tif");	
					break; // break as soon as first image of series is found		
				}
			}
			
			// check if experiment folder already processed, ask to overwrite
			if(File.exists(saveDir+dateDir+expDir)) {
				overwrite = getBoolean("File already exists! Overwrite?");
			} else { 
				overwrite = 1; 
			}
			
			// if folder for experiment not present, create one
			if(!File.exists(saveDir+dateDir)) File.makeDirectory(saveDir+dateDir); 
			if(!File.exists(saveDir+dateDir+expDir)) File.makeDirectory(saveDir+dateDir+expDir);

			

			if(overwrite == 1) {
			open(sourceDir+dateDir+expDir+firstImg);
			T = getTimeSeries();
			close();
			
			// we import the frap image sequence as one stack
			run("Image Sequence...", "open="+imgPath+" sort");
					
			imgName = getTitle();
			selectWindow(imgName);
			
					
			getFrapRegion(); // get the ROIs for cell and FRAP

			
			selectWindow("thresholdImage");
				
			close();
			selectWindow(imgName);
			
			outputDir = saveDir+dateDir+expDir;
			
			saveAs("results",outputDir+"threshold_measurements.txt");
			run("Clear Results");

			
			setTool("rectangle");
			waitForUser("Select background!");
			roiManager("add");
			roiManager("select", nSlices()*2);
			roiManager("Remove Frame Info");

			waitForUser("Check ROIs! Press OK to measure!");
	
			// every other selection is a FRAP region
			line = 0;
			for(m=0; m<nSlices()*2; m+=2){
				roiManager("select",m);
				getRawStatistics(nPixels, mean);
				setResult("frap",line,mean);
				updateResults;
				line++;
			}
			// every odd selection is a Cell region
			line = 0;
			for(m=1; m<nSlices()*2; m+=2){
				roiManager("select",m);
				getRawStatistics(nPixels, mean);
				setResult("cell",line,mean);
				updateResults;
				line++;
			}
			// measure background
			line = 0;
			for(m=1; m<=nSlices(); m++){
				setSlice(m);
				roiManager("select", nSlices()*2);
				getRawStatistics(nPixels, mean);
				setResult("bg",line,mean);
				updateResults;
				line++;
			}
			// set time
			line = 0;
			for(m=0; m<T.length; m++){
				setResult("t",line,T[m]);
				updateResults;
				line++;
			}
					
			roiManager("save",outputDir+"rois.zip");
						
			Dialog.create("Drop measurements?");
			Dialog.addNumber("Begin sequence:",0);
			Dialog.addNumber("End sequence:", nSlices());

			Dialog.show();

			begin = Dialog.getNumber();
			end = Dialog.getNumber();

			if(end < nSlices()) {
				IJ.deleteRows(end, nSlices());
			}
			if(begin > 0) {
				IJ.deleteRows(0, begin-1);
			}

			saveAs("results",outputDir+"frap.txt");	
			roiManager("reset");
			selectWindow(imgName);
			close();
			 	
		}
	}
}


function getFrapRegion(){

// duplicate for thresholding
run("Duplicate...", "title=thresholdImage duplicate");
// blur to faciiltate smooth threshold
run("Gaussian Blur...", "sigma=2 stack");
// otsu threshold
run("Convert to Mask", "method=Otsu background=Dark");
// rund closure to remove small holes in threshold
run("Close-", "stack");
// set to the first slice after FRAP
setSlice(6);
// ask user to select the frap region
setTool("point");

waitForUser("Select middle of FRAP region!");
getSelectionCoordinates(xfrap, yfrap);
frap_x = xfrap[0];
frap_y = yfrap[0];

setSlice(1);
setTool("point");
waitForUser("Select frapped cell!");
getSelectionCoordinates(xcell, ycell);
cell_x = xcell[0];
cell_y = ycell[0];
	

// we loop through all thresholded images and update frapped region and the cell outline
run("Clear Results");
for(t=1; t<=nSlices(); t++){
	// save the center of frapped region and the cell
	
	setResult("FRAP XM", t-1, frap_x);
	setResult("FRAP YM", t-1, frap_y);
	setResult("Cell XM", t-1, cell_x);
	setResult("Cell YM", t-1, cell_y);
	updateResults;
	// move to slice, deselect and clear any saved selection
	setSlice(t);
	List.clear();
	run("Select None");
	roiManager("deselect");
	// for the first slices, just use center of frapped region that was user defined
	if(t<6) {
		makeOval(frap_x-8, frap_y-8, 16, 16);
		roiManager("add"); 
	} else { // afterwards, update by doing wand with th = 1.0 for getting the bleached region	
		doWand(frap_x, frap_y, 1.0, "8-connected");
		List.setMeasurements;
		frap_x = List.getValue("XM");
		frap_y = List.getValue("YM");
		makeOval(frap_x-8, frap_y-8, 16, 16);
		roiManager("add");
	}
	List.clear();
	run("Select None");
	roiManager("deselect");
	// update cell outline by doing wand with th = 1.0
	doWand(cell_x, cell_y, 1.0, "8-connected");
	List.setMeasurements;
	cell_x = List.getValue("XM");
	cell_y = List.getValue("YM");
	roiManager("add");
}
// close thresholded image, select raw data
selectWindow("thresholdImage");
// close(); 

}

function getTimeSeries(){
	// execute on the first image of Opterra Time Series which contains the XML metadata
	info = getImageInfo();
	// split by newline characters
	info = split(info,"\n");
	// only the first line contains all the metadata
	info = info[0];
	// after DeltaT comes the relative time of a sequence
	info = split(info,"(DeltaT=)");
	// ignore first line, does not contain DeltaT
	n=info.length-1;
	T = newArray(n);

	for(i=1; i<info.length; i++){
		ind = indexOf(info[i],"PositionX"); // the time delta string is followed by PositionX
		if(startsWith(info[i],'"')){
			T[i-1] = substring(info[i],1,ind-2); // get the substring containig the relative time points
		}
	}

	return T;
}

