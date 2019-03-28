for(i=1; i<=nSlices(); i++){
setSlice(i);
run("Select All");
run("Translate...", "x="+5*(i-1)+" y=0 interpolation=None slice");
}