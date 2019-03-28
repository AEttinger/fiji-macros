//homeDir = "/media/andreas/Data/CenpA_counting/";

// select directory
homeDir = getDirectory("Choose a directory: ");

// list files recursively
listFiles(homeDir);

// extract file names from log window and save into array
filesStr = split(getInfo("log"),'\n');
selectWindow("Log");
run("Close");

// initialize for counting results
totalresults = 0;
lastresults = 0;

// loop through all files
for(f = 0; f < filesStr.length; f++) {

	// check from file name which set the image belongs to
	if(indexOf(filesStr[f],"/a/")>0) set = "a";
	else if(indexOf(filesStr[f],"/b/")>0) set = "b";
	else if(indexOf(filesStr[f],"/c/")>0) set = "c";

	// check from file name if there were 4 channels
	if(indexOf(filesStr[f],"/channel4/")>0) ch = 4;
	else ch = 3;

	// open file, this works for SCIFIO, Bioformats plugin not working at the moment
	open(filesStr[f]);

	// get the current image name
	imgName = getTitle();

	// split into single channels, close all but last channel
	run("Split Channels");

	for(i = 1; i<ch; i++) {
		selectWindow("C"+i+"-"+imgName); 
		close();
	}
	
	// create dialog to ask how many cells should be counted; default 2 for 2-cell embryo
	Dialog.create("How many cells to analyize?");
	Dialog.addNumber("Cell No.:",2);
	Dialog.show();
	cellnumber = Dialog.getNumber();

	// start analysis, set to multipoint tool
	setTool("multipoint");

	// repeat for all cells
	for(thecell=1; thecell < cellnumber+1; thecell++) {
		
		waitForUser("Click on CenpA foci in cell number "+thecell);

		run("Measure");
		run("Select None");
		
		// save in results window, add columns for file name, set name, channel and which cell was counted
		totalresults = nResults();

		for(j=lastresults; j<totalresults; j++) {
			setResult("File",j,filesStr[f]);
			setResult("Set",j,set);
			setResult("Channel",j,ch);
			setResult("Cell",j,thecell);
		}
		
	// after each round, adjust the result number
	lastresults = totalresults;
	updateResults();
	}

	// tidy up
	close();
	selectWindow("Results");
	saveAs("txt",homeDir+"results.txt");
	print("file = " + filesStr[f] + "; set = " + set + "; ch = " +ch);
}

// list files recursively function
function listFiles(dir) {
     list = getFileList(dir);
     for (i=0; i<list.length; i++) {
        if (endsWith(list[i], "/"))
           listFiles(""+dir+list[i]);
        else
           print(dir + list[i]);
     }
  }

