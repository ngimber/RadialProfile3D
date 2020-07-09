//niclas.gimber@charite.de

print("\\Clear");


//center
xc=yc=13;
zc=14;

Stack.getDimensions(width,  height,  channels,  slices,  frames)
	dir=getDirectory("image");
	imagename = getTitle();

length=2;//in units
xlabel="Center of Mass (Ch 1): X (px)";
ylabel="Center of Mass (Ch 1): Y (px)";
zlabel="Center of Mass (Ch 1): Z (px)";
import=false;

getPixelSize(unit,xpixelsize,ypixelsize,zpixelsize);


//dialogue
Dialog.create("RadialProfile3D:		Enter Values");
  	Dialog.addString("unit:", unit);
  	Dialog.addNumber("channels:", channels);
  	Dialog.addNumber("length (units):", length);
  	Dialog.addNumber("voxelsize x (units):", xpixelsize);
	Dialog.addNumber("voxelsize y (units):", ypixelsize);
	Dialog.addNumber("voxelsize z (units):", zpixelsize);
	Dialog.addNumber("center x (pixel):", xc);
	Dialog.addNumber("center y (pixel):", yc);
	Dialog.addNumber("center z (pixel):", zc);
	Dialog.addMessage("\n");
	Dialog.addMessage("the following options are only required for batch analysis");
	Dialog.addCheckbox("Import coordinates from Result table", import);
	Dialog.addString("label of x-column (write out quotation marks):", xlabel);
	Dialog.addString("label of y-column (write out quotation marks):", ylabel);
	Dialog.addString("label of z-column (write out quotation marks):", zlabel);
	
  	Dialog.show();
  	
    	unit= Dialog.getString();
    	channels = Dialog.getNumber();
    	length = Dialog.getNumber();
    	xpixelsize = Dialog.getNumber();
    	ypixelsize = Dialog.getNumber();
    	zpixelsize = Dialog.getNumber();
    	xc = Dialog.getNumber();
    	yc = Dialog.getNumber();
    	zc = Dialog.getNumber();
    	import = Dialog.getCheckbox();
		xlabel=Dialog.getString();
		ylabel=Dialog.getString();
		zlabel=Dialog.getString();
    	


prefix=("_");
xcoord=newArray();
ycoord=newArray();
zcoord=newArray();

//close previous results
if (isOpen("Results")) 
    {
     selectWindow("Results");
     run("Close");
    } 
	
//opem coordinate files	
if(import==true)
	{
	coordinateFile=File.openDialog("Open Coordinates");
	run("Results... ", "open="+coordinateFile+"");
	print("file: "+coordinateFile+"");

	//read coordinates
	xcoord=readArray(xlabel); //function defined below
	ycoord=readArray(ylabel); //function defined below
	zcoord=readArray(zlabel); //function defined below
	print("result import successful");
	}

//close previous results
if (isOpen("Results")) 
    {
     selectWindow("Results");
     run("Close");
    } 

//loop through coordinates, channels and do 3d rad plot
for(i=1;i<=channels;i++)
{
	channelnr=i;
	
	
	if(import==false)
	{
	rad3d(xc,yc,zc,xpixelsize,ypixelsize,zpixelsize,length,unit,channelnr,prefix);//prefix is required to rename result column
	printParam();//defined below
	}
		
	else
	{
 
	print("coordinates, x:");
	Array.print(xcoord);
	print("coordinates, y:");
	Array.print(ycoord);	
	print("coordinates, z:");
	Array.print(zcoord);

	for(j=0;j<xcoord.length;j++)
		{
		xc=xcoord[j];
		yc=ycoord[j];
		zc=zcoord[j];
		prefix=(j);
		printParam(); //defined below
		rad3d(xc,yc,zc,xpixelsize,ypixelsize,zpixelsize,length,unit,channelnr,prefix);
		
		}
	}





	
}

print("-----DONE-----");



selectWindow("Log");  //select Log-window
saveAs("Text", dir+imagename+"-Log.txt"); 
selectWindow("Log");
run("Close");
//selectWindow("Results");  //select Result-window
saveAs("results", dir+imagename+"-RadialPlots.txt"); 

exit;


//----------------------------------------------------------


//print parameters
function printParam()
	{
	print("unit: "+unit);
	print("channels: "+channels);
	print("length (in units): "+length);
	print("voxelsize x: "+xpixelsize);
	print("voxelsize y: "+ypixelsize);
	print("voxelsize z: "+zpixelsize);
	print("center x: "+xc);
	print("center y: "+yc);
	print("center z: "+zc);
	}


	

function readArray(columnname)
	{
	storageArray=newArray(nResults);
	for(row=0;row<nResults;row++)
		{
		storageArray[row]=getResult(columnname, row);
		}
		return storageArray;
	}




function rad3d(xc,yc,zc,xpixelsize,ypixelsize,zpixelsize,length,unit,channelnr,prefix)
{
center=newArray(-floor(-xc),-floor(-yc),-floor(-zc));	


//create empty arrays
npix=-floor(-(length/xpixelsize));
npixZ=-floor(-(length/zpixelsize));
//arraysize=sqrt((npix*npix)+(npix*npix)+(npix*npix));
arraysize=-floor(-(pow((npix+1),3)/8))+1;
intensities=newArray(arraysize);
normintensities=newArray(arraysize);
distances=newArray(arraysize);
nmdistances=newArray(arraysize);
nelements=newArray(arraysize);

print(npix);
print(arraysize);
 

n=8*pow(npix,3);
tmpintensities=newArray(n);
tmpdistances=newArray(n);

//calculate distances
distance=0;
Stack.getDimensions(width,  height,  channels,  slices,  frames)

counter=0;
for(z=center[2]-npixZ;z<center[2]+npixZ;z++)
	{

		if(z<0||z>slices)
			{
			print("Error, stack is not thick enough for length");
			}
		
		else
			{
			print("measure z slice "+z);

			//setSlice(z);
			Stack.setPosition(channelnr,z,0);
			//sliceintensities=newArray();
			
			for(x=center[0]-npix;x<center[0]+npix;x++)
				{
				
					for(y=center[1]-npix;y<center[1]+npix;y++)
						{
		
						//calculate pythagoras
						a=((center[0]-x)*xpixelsize);
						b=((center[1]-y)*ypixelsize);
						c=((center[2]-z)*zpixelsize);				
						distance=sqrt(a*a+b*b+c*c); //distance in units


						
						
							
							tmpintensities[counter]=getPixel(x,y); // write all intensities into one array
							tmpdistances[counter]=distance; // create  corresponding distance array (in units)
							counter=counter+1;
							
						
						}
				
				}
			}
	
			
	}





//fill distances array with increasing integers representing pixels: 0,1,2,3,etc, 
for(i=0;i<distances.length;i++)
	{
	distances[i]=i;	
	nmdistances[i]=distances[i]*xpixelsize;			
	}
	


//write and average into arrays 
for(i=0;i<counter;i++)
	{
	tmp=round(tmpdistances[i]/xpixelsize);//distance must be converted into pixels

	if(tmp==(tmpdistances[i]/xpixelsize))
		{
	intensities[tmp]=intensities[tmp]+tmpintensities[i];
	nelements[tmp]=nelements[tmp]+1;
		}
	else
		{
		rounddown=floor(tmpdistances[i]/xpixelsize);
		roundup=-floor(-(tmpdistances[i]/xpixelsize));
		
		intensities[rounddown]=intensities[rounddown]+tmpintensities[i]*(1-((tmpdistances[i]/xpixelsize)-rounddown));
		nelements[rounddown]=nelements[rounddown]+(1-((tmpdistances[i]/xpixelsize)-rounddown));

		intensities[roundup]=intensities[roundup]+tmpintensities[i]*(1-(roundup-(tmpdistances[i]/xpixelsize)));
		nelements[roundup]=nelements[roundup]+(1-(roundup-(tmpdistances[i]/xpixelsize)));
		}

	}


//normalize intensities
for(i=0;i<intensities.length;i++)
	{
	normintensities[i]=intensities[i]/nelements[i];
	if(nelements[0]>1){print("error in script. nelements[0] cannot be > 1")}

	}

	

//write into result table
done=false;
for(i=0;i<intensities.length;i++)
	{
	if(distances[i]<=npix)//get rid of all the measurements with too long distance that result from pytagoras
		{
		setResult(unit, i, nmdistances[i]);
		setResult(prefix+"_intensity Ch"+channelnr, i, normintensities[i]);
		}
	done=true;
	}


	
}



