files = getFileList("/mnt/Evo/05_Stephan_Coloc_screen_data/library_1/screen");
images_dir = "/mnt/ProjectData/05_Stephan_Coloc/data/stardist_training/images/";
masks_dir = "/mnt/ProjectData/05_Stephan_Coloc/data/stardist_training/masks/";

done_images = getFileList(images_dir);

random("seed",42);

for(i=done_images.length; i<500; i++){

	k = random();
	
	if(!File.exists(files[round(k*files.length)])){
		open(files[round(k*files.length)]);
		img_name = getTitle();
		run("Split Channels");
		close("C1-"+img_name);
		close("C3-"+img_name);
		run("Duplicate...", "title=threshold");
		run("Gaussian Blur...", "sigma=1");
		setAutoThreshold("Huang dark");
		run("Threshold...");
		run("Convert to Mask");
		run("Fill Holes");
		run("Watershed");
		run("Analyze Particles...", "size=1000-Infinity circularity=0.40-1.00 clear add");
		selectWindow("threshold");
		close();
		setTool("brush");
	    call("ij.gui.Toolbar.setBrushSize", "12");
		waitForUser;
		n = roiManager("count");
		newImage("labels", "16-bit black", 1024, 1024, 1);
		selectWindow("labels");
		for(l=0; l<n; l++){
			roiManager("select",l);
			setColor(l+1);
			fill();
		}
		selectWindow("labels");
		saveAs(".tif",masks_dir+img_name);
		selectWindow("C2-"+img_name);
		saveAs(".tif",images_dir+img_name);
	
		close();
		close();
	}
}
