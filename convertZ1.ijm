dir = "/media/andreas/SAMSUNG/EMBO2016_LISH/DATA/Z1/160823/20160823/";
saveDir = "/media/andreas/SAMSUNG/processed/";

files = getFileList(dir);

angle = newArray(0,45,90,135,180);
setBatchMode(true);
for(i=0; i<files.length; i++){
	f = files[i];
	if(endsWith(f,".czi")){
		print("Copying... "+f);
		frame = substring(f,indexOf(f,"(")+1,indexOf(f,")"));
		File.copy(dir+f,"/home/andreas/Downloads/"+f);
		copy = "copy_of_"+f;
		File.rename("/home/andreas/Downloads/"+f,"/home/andreas/Downloads/"+copy);
		for(k=0; k<5; k++){
			print("Import view... "+k+1);					
			run("Bio-Formats Importer", "open=/home/andreas/Downloads/"+copy+" color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT series_"+k+1);
			title = getTitle();
			run("Split Channels");
			for(j=1; j<=4; j++){
				if(j==1||j==3){channel=1;
				}else if(j==2||j==4){channel=2;}
				if(j==1||j==2){illside=0;
				}else if(j==3||j==4){illside=1;}
				name = "160823_2cell_TALE-clover_H2B-RFP_tp"+frame+"_a"+angle[k]+"_ch"+channel+"_ill"+illside+".tif";
				print("Rename... "+f+" Frame="+frame+" Angle="+angle[k]+" Channel="+channel+" Illumination="+illside+" -> "+name);
				selectWindow("C"+j+"-"+title);
				roiManager("Select",k);
				run("Crop");
				print("Saving...");
				saveAs("tiff",saveDir+name);
				close();
				}				
		}
		print("Deleting temporary files...");
		File.delete("/home/andreas/Downloads/"+copy);
		}
}
setBatchMode(false);