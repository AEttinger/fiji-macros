info = getImageInfo();

info = split(info,"\n");

info = info[0];


imageSeuqences = split(info,"(<image)");
info = split(info,"(DeltaT=)");


for(i=0; i<imageSequences.lenght;i++){
	print(imageSequences[i]);
}

n = nSlices();
n=65;
T = newArray(n);

for(i=1; i<info.length; i++){
	ind = indexOf(info[i],"PositionX");
	if(startsWith(info[i],'"')){
		T[i-1] = substring(info[i],1,ind-2);
	}
}

for(i=0;i<T.length;i++){
	//print(info[i]);
	print(T[i]);
}
