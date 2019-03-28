dir = getDirectory("Choose directory with Raw Data!");

baseName = split(dir,File.separator());
baseName = baseName[baseName.length-1];

files = getFileList(dir);

rawFiles = newArray();

// get only the raw data files
for(i=0; i<files.length; i++) {
	if(!(endsWith(files[i],".xml") | endsWith(files[i],".txt") | endsWith(files[i],".env") | matches(files[i],"References(.)"))) {
		print(files[i]);
		f = newArray(files[i]);
		rawFiles = Array.concat(rawFiles, f);
	}
}

// check the beginning of the file array to get z-dimension
firstCycle = split(rawFiles[0],"(_RAWDATA_)");
lastCycle = split(rawFiles[rawFiles.length-1],"(_RAWDATA_)");



zNo = 0;

str = firstCycle[0]
firstID = firstCycle[1];
lastID = lastCycle[1];
lastCycleNo = split(lastCycle[0],"(CYCLE_)");
lastCycleNo = lastCycleNo[1];
firstID = parseInt(firstID);
lastID = parseInt(lastID);
lastCycleNo = parseInt(lastCycleNo);

while(matches(rawFiles[zNo], str +"(.*)")){
	// print(rawFiles[zNo]);
	zNo++;
}

// print(rawFiles.length / zNo );

// print(zNo);


Dialog.create("Time lapse parameters");
Dialog.addNumber("Channels:", 1);
Dialog.addNumber("Z Slices:",zNo);
Dialog.addNumber("T Frames:", 96);
Dialog.addNumber("XY Positions:", 10);
//Dialog.addCheckbox("Wait before Zseries?",1);
Dialog.addNumber("Raw data index start:", firstID);
Dialog.addNumber("Raw data index end:", lastID);
Dialog.addNumber("Number of cycles:", lastCycleNo);
Dialog.addString("Base name:", baseName, 30)
//Dialog.addCheckbox("Only convert raw files?",0);

Dialog.show();

chN = Dialog.getNumber();
zN = Dialog.getNumber();
tN = Dialog.getNumber();
xyN = Dialog.getNumber();
//w = Dialog.getCheckbox();
firstID = Dialog.getNumber();
lastID = Dialog.getNumber();
lastCycleNo = Dialog.getNumber();
baseName = Dialog.getString();
//convertOnly = Dialog.getCheckbox();

saveDir = getDirectory("Where to save?");

tmpDir = saveDir+File.separator()+"converted_"+baseName+"_files";

File.makeDirectory(tmpDir);

convertRaw(firstID, lastID, lastCycleNo, chN, zN, tN, xyN, baseName, dir, tmpDir);

assembleXY(firstID, lastID, chN, zN, tN, xyN, baseName, tmpDir, saveDir);


function convertRaw(firstID, lastID, lastCycleNo, chN, zN, tN, xyN, baseName, dir, tmpDir) {
progressBar = "[Progress]";
bar = "";
percentIDsDone = 0;
percentPerID = round((lastID - firstID) / 20);
nextProgress = 0;

if(!isOpen(progressBar)) {
	run("Text Window...", "name="+ progressBar +" width=80 height=4 monospaced");
}

print(progressBar, " Converting RAW "+percentIDsDone+"%  " + bar);
setBatchMode(true);
// position starts at
p=1;
// time series starts at
t=0;
// running id starts at
i=firstID;
// names of RAW images are CYCLE_00000c_RAWDATA_00000i
// we added a wait time which is counted as cycle
// therefore increment by 2

for(c=2; c<lastCycleNo + 1; c+=2){
	
	// fill up with 0's to match 000000 format
	n = lengthOf(d2s(c,0));
	cycleStr = c;
	for(k = 0; k < 6 - n; k++ < 7) 
		cycleStr = "0" + cycleStr;

		z=0;
		while(z<zN){ 
			// fill up with 0's to match 000000 format
			n = lengthOf(d2s(z,0));
			zStr = z+1;
			for(k = 0; k < 6 - n; k++) 
				zStr = "0" + zStr;
			
			// fill up with 0's to match 000000 format
			n = lengthOf(d2s(i,0));
			idStr = i;
			for(k = 0; k < 6 - n; k++) 
				idStr = "0" + idStr;
				
			
			// print("CYCLE_"+cycleStr+"_RAWDATA_"+idStr+" -->  TSeries-09152016-t"+time+"-pos"+pos);
			// import raw data
			// Bruker format with Photometrics is 512x512, 16-bit unsigned, needs little endian option ticked, otherwise no additional byte headers found
			//print(dir+"CYCLE_"+cycleStr+"_RAWDATA_"+idStr);
			run("Raw...", "open="+dir+"CYCLE_"+cycleStr+"_RAWDATA_"+idStr+" image=[16-bit Unsigned] width=512 height=512 number="+chN+" little-endian");
			
			title = getTitle();
				
				if(chN==1) {
					// print("Saved --> "+dir+"CYCLE_"+cycleStr+"_RAWDATA_"+idStr+"as --> "+tmpDir+File.separator+baseName+"_Cycle"+cycleStr+"_"+zStr+".tiff");
					saveAs("tiff",tmpDir+File.separator+baseName+"_Cycle"+cycleStr+"_"+zStr+".tiff");
					close();
				}

				
				if(i>nextProgress) {	
					bar = bar+"*";
					percentIDsDone = (i - firstID) / (lastID - firstID);
					print(progressBar, "\\Update: Converting RAW "+round(percentIDsDone*100)+"%  " + bar);
					nextProgress = nextProgress + percentPerID;
				}

				
				/*if(chN > 1){
					run("Stack to Images");
					// split into N channels
					for(i=1; i<= chN) {
						selectWindow(title+"-000"+i);
						saveAs("tiff",saveDir+baseName+"_Cycle"+cycleStr+"_Ch"+i"_"+zStr+".tiff");
						close();
					}*/
			
			z++;		
			i++;
		}

}
}

function assembleXY(firstID, lastID, chN, zN, tN, xyN, baseName, tmpDir, saveDir) {
progressBar = "[Progress]";
bar = "";
percentIDsDone = 0;
percentPerXY = round(xyN / 20);
nextProgress = 0;
if(!isOpen(progressBar)) {
	run("Text Window...", "name="+ progressBar +" width=80 height=4 monospaced");
}
print(progressBar, "\\Update2: Assembling XY movies "+percentIDsDone+"%  " + bar);
// position starts at
p=1;
// time series starts at
t=0;
// running id starts at
i=firstID;	
// get all the channels, z-positions and timepoints per XY location
setBatchMode(true);
for(xy = 1; xy <= xyN; xy ++) {
	print("\\Clear");

	for(t = 1; t <= tN; t ++) {

		for(ch = 1; ch <= chN; ch++) {

			for(z = 1; z <=zN; z++) {

				id =   xy * 2 + (t-1) * xyN * 2 ;

				n = lengthOf(d2s(id,0));
				idStr = id;
				for(k = 0; k < 6 - n; k++) {
					idStr = "0" + idStr;
				}
				n = lengthOf(d2s(z,0));
				zStr = z;
				for(k = 0; k < 6 - n; k++) {
					zStr = "0" + zStr;
				}
				
				if(chN == 1) {
					imgname = tmpDir + File.separator + baseName + "_Cycle" + idStr + "_" + zStr + ".tiff";
					print(imgname);
				} else {
					print("Multiple channels not implemented yet");
				}
 
			}
				
		}
		
	}

	selectWindow("Log");
	saveAs(".txt", saveDir + File.separator +  baseName + "_pos" + xy + "_filenames.txt");
	run("Stack From List...", "open=" + saveDir + File.separator + baseName + "_pos" + xy + "_filenames.txt");
	run("Stack to Hyperstack...", "order=xyzct channels="+chN+" slices="+zN+" frames="+tN+" display=Color");
	saveAs("tiff", saveDir + File.separator + baseName + "_pos" + xy + ".tiff");
	close();

	if(xy>nextProgress) {	
					bar = bar+"*";
					percentIDsDone = xy / xyN;
					print(progressBar, "\\Update2: Assembling XY movies "+round(percentIDsDone*100)+"%  " + bar);
					nextProgress = nextProgress + percentPerXY;
				}
}
}




