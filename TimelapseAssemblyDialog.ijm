dir = getDirectory("Choose directory with Raw Data!");

baseName = split(dir,File.separator());
baseName = baseName[baseName.length-1];

// open the xml
open(dir+ File.separator + baseName + ".xml");

//run("Bio-Formats Importer", "open="+ dir +File.separator + baseName + ".xml color_mode=Default display_metadata rois_import=[ROI manager] view=[Metadata only] stack_order=Default");
selectWindow("Original Metadata - " + baseName + ".xml");
info = getInfo("window.contents");
info = split(info,"\n");

// get metadata from metadata text
s = 0;
for(i=0; i<info.length; i++){
	if(startsWith(info[i]," Series")) s++;
	if(startsWith(info[i]," "+baseName+".xml"+" #1 SizeC")){
		ch = split(info[i],"(SizeC)");
		ch = ch[1];
	}
	if(startsWith(info[i]," "+baseName+".xml"+" #1 SizeT")){
		t = split(info[i],"(SizeT)");
		t = t[1];
	}
	if(startsWith(info[i]," "+baseName+".xml"+" #1 SizeZ")){
		z = split(info[i],"(SizeZ)");
		z = z[1];
	}
}

// extract metadata from file list
// all files including subdirectories
files = getFileList(dir);

// empty array for all the tif files
rawFiles = newArray();

// get only the raw data ome.tif files
for(i=0; i<files.length; i++) {
	if(endsWith(files[i],".ome.tif")) {
		f = newArray(files[i]);
		//print(files[i]);
		rawFiles = Array.concat(rawFiles, f);
	}
}

// check the beginning of the file array to get z-dimension
firstFile = rawFiles[0];
lastFile = rawFiles[rawFiles.length-1];

firstCh = split(firstFile,"(_[0-9]{6})");
firstCh = firstCh[0];

//print("Analyzing z\n---------");
zF = 0;
while(matches(rawFiles[zF], firstCh +"(.*)")){
	//print(rawFiles[zF]);
	zF++;
}

firstCycle = split(firstCh,"(_Ch[0-9]{1})");
firstCycle = firstCycle[0];

//print("Analyzing ch\n---------");
chF = 0;
while(matches(rawFiles[chF], firstCycle +"(.*)")){
	//print(rawFiles[chF]);
	chF++;
}

chF = chF/zF;

//print(ch, z, t);
//print(chF, zF);

firstID = split(firstFile,"(Cycle)");
firstID = split(firstID[1],"(_)");
firstID = firstID[0];

lastID = split(lastFile,"(Cycle)");
lastID = split(lastID[1],"(_)");
lastID = lastID[0];

//print(firstID, lastID);
// print(rawFiles.length / zNo );

// print(zNo);

Dialog.create("Time lapse parameters");
Dialog.addNumber("Channels:", ch);
Dialog.addNumber("Z Slices:",z);
Dialog.addNumber("T Frames:", t);
Dialog.addNumber("XY Positions:", s);
Dialog.addNumber("Cycles start:", firstID);
Dialog.addNumber("Cycles end:", lastID);
Dialog.addString("Base name:", baseName, 30)

Dialog.show();

chN = Dialog.getNumber();
zN = Dialog.getNumber();
tN = Dialog.getNumber();
xyN = Dialog.getNumber();
//w = Dialog.getCheckbox();
firstID = Dialog.getNumber();
lastID = Dialog.getNumber();
baseName = Dialog.getString();

saveDir = getDirectory("Where to save?");

assembleXY(firstID, lastID, chN, zN, tN, xyN, baseName, dir, saveDir);

function assembleXY(firstID, lastID, chN, zN, tN, xyN, baseName, dir, saveDir) {
progressBar = "[Progress]";
bar = "";
percentIDsDone = 0;
percentPerXY = round(xyN / 20);
nextProgress = 0;
if(!isOpen(progressBar)) {
	run("Text Window...", "name="+ progressBar +" width=80 height=4 monospaced");
}
print(progressBar, "\\Update: Assembling XY movies "+percentIDsDone+"%  " + bar);
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
				for(k = 0; k < 5 - n; k++) {
					idStr = "0" + idStr;
				}
				n = lengthOf(d2s(z,0));
				zStr = z;
				for(k = 0; k < 6 - n; k++) {
					zStr = "0" + zStr;
				}

				imgname = dir + File.separator + baseName + "_Cycle" + idStr + "_Ch" + ch + "_" + zStr + ".ome.tif";
				print(imgname);
 
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
					print(progressBar, "\\Update: Assembling XY movies "+round(percentIDsDone*100)+"%  " + bar);
					nextProgress = nextProgress + percentPerXY;
				}
}
}




