experiments = File.openAsRawString("C:/Users/andi/Documents/Projects/Xavier_FRAP/Microscopy/experiment_ids-200623.txt");
experiments = split(experiments,"\n");

lif_files = getFileList("C:/Users/andi/Documents/Projects/Xavier_FRAP/Microscopy/");

results_dir = "C:/Users/andi/Documents/Projects/Xavier_FRAP/results/stainings_3/";

to_analyze = ".*(ring1b sirna|nt).*"; // select condition using regular expression
i = 1;
antibodies = newArray();
secondaries = newArray();

while(i<(experiments.length-1)){
	  // print(i);
	  
		image_metadata = split(experiments[i],",");
		next_image_metadata = split(experiments[i+1],",");
		//print(image_metadata[1]);
		//print(next_image_metadata[1]);
		//print(image_metadata[2]);
		//print(next_image_metadata[2]);

		if((matches(image_metadata[1],next_image_metadata[1])) & (matches(image_metadata[2],next_image_metadata[2]))){ // ckeck if staining IF_<00> and image <00> number are the same, if yes only record antibodies or label
				antibodies = Array.concat(antibodies,newArray(image_metadata[3]));
				secondaries = Array.concat(secondaries,newArray(replace(image_metadata[4],"([A-Za-z])","")));
				i=i+1;

		}else if(((matches(image_metadata[1],next_image_metadata[1])) & (matches(image_metadata[2],next_image_metadata[2])!=true)) | (((matches(image_metadata[1],next_image_metadata[1]))!=true) & (matches(image_metadata[2],next_image_metadata[2]))) | (((matches(image_metadata[1],next_image_metadata[1]))!=true) & (matches(image_metadata[2],next_image_metadata[2]))!=true) ){ // if staining and image are not the same in the next row, trigger analysis
				antibodies = Array.concat(antibodies,newArray(image_metadata[3])); // add current label
				secondaries = Array.concat(secondaries,newArray(replace(image_metadata[4],"([A-Za-z])","")));

				if(secondaries.length > 1){
					first_secondary = parseInt(secondaries[0]);
					second_secondary = parseInt(secondaries[1]);
					if(first_secondary < second_secondary) {
						antibodies_copy = Array.copy(antibodies);
						for(ab=0; ab<antibodies.length; ab++){
							antibodies[ab] = antibodies_copy[(antibodies.length-1)-ab]; // flip order to match labels with channel order
						} 
					}
				}

				antibodies = Array.concat(antibodies,newArray("DAPI")); // add dapi, always in last channel and not present in experiment descriptions

				if(matches(toLowerCase(image_metadata[5]), to_analyze)){ 
					for(k=0; k<lif_files.length; k++){ // check all the files in the list
				
	  					if(matches(lif_files[k], replace(image_metadata[1],"_","")+".*.lif")){ // open file where the condition matches 

	  					run("Bio-Formats", "open=C:/Users/andi/Documents/Projects/Xavier_FRAP/Microscopy/"+lif_files[k]+" color_mode=Default open_all_series rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT"); // open all series in lif file
	  					while(nImages() > 0){
	  						image_title = getTitle();
	  						fov_nr = replace(image_title,"(.*IF[0-9]{1,}.*.lif - [0-9]{1,3}-)","");
	  						if(matches(image_title, ".*"+lif_files[k]+" - "+image_metadata[2]+"-.*")){ // run if the series number in the specific file matches
		  						getPixelSize(unit, pixelWidth, pixelHeight);
	  							if(pixelWidth > 0.3){ // do not analyze images taken with 20 x objectie
	  								close();
	  							}else{
	  							Stack.getDimensions(width, height, channels, slices, frames);
	  							if((channels > 1) & (slices > 1)) {	// if multiple z-stacks, pick middle optical section for z-stacks		
	  								run("Duplicate...", "title=["+image_title+"-single] duplicate slices="+round(slices/2));
	  								selectWindow(image_title);
	  								close();
	  								selectWindow(image_title+"-single");
	  								image_title = getTitle(); // set new image title for the single optical section
	  								Stack.getDimensions(width, height, channels, slices, frames);
	  							}
	  							if(channels > antibodies.length) { // some images have more channels than in the description
	  								for(ch = 0; ch<nSlices; ch++){
	  									setSlice(ch+1);
	  									run("Select All");
	  									getRawStatistics(nPixels, mean, min, max, std, histogram);
	  									if(mean < 1.5) { // assume channels with low mean intensity are not labeled
	  										run("Delete Slice", "delete=channel");
	  									}
	  								}
	  								Stack.getDimensions(width, height, channels, slices, frames);
	  							}
	  							run("Select None");
		  						roiManager("reset");
		  						run("Clear Results");
		  						selectWindow(image_title);
								Stack.getDimensions(width, height, channels, slices, frames);
		  						run("Duplicate...", "title=nuclei duplicate channels="+channels); // assume DAPI is in the last channel
								selectWindow("nuclei");
								run("Command From Macro", "command=[de.csbdresden.stardist.StarDist2D], args=['input':'nuclei', 'modelChoice':'Model (.zip) from File', 'normalizeInput':'true', 'percentileBottom':'1.0', 'percentileTop':'99.8', 'probThresh':'0.6000000000000001', 'nmsThresh':'0.45', 'outputType':'ROI Manager', 'modelFile':'C:\\\\Users\\\\andi\\\\Documents\\\\Projects\\\\Stephan_Coloc\\\\scripts\\\\jupyter_notebooks\\\\stardist_models\\\\200220-dragonfly-40x-2x.zip', 'nTiles':'1', 'excludeBoundary':'2', 'roiPosition':'Automatic', 'verbose':'false', 'showCsbdeepProgress':'false', 'showProbAndDist':'false'], process=[false]");
								selectWindow("nuclei");
								close();
								n_roi = roiManager("count");
								selectWindow(image_title);
		  						for(roi=0; roi<n_roi; roi++){
		  							roiManager("select",roi);
		  							roiManager("multi-measure measure_all append");
		  						}
		  						selectWindow("Results");
	
		  						for(res_no = 0; res_no<nResults; res_no++){
									roiManager("select",floor(res_no/channels));
									roi_name = Roi.getName; 
		  							
		  							setResult("file", res_no, File.getName(lif_files[k]));
		  							setResult("IF", res_no, image_metadata[1]);
		  							setResult("sample", res_no, image_metadata[2]);
		  							setResult("ROI", res_no, roi_name);
		  							setResult("image",res_no, fov_nr);		  							
		  							setResult("condition", res_no, image_metadata[5]);		  							
									setResult("label", res_no, antibodies[res_no % antibodies.length]);
									setResult("pixel_size",res_no,pixelWidth);
		  						}
		  						
		  						if(!File.exists(results_dir+image_metadata[1])){
		  							File.makeDirectory(results_dir+image_metadata[1]);
		  						}
	
		  						roiManager("save", results_dir+image_metadata[1]+File.separator+image_metadata[2]+"-"+fov_nr+"_rois.zip");
		  						saveAs("results",results_dir+image_metadata[1]+File.separator+image_metadata[2]+"-"+fov_nr+"_channel_intensities.txt");
		  						
		  						selectWindow(image_title);
		  						close();
	  							}
	  						}else{ 
	  							close(); // close if image title does not match	
	  						}
	  					}
	  	 			}
	  	 		}
				
				i=i+1;
				antibodies = newArray();
				secondaries = newArray();
			} else{
					i=i+1;
					antibodies = newArray();
					secondaries = newArray();
			}
		}else{
			print("something unexpected happened");
			print(image_metadata[1]+" ------- "+image_metadata[2]+" ------- "+image_metadata[5]);
			print(next_image_metadata[1]+" ------- "+next_image_metadata[2] +" ------- "+next_image_metadata[5]);     
			i=i+1;
			antibodies = newArray();
			secondaries = newArray();
		}			
}
