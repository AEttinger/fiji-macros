// working directory and lif project file
dir = "/media/andreas/Samsung 950 Pro/Data/SP8/160530_stage_testing_SP8/";
file = "stage_testing001.lif";
// import metadata
run("Bio-Formats Importer", "open=["+dir+file+"] color_mode=Default display_metadata view=[Metadata only] stack_order=XYCZT");

selectWindow("Original Metadata - "+file);
lines = getValue("results.count"); // get line number of metadata

// initialize array size of experiments*positions
seriesNames = newArray(5*25);
a = 0;

//type = getInfo("window.type");
//print(type);

// loop over metadata
for(i=0; i<lines; i++) {
	//selectWindow("Original Metadata - "+file);
	key = getResultString("Key",i);
	val = getResultString("Value",i);
	checkKey = matches(key," Series.[0-9]{1,}.Name"); // metadata in LIF have a trailing whitespace (!) get the values for Series Name
	checkVal = matches(val,"Mark_and_Find_[0-3|5-6]{3}/Position[0-9]{3}"); // select the valid experiments 'Mark_and_Find' no.4 was aborted
	//print(key+" "+val+" "+check);
	if(checkKey && checkVal) {
		// if the line contains a series name and is a correct experiment
		// save the number of the series as integer
		// increased by +1 for open series starts at 1
		seriesNames[a] = parseInt(substring(key,8,indexOf(key," Name")))+1; 
				
		//seriesNames[a] = "series_"+ (parseInt(substring(key,8,indexOf(key," Name")))+1);
		
		a = a+1;
		}
	}
	
Array.sort(seriesNames); // sort series numbers ascending

for(i=0;i<seriesNames.length; i++) {
	print(seriesNames[i]);
}

// file to write results, print header row
f = File.open("/home/andreas/Desktop/results.txt");
print(f,"image1,image2,dX,dY,avgErr");
// loop over series
// 5 experiments with 25 positions each
for(k=0; k<5; k++) {
	// loop over positions in one experiment
	for(i=k*25; i<(k*25+25)-2; i++) {
		//print("open series: "+ seriesNames[i] +" | "+ seriesNames[i+2]);
		
		// get correct series numbers; open images, get actual position number from series image title
		run("Bio-Formats Importer", "open=["+dir+file+"] color_mode=Default view=Hyperstack stack_order=XYCZT series_"+seriesNames[i]);
		image1 = getTitle();
		run("Bio-Formats Importer", "open=["+dir+file+"] color_mode=Default view=Hyperstack stack_order=XYCZT series_"+seriesNames[i+2]);
		image2 = getTitle();	
		// save positions as integers
		// corresponding positions to analyze are 1&3 3&5 5&7 ... 23&25
		pos1 = parseInt(substring(image1,lengthOf(image1)-3,lengthOf(image1)));
		pos2 = parseInt(substring(image2,lengthOf(image2)-3,lengthOf(image2)));
		
		//print(image1+" "+image2);
		//print(pos1+" "+pos2);
		
		// only compare if both images have positions
		if((pos1 % 2) & (pos2 % 2)) {
			// erase contents of Log window
			print("\\Clear");
			// use Preibisch's plugin to get XY shift
			// use purely translational model
			// use manually tested values for sigma and theshold
			run("Descriptor-based registration (2d/3d)", "first_image=["+image1+"] second_image=["+image2+"] brightness_of=[Advanced ...] approximate_size=[Advanced ...] type_of_detections=[Maxima only] subpixel_localization=[3-dimensional quadratic fit] transformation_model=[Translation (2d)] images_pre-alignemnt=[Approxmiately aligned] number_of_neighbors=3 redundancy=1 significance=3 allowed_error_for_ransac=5 choose_registration_channel_for_image_1=1 choose_registration_channel_for_image_2=1 detection_sigma=2.0015 threshold=0.03003");	
		
		// get results from the Log window
		output = getInfo("Log");
		// get indices of relevant results
		xId = indexOf(output,"[[1.0, 0.0, ");
		yId = indexOf(output,", [0.0, 1.0, ");
		errId = indexOf(output,"]]) ");
		// write results into file
		print(f, image1+","+image2+","+substring(output,xId+12,xId+23)+","+substring(output,yId+13,yId+24)+","+substring(output,errId+4,errId+15));	
		
		}
		// close images
		selectWindow(image1);
		close();
		selectWindow(image2);
		close();
		
		}

	//print("Reading position ... "+seriesNames[k]);	
}

// close file handle
File.close(f);
