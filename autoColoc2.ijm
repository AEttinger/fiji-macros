dir = getDirectory("Choose a Directory");
setBatchMode(true);
filesList = File.open(dir+"files.txt");
listFiles(dir,filesList);
File.close(filesList);
ostype = getInfo("os.name");
if(ostype == "Windows"){
	nldel = "\r\n";
} else {
	nldel = "\n";
}
files = File.openAsString(dir+"files.txt");
files = split(files,nldel);

filePath = dir+"results.txt";
f = File.open(filePath);
print(f,"Experiment,LIF-File,Series,ROI,mean-C2,mean-C3,Pearson-R,tM1,tM2");
File.close(f);
getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
for(k=0; k<files.length; k++) {
	experimentID = "" + toString(year) + toString(month+1) + toString(dayOfMonth) + "-" + toString(hour) + toString(minute);
	/*expI = indexOf(files[k],"Experiment");
	experimentID = substring(files[k],expI+10,lengthOf(files[k]));
	experimentID = substring(experimentID,0,indexOf(experimentID,File.separator));*/
	
	run("Bio-Formats", "open="+files[k]+" color_mode=Default open_all_series rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
		
	
		while(nImages() > 0) {
			// get the curent image name
			imgName = getTitle();
			seriesName = split(imgName," -");
			lifName = seriesName[0];
			lifName = split(lifName,"(.lif)");
			lifName = lifName[0];
			seriesName = seriesName[1];
			// run segmentation in channel 1 (DAPI)
			selectWindow(imgName);
			run("Split Channels");
			selectWindow("C1-"+imgName);
			run("Gaussian Blur...", "sigma=3");
			setAutoThreshold("Otsu dark");
			run("Convert to Mask");
			run("Fill Holes");
			run("Watershed");
		
			// get the ROIs
			selectWindow("C1-"+imgName);
			run("Analyze Particles...", "size=5000-50000 pixel exclude clear add");
			n = roiManager("count");
		
			// get the ROIs with intensity > 10
			selectWindow("C3-"+imgName);
			// get the ROI no to be removed
			removeIds = newArray(0);
			for(i=0;i<n;i++){	
				roiManager("select", i);
				getRawStatistics(nPixels, mean, min, max, std, histogram);
				id = newArray(1);
				id[0] = i;
				if(parseFloat(mean) < 10.0) removeIds = Array.concat(removeIds,id);
			}
			// delete the 'negative' ones
			roiManager("select",removeIds);
			roiManager("delete");
	
			// save ROIs in channel 3
			selectWindow("C3-"+imgName);
			run("Select None");
			run("Duplicate...", "title=C3-mark-rois");
			selectWindow("C3-mark-rois");
			run("RGB Color");
			setForegroundColor(255, 255, 0);
			roiManager("show all");
			run("Flatten");
			saveAs(dir+"ROIs-"+experimentID+"-"+lifName+"-"+seriesName+".jpg");
			close();
			// need to close duplicate
			selectWindow("C3-mark-rois");
			close();
			
			
			// update no of ROIs
			n = roiManager("count");
			// the total no of results in this experiment
			// perform colocalization on channel 2 and 3 for each ROI
			selectWindow("C3-"+imgName);
			for(i=0;i<n;i++){	
				totN = getValue("results.count");
				newRes = totN;
				print("\\Clear");
				roiManager("select",i);
				run("Coloc 2", "channel_1=[C2-"+imgName+"] channel_2=[C3-"+imgName+"] roi_or_mask=[ROI Manager] threshold_regression=Costes display_images_in_result display_shuffled_images li_histogram_channel_1 li_histogram_channel_2 li_icq spearman's_rank_correlation manders'_correlation kendall's_tau_rank_correlation 2d_intensity_histogram costes'_significance_test psf=3 costes_randomisations=10");
				info = getInfo("log");
				info = split(info,"\n");
		
				// extract coloc results from 'Log' window
				for(s=0; s<info.length; s++){
					line = info[s];
					if(startsWith(line, "Pearson's R value (above threshold),")) rval = substring(line, 37, lengthOf(line));//setResult("Pearson-R", newRes, substring(line, 38, lengthOf(line)));
					else if(startsWith(line, "Manders' tM1 (Above autothreshold of Ch2)")) tM1 = substring(line, 43, lengthOf(line));//setResult("tM1",newRes, substring(line, 43, lengthOf(line)));
					else if(startsWith(line, "Manders' tM2 (Above autothreshold of Ch1)")) tM2 = substring(line, 43, lengthOf(line));//setResult("tM2",newRes, substring(line, 43, lengthOf(line)));		
				}
		
				// save some other image stats in the Results table
				selectWindow("C2-"+imgName);
				roiManager("select",i);
				getRawStatistics(nPixels, mean, min, max, std, histogram);
				c2Mean = mean;
				//setResult("Mean-C2",newRes,mean);
			
				selectWindow("C3-"+imgName);
				roiManager("select",i);
				getRawStatistics(nPixels, mean, min, max, std, histogram);
				c3Mean = mean;
				//setResult("Mean-C3",newRes,mean);
				
				//setResult("Image",newRes,imgName);
				//print(f,experimentID+","+lifName+","+seriesName+","+i+","+c2Mean+","+c3Mean+","+rval+","+tM1+","+tM2);
				File.append(experimentID+","+lifName+","+seriesName+","+i+","+c2Mean+","+c3Mean+","+rval+","+tM1+","+tM2, filePath);
			}
			// close coloc dialog by clicking on X -> need to adapt for each DISPLAY
			for(i=0;i<(n+1);i++){
				run("IJ Robot", "order=Left_Click x_point=580 y_point=20 delay=10");
				wait(100);
			}
			// close the image windows
			selectWindow("C1-"+imgName);
			close();
			selectWindow("C2-"+imgName);
			close();
			selectWindow("C3-"+imgName);
			close();
		
			// loop continues with next image until all images are closed
		}
		
}

function listFiles(dir,f) {
     list = getFileList(dir);
     for (i=0; i<list.length; i++) {
        if (endsWith(list[i], "/")) {
			currentPath = dir+list[i];
			currentPath = replace(currentPath,"/",File.separator);
           	listFiles(""+currentPath,f);           	
        }
        else
           if(endsWith(list[i],".lif")) {
           	// replace "/" with file separator
       		currentPath = dir+list[i];
			currentPath = replace(currentPath,"/",File.separator);
       		print(f, currentPath);
           }
     }
  }
