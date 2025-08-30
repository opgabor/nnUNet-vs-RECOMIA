#!/bin/bash

#usage: R01_makeStructureSet.sh manual_mask.nii.roi manual
#$1: eg.: ./manual_mask.nii.roi					#input roi from volumeMask by vpp OR BrainMOD save voi to ROI
#$2: eg.: manual						#name of structureset

fname_sedroi="`dirname $1`/`basename -s '.roi' $1`.sed.roi"	#generate: ./manual_mask.nii.sed.roi
fname_poly=$fname_sedroi".poly"					#generate: ./manual_mask.nii.sed.roi.poly

#roi sample:
#vpproi
#RoiSeries {
#        Roi {
#                name: roi
#                description: an object
#                direction: AxialPlanar
#                color: 1.000000 1.000000 1.000000
#                roi_polygon {
#                        offset: -191.5
#                        reqpoints: 0
#                        pivot: [-262.567 28.9453 ]
#                        positive: 1
#                        [-309.442 -17.9297 ]
#                        [-309.442 21.1328 ]
#                        [-301.63 21.1328 ]
#                }
#	    }
#	}

#cheatsheet for sed:
#:  # label
#=  # line_number
#a  # append_text_to_stdout_after_flush
#b  # branch_unconditional             
#c  # range_change                     
#d  # pattern_delete_top/cycle          
#D  # pattern_ltrunc(line+nl)_top/cycle 
#g  # pattern=hold                      
#G  # pattern+=nl+hold                  
#h  # hold=pattern                      
#H  # hold+=nl+pattern                  
#i  # insert_text_to_stdout_now         
#l  # pattern_list                       
#n  # pattern_flush=nextline_continue   
#N  # pattern+=nl+nextline              
#p  # pattern_print                     
#P  # pattern_first_line_print          
#q  # flush_quit                        
#r  # append_file_to_stdout_after_flush 
#s  # substitute                                          
#t  # branch_on_substitute              
#w  # append_pattern_to_file_now         
#x  # swap_pattern_and_hold             
#y  # transform_chars             

#-n: supress automat print,
#-f: script file
sed -n -f - $1 > $fname_sedroi << SED_SCRIPT
					#pattern matching: if the next input line contains the '{' character, then
					#start to execute command block in {}
    /{/ 				\
    {    				\
					#1:label, where need to jump back, n; '-n' w/o flag print the current 
					#pattern space, in this case (-n) empties the curr.patt.sp. and read in the next line
	:1; n; 				\
					#if the line does not contain }, then start to execute next command block in {}
	/}/!				\
	{ 				\
					#if there is inside 'pivot', empties the curr.patt.sp.
	    /pivot/{n}; 		\
					#if there is inside 'offset' append it to the hold buffer
	    /offset/{H}; 		\
					#if there is inside the pattern space '['  char., then the whole line will be appended to the
					#hold buffer and jump/branch to label 1:
	    /\[/{H}; b1;		\
	};  				\
				        #exchange the pattern and hold buffer and print out the content ofpattern buffer
    };x;p;
SED_SCRIPT




vertices="matrix(c("; 
contour=""; 
contours=""; 
echo "library("RadOnc")" > $fname_poly;
echo "closed.polys=list(" > $fname_poly;						#appen oerator ">>" need to be used here!
 while read -r i; 
 do 
    if [[ $i =~ ^$ ]]; 									#if curr line fits to the pattern 'empty line' neglect it
    then 
	continue;
    fi; 
    if [[ $i =~ vpproi ]]; 								#same as before just for 'vpproi'
    then 
	continue;
    fi; 
    if [[ $i =~ } ]]; 									#same as before just for '}'
    then
	continue;
    fi; 
    if [[ $i =~ offset.* ]]; 								#if word 'offset' is  in line calculate the offset itself
    then 
	contour=`echo $contour | sed -r 's/(.*),$/\1),ncol=3,byrow=TRUE),/'`;		#ending of the R matrix statement
#	echo -e "$contour";								#print it
	contours=`echo "$contours\n$contour"`;
	z=`echo $i | sed -r 's/offset: (.*)/\1/'`; 					#calc. the z offset
	contour="matrix(c("; 								#begining of the R matrix statement
    else 
	xycoords=`echo $i | sed -r 's/.*\[(.*) (.*) \].*/\2,\1/'`; 
	contour="$contour$xycoords,$z,"; 						#put together the R statement
	vertices="$vertices$xycoords,$z,";
    fi; 
 done < $fname_sedroi
echo -e   "$contours" | sed -r '/^$/d' |sed '$ s/.$/)/'   >> $fname_poly; 
echo -e "v=$vertices" |sed '$ s/.$/),ncol=3,byrow=TRUE)/' >> $fname_poly
echo -e "$2=new(\"structure3D\", \"$2\", 1, \"cc\", \"mm\", v, c(0,0,0), 1, closed.polys, DVH)" >> $fname_poly;



