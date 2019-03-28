macro "Next hyperstack time point [n6]" {
	Stack.getPosition(channel, slice, frame);
	Stack.setPosition(channel, slice, frame+1);
}

macro "Previous hyperstack time point [n4]" {
	Stack.getPosition(channel, slice, frame);
	Stack.setPosition(channel, slice, frame-1);
}

macro "Skip forward 5 hyperstack time points [n3]" {
	Stack.getPosition(channel, slice, frame);
	Stack.setPosition(channel, slice, frame+5);
}

macro "Skip back 5 hyperstack time points [n1]" {
	Stack.getPosition(channel, slice, frame);
	Stack.setPosition(channel, slice, frame-5);
}


macro "Next hyperstack slice [n8]" {
	Stack.getPosition(channel, slice, frame);
	Stack.setPosition(channel, slice+1, frame);
}

macro "Previous hyperstack slice [n5]" {
	Stack.getPosition(channel, slice, frame);
	Stack.setPosition(channel, slice-1, frame);
}

macro "Next hyperstack channel [n9]" {
	Stack.getPosition(channel, slice, frame);
	Stack.setPosition(channel+1, slice, frame);
}

macro "Previous hyperstack slice [n7]" {
	Stack.getPosition(channel, slice, frame);
	Stack.setPosition(channel-1, slice, frame);
}
