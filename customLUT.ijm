colors = File.openAsString("/home/andreas/Downloads/colorlist");
rgbvalues = split(colors,"\n");

getLut(reds, greens, blues);

k=0;

reds[0] = 0;
greens[0] = 0;
greens[0] = 0;

for(i=1; i<reds.length; i++){
	if(k==rgbvalues.length) k=0;

	values = split(rgbvalues[k],",");
	
	reds[i] = values[0];
	greens[i] = values[1];
	blues[i] = values[2];

	k++;
}

setLut(reds,greens,blues);
