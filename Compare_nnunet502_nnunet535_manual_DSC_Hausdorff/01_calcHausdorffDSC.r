#set working directory
#setwd("/home/leductrung/Downloads/Project_502/p009")
patient="p008"
setwd(paste0("/home/leductrung/Compare_nnunet502_nnunet535_manual_DSC_Hausdorff/",patient))
print(patient)

#generate polygons from BrainMOD roi files
#for manual
system("../02_R01_makeStructureSet.sh manual_mask.nii.roi manual")
#and for nnunet502 predicted case
#system(paste0("../02_R01_makeStructureSet.sh lungtumor_",substr(patient,3,4),"_label.nii.gz.roi n502"))
#and for nnunet535 predicted case
#system("../02_R01_makeStructureSet.sh nnunet_535_f0_mask_offsetOK.nii.gz.roi n535")
system(paste0("../02_R01_makeStructureSet.sh NNUNET_535_petlungtumor_mask_offsetOK.nii.gz.roi n535"))


#install.packages("RadOnc")
suppressPackageStartupMessages(library("RadOnc"))

#by sourcing polygons in R, new datastructers are set like n502 or manual as you gave at the 2nd argument to R01_makeStructureSet.sh few lines above
source("manual_mask.nii.sed.roi.poly")
#source(paste0("lungtumor_",substr(patient,3,4),"_label.nii.gz.sed.roi.poly"))
source("NNUNET_535_petlungtumor_mask_offsetOK.nii.gz.sed.roi.poly")

#structure3D (initialized in 'poly' files) is a class defined in RadOnc package for radiation oncology (Analytical Tools for Radiation Oncology)
#This data structure contains 3D volumetric (structure3D) data and associated parameters for a single structure object
#these are the structures, slots in class:
#showClass("structure3D")
##Class "structure3D" [package "RadOnc"]
##Slots:
##Name:   name       volume    volume.units coordinate.units  vertices  origin   triangles   closed.polys  DVH
##Class:  character  numeric   character    character         matrix    numeric  matrix      matrix        DVH

#you can see into structures e.g.
#attributes(n502)
#attributes(n502)$name
#attributes(n502)$closed.polys

#Another class from RadOnc for dicom structuresets. This data structure contains one or more 3D structure (structure3D) objects, you set these objects few lines above
#showClass("structure.list")
##Class "structure.list" [package "RadOnc"]
##Slots:
##Name:  structures
##Class:       list
#s=new("structure.list",list(manual,n502,manual))	#manual are set 2x, because of visualization 
#s=new("structure.list",list(manual,n502,n535))
s=new("structure.list",list(manual,n535))

###############################################
#Hausdorrf distance and Dice Similarity Score #
###############################################
print("DSC:")
print(compareStructures(s, method="DSC"))
print("hausdorff:")
print(compareStructures(s, method="hausdorff", hausdorff.method="mean"))

##################
# visualize data #
##################
compareStructures(s, method="axial",plot=TRUE)


#########################################
# another method for Hausdorff distance #
#########################################
#library("fslr")

    #correct the bad sform transformation matrix in manual mask image
    #qform: input image orientation during flirt image registration
    #sform: reference image orientation
    #system(". /site/fsl-6.0/etc/fslconf/fsl.sh; fslorient -getqform manual_mask.nii")
    #system(". /site/fsl-6.0/etc/fslconf/fsl.sh; fslorient -getqform manual_mask.nii")
#system(". /site/fsl-6.0/etc/fslconf/fsl.sh; fslorient -copyqform2sform manual_mask.nii")

    #fmanual=readnii("manual_mask.nii")
#fn502=readnii(paste0("lungtumor_",substr(patient,3,4),"_label.nii.gz"))
    #fn535=readnii("nnunet_535_f0_mask_offsetOK.nii.gz")
#fn535=readnii("NNUNET_535_petlungtumor_mask_offsetOK.nii.gz")

    #look into data
    #manual@.Data[1:5,1:5,1]
    #     [,1] [,2] [,3] [,4] [,5]
    #[1,]    0    0    0    0    0
    #[2,]    0    0    0    0    0
    #[3,]    0    0    0    0    0
    #[4,]    0    0    0    0    0
    #[5,]    0    0    0    0    0

    #check that the images are real masks, that is range of pixels are in [0,1]
#c(min(fmanual),max(fmanual))
    #[1] 0 1
#c(min(fn502),max(fn502))
    #[1] 0 1
#c(min(fn535),max(fn535))
    #[1] 0 1

#manual_points=which(fmanual==1, arr.ind=TRUE)
#n502_points=which(fn502==1, arr.ind=TRUE)
#n535_points=which(fn535==1, arr.ind=TRUE)

    #check values
    #manual@.Data[121,133,288]
    #[1] 1
    #manual@.Data[115:125,133,288]
    #[1] 0 0 0 0 0 0 1 1 0 0 0

#cat("\nanother Hausdorff\n")

#library("pracma")
#print("hausdorff manual-n502:")
#print(hausdorff_dist(manual_points,n502_points))
#print("hausdorff manual-n535:")
#print(hausdorff_dist(manual_points,n535_points))




#results from here

#p009
#[1] "DSC:"
#          manual      n502      n535
#manual 1.0000000 0.9769856 0.9136471
#n502   0.9769856 1.0000000 0.9043490
#n535   0.9136471 0.9043490 1.0000000
#
#[1] "hausdorff:"
#          manual      n502     n535
#manual 0.0000000 0.6542708 1.467420
#n502   0.6542708 0.0000000 1.491089
#n535   1.4674203 1.4910888 0.000000

#p010
#[1] "DSC:"
#          manual      n502      n535
#manual 1.0000000 0.9537024 0.9142181
#n502   0.9537024 1.0000000 0.9547403
#n535   0.9142181 0.9547403 1.0000000

#[1] "hausdorff:"
#          manual      n502     n535
#manual 0.0000000 0.9511711 1.620300
#n502   0.9511711 0.0000000 1.244008
#n535   1.6202996 1.2440075 0.000000

#p011 - no nnunet502 mask

#p012
#          manual      n502      n535
#manual 1.0000000 0.8895311 0.8091887
#n502   0.8895311 1.0000000 0.8627132
#n535   0.8091887 0.8627132 1.0000000
#[1] "hausdorff:"
#         manual     n502     n535
#manual 0.000000 1.825951 2.473998
#n502   1.825951 0.000000 1.857338
#n535   2.473998 1.857338 0.000000
#another Hausdorff
#[1] "hausdorff manual-n502:"
#[1] 4.472136
#[1] "hausdorff manual-n535:"
#[1] 219.0297

#p013
#[1] "DSC:"
#          manual      n502      n535
#manual 1.0000000 0.7747756 0.7810651
#n502   0.7747756 1.0000000 0.9377608
#n535   0.7810651 0.9377608 1.0000000
#[1] "hausdorff:"
#         manual     n502     n535
#manual 0.000000 2.207709 2.054387
#n502   2.207709 0.000000 1.056727
#n535   2.054387 1.056727 0.000000
#another Hausdorff
#[1] "hausdorff manual-n502:"
#[1] 4.123106
#[1] "hausdorff manual-n535:"
#[1] 194.0026

#p014
#[1] "DSC:"
#          manual      n502      n535
#manual 1.0000000 0.8765062 0.7896523
#n502   0.8765062 1.0000000 0.9007809
#n535   0.7896523 0.9007809 1.0000000
#[1] "hausdorff:"
#        manual     n502     n535
#manual 0.00000 1.938680 2.765350
#n502   1.93868 0.000000 1.584989
#n535   2.76535 1.584989 0.000000
#another Hausdorff
#[1] "hausdorff manual-n502:"
#[1] 25.07987
#[1] "hausdorff manual-n535:"
#[1] 222.1171

#p015
#[1] "DSC:"
#          manual      n502      n535
#manual 1.0000000 0.9105517 0.9324831
#n502   0.9105517 1.0000000 0.9202238
#n535   0.9324831 0.9202238 1.0000000
#[1] "hausdorff:"
#         manual     n502     n535
#manual 0.000000 1.545998 1.028234
#n502   1.545998 0.000000 1.309512
#n535   1.028234 1.309512 0.000000
#another Hausdorff
#[1] "hausdorff manual-n502:"
#[1] 3
#[1] "hausdorff manual-n535:"
#[1] 256.0098

#p016 - no nnunet502 mask

#p017
#[1] "DSC:"
#          manual      n502      n535
#manual 1.0000000 0.8479521 0.9038058
#n502   0.8479521 1.0000000 0.9413994
#n535   0.9038058 0.9413994 1.0000000
#[1] "hausdorff:"
#         manual     n502     n535
#manual 0.000000 1.901191 1.670544
#n502   1.901191 0.000000 1.486316
#n535   1.670544 1.486316 0.000000
#another Hausdorff
#[1] "hausdorff manual-n502:"
#[1] 1.732051
#[1] "hausdorff manual-n535:"
#[1] 251.002

#p018
#[1] "DSC:"
#          manual      n502      n535
#manual 1.0000000 0.9045946 0.9657737
#n502   0.9045946 1.0000000 0.9386204
#n535   0.9657737 0.9386204 1.0000000
#[1] "hausdorff:"
#          manual     n502      n535
#manual 0.0000000 1.651255 0.9454167
#n502   1.6512553 0.000000 1.3973667
#n535   0.9454167 1.397367 0.0000000
#another Hausdorff
#[1] "hausdorff manual-n502:"
#[1] 1
#[1] "hausdorff manual-n535:"
#[1] 172.0029

#p019 - no nnunet502 mask

#p020
#[1] "DSC:"
#          manual      n502     n535
#manual 1.0000000 0.8995233 0.976056
#n502   0.8995233 1.0000000 0.904447
#n535   0.9760560 0.9044470 1.000000
#[1] "hausdorff:"
#          manual     n502      n535
#manual 0.0000000 1.770447 0.6696614
#n502   1.7704469 0.000000 1.6783963
#n535   0.6696614 1.678396 0.0000000
#another Hausdorff
#[1] "hausdorff manual-n502:"
#[1] 2.236068
#[1] "hausdorff manual-n535:"
#[1] 209.0024

#p021
#[1] "DSC:"
#          manual n502      n535
#manual 1.0000000    0 0.7550741
#n502   0.0000000    1 0.0000000
#n535   0.7550741    0 1.0000000
#[1] "hausdorff:"
#          manual     n502      n535
#manual  0.000000 46.94172  2.073424
#n502   46.941717  0.00000 43.379855
#n535    2.073424 43.37985  0.000000
#another Hausdorff
#[1] "hausdorff manual-n502:"
#[1] 45.70558
#[1] "hausdorff manual-n535:"
#[1] 218.0046

#p022
#[1] "DSC:"
#          manual n502      n535
#manual 1.0000000    0 0.6953828
#n502   0.0000000    1 0.0000000
#n535   0.6953828    0 1.0000000
#[1] "hausdorff:"
#         manual     n502     n535
#manual  0.00000 27.52640  2.65166
#n502   27.52640  0.00000 24.23411
#n535    2.65166 24.23411  0.00000
#another Hausdorff
#[1] "hausdorff manual-n502:"
#[1] 52.58327
#[1] "hausdorff manual-n535:"
#[1] 96.02604

#p023
#          manual      n502      n535
#manual 1.0000000 0.6440754 0.7997891
#n502   0.6440754 1.0000000 0.7884911
#n535   0.7997891 0.7884911 1.0000000
#[1] "hausdorff:"
#         manual     n502     n535
#manual 0.000000 2.818431 1.836411
#n502   2.818431 0.000000 2.096935
#n535   1.836411 2.096935 0.000000
#another Hausdorff
#[1] "hausdorff manual-n502:"
#[1] 2.236068
#[1] "hausdorff manual-n535:"
#[1] 229.0284

#p024
#[1] "DSC:"
#          manual      n502      n535
#manual 1.0000000 0.7541996 0.8683988
#n502   0.7541996 1.0000000 0.8359022
#n535   0.8683988 0.8359022 1.0000000
#[1] "hausdorff:"
#         manual     n502     n535
#manual 0.000000 2.539511 1.726324
#n502   2.539511 0.000000 1.886371
#n535   1.726324 1.886371 0.000000
#another Hausdorff
#[1] "hausdorff manual-n502:"
#[1] 3.162278
#[1] "hausdorff manual-n535:"
#[1] 244

#p025 - empty n535 mask

#p026
#[1] "DSC:"
#          manual      n502      n535
#manual 1.0000000 0.9627394 0.9610359
#n502   0.9627394 1.0000000 0.9727685
#n535   0.9610359 0.9727685 1.0000000
#[1] "hausdorff:"
#          manual      n502      n535
#manual 0.0000000 0.6750867 0.7297728
#n502   0.6750867 0.0000000 0.6498253
#n535   0.7297728 0.6498253 0.0000000
#another Hausdorff
#[1] "hausdorff manual-n502:"
#[1] 1.414214
#[1] "hausdorff manual-n535:"
#[1] 92.00543

#p027
#[1] "DSC:"
#          manual n502      n535
#manual 1.0000000    0 0.8785942
#n502   0.0000000    1 0.0000000
#n535   0.8785942    0 1.0000000
#[1] "hausdorff:"
#          manual     n502      n535
#manual   0.00000 234.8845   1.69635
#n502   234.88451   0.0000 236.40508
#n535     1.69635 236.4051   0.00000
#another Hausdorff
#[1] "hausdorff manual-n502:"
#[1] 185.2458
#[1] "hausdorff manual-n535:"
#[1] 242.0041

#p028
#[1] "DSC:"
#          manual      n502      n535
#manual 1.0000000 0.9072094 0.8834638
#n502   0.9072094 1.0000000 0.9738783
#n535   0.8834638 0.9738783 1.0000000
#[1] "hausdorff:"
#         manual      n502      n535
#manual 0.000000 1.5717461 1.5239101
#n502   1.571746 0.0000000 0.7978378
#n535   1.523910 0.7978378 0.0000000
#another Hausdorff
#[1] "hausdorff manual-n502:"
#[1] 26.4764
#[1] "hausdorff manual-n535:"
#[1] 178.0056

#p029 - empty n502 mask

#p030
#[1] "DSC:"
#          manual      n502      n535
#manual 1.0000000 0.8254257 0.8373171
#n502   0.8254257 1.0000000 0.9323806
#n535   0.8373171 0.9323806 1.0000000
#[1] "hausdorff:"
#         manual     n502     n535
#manual 0.000000 2.324608 2.497858
#n502   2.324608 0.000000 1.582809
#n535   2.497858 1.582809 0.000000
#another Hausdorff
#[1] "hausdorff manual-n502:"
#[1] 3.741657
#[1] "hausdorff manual-n535:"
#[1] 228.0439

#p031
#[1] "DSC:"
#          manual      n502      n535
#manual 1.0000000 0.8411485 0.8837421
#n502   0.8411485 1.0000000 0.8371361
#n535   0.8837421 0.8371361 1.0000000
#[1] "hausdorff:"
#         manual     n502     n535
#manual 0.000000 2.111254 1.760620
#n502   2.111254 0.000000 2.208031
#n535   1.760620 2.208031 0.000000
#another Hausdorff
#[1] "hausdorff manual-n502:"
#[1] 5.385165
#[1] "hausdorff manual-n535:"
#[1] 209.0598

#p032
#[1] "DSC:"
#          manual      n502      n535
#manual 1.0000000 0.8690996 0.8164051
#n502   0.8690996 1.0000000 0.8998278
#n535   0.8164051 0.8998278 1.0000000
#[1] "hausdorff:"
#         manual     n502     n535
#manual 0.000000 2.099771 2.670506
#n502   2.099771 0.000000 1.665198
#n535   2.670506 1.665198 0.000000
#another Hausdorff
#[1] "hausdorff manual-n502:"
#[1] 2.236068
#[1] "hausdorff manual-n535:"
#[1] 172.0029

#p033
#[1] "DSC:"
#          manual n502      n535
#manual 1.0000000    0 0.2360496
#n502   0.0000000    1 0.0000000
#n535   0.2360496    0 1.0000000
#[1] "hausdorff:"
#           manual     n502       n535
#manual   0.000000 226.8112   7.995233
#n502   226.811221   0.0000 214.451332
#n535     7.995233 214.4513   0.000000
#another Hausdorff
#[1] "hausdorff manual-n502:"
#[1] 303.1518
#[1] "hausdorff manual-n535:"
#[1] 185.0135

#p034
#[1] "DSC:"
#          manual      n502      n535
#manual 1.0000000 0.8574001 0.8050536
#n502   0.8574001 1.0000000 0.9340279
#n535   0.8050536 0.9340279 1.0000000
#[1] "hausdorff:"
#         manual     n502     n535
#manual 0.000000 1.913571 2.321699
#n502   1.913571 0.000000 1.299197
#n535   2.321699 1.299197 0.000000
#another Hausdorff
#[1] "hausdorff manual-n502:"
#[1] 2.44949
#[1] "hausdorff manual-n535:"
#[1] 226.0376

#p035
#[1] "DSC:"
#          manual n502      n535
#manual 1.0000000    0 0.8087459
#n502   0.0000000    1 0.0000000
#n535   0.8087459    0 1.0000000
#[1] "hausdorff:"
#          manual     n502      n535
#manual  0.000000 60.38257  2.566568
#n502   60.382573  0.00000 60.145582
#n535    2.566568 60.14558  0.000000
#another Hausdorff
#[1] "hausdorff manual-n502:"
#[1] 33.01515
#[1] "hausdorff manual-n535:"
#[1] 154.0292

#p036
#[1] "DSC:"
#          manual      n502      n535
#manual 1.0000000 0.7315395 0.6574439
#n502   0.7315395 1.0000000 0.9161368
#n535   0.6574439 0.9161368 1.0000000
#[1] "hausdorff:"
#         manual     n502     n535
#manual 0.000000 3.659326 4.461052
#n502   3.659326 0.000000 1.570736
#n535   4.461052 1.570736 0.000000
#another Hausdorff
#[1] "hausdorff manual-n502:"
#[1] 3.605551
#[1] "hausdorff manual-n535:"
#[1] 60.08328

#p037
#[1] "DSC:"
#          manual      n502      n535
#manual 1.0000000 0.4623508 0.5508662
#n502   0.4623508 1.0000000 0.8344436
#n535   0.5508662 0.8344436 1.0000000
#[1] "hausdorff:"
#          manual      n502     n535
#manual  0.000000 13.621883 9.965312
#n502   13.621883  0.000000 2.369081
#n535    9.965312  2.369081 0.000000
#another Hausdorff
#[1] "hausdorff manual-n502:"
#[1] 26
#[1] "hausdorff manual-n535:"
#[1] 203.0616

#p038
#          manual n502      n535
#manual 1.0000000    0 0.7519861
#n502   0.0000000    1 0.0000000
#n535   0.7519861    0 1.0000000
#[1] "hausdorff:"
#           manual     n502       n535
#manual   0.000000 280.2427   3.273178
#n502   280.242656   0.0000 280.852883
#n535     3.273178 280.8529   0.000000
#another Hausdorff
#[1] "hausdorff manual-n502:"
#[1] 349.6327
#[1] "hausdorff manual-n535:"
#[1] 235.1127

#p039
#[1] "DSC:"
#          manual n502      n535
#manual 1.0000000    0 0.8124297
#n502   0.0000000    1 0.0000000
#n535   0.8124297    0 1.0000000
#[1] "hausdorff:"
#           manual     n502       n535
#manual   0.000000 139.3582   2.091223
#n502   139.358239   0.0000 141.122477
#n535     2.091223 141.1225   0.000000
#another Hausdorff
#[1] "hausdorff manual-n502:"
#[1] 84.49852
#[1] "hausdorff manual-n535:"
#[1] 216.0116

#p040
#[1] "DSC:"
#          manual      n502      n535
#manual 1.0000000 0.8928935 0.7774899
#n502   0.8928935 1.0000000 0.8556486
#n535   0.7774899 0.8556486 1.0000000
#[1] "hausdorff:"
#         manual     n502     n535
#manual 0.000000 2.224445 5.349883
#n502   2.224445 0.000000 3.985595
#n535   5.349883 3.985595 0.000000
#another Hausdorff
#[1] "hausdorff manual-n502:"
#[1] 3.316625
#[1] "hausdorff manual-n535:"
#[1] 179

#p041
#[1] "DSC:"
#          manual      n502      n535
#manual 1.0000000 0.7858313 0.7523803
#n502   0.7858313 1.0000000 0.9510436
#n535   0.7523803 0.9510436 1.0000000
#[1] "hausdorff:"
#         manual     n502     n535
#manual 0.000000 4.354195 4.828307
#n502   4.354195 0.000000 1.185151
#n535   4.828307 1.185151 0.000000
#another Hausdorff
#[1] "hausdorff manual-n502:"
#[1] 15.58846
#[1] "hausdorff manual-n535:"
#[1] 230

#p042
#[1] "DSC:"
#          manual      n502      n535
#manual 1.0000000 0.7077598 0.6327881
#n502   0.7077598 1.0000000 0.9160155
#n535   0.6327881 0.9160155 1.0000000
#[1] "hausdorff:"
#         manual     n502     n535
#manual 0.000000 3.877712 4.826373
#n502   3.877712 0.000000 1.699553
#n535   4.826373 1.699553 0.000000
#another Hausdorff
#[1] "hausdorff manual-n502:"
#[1] 3.605551
#[1] "hausdorff manual-n535:"
#[1] 231.0043













#--- from here, garbage collector -----
# apt install  libssl-dev libsasl2-dev

##in R4.1.0
#install.packages("htmlTable")
#install.packages("viridis")
#install.packages("Formula")

##tar.gz downloaded from https://cran.r-project.org/src/contrib/Archive/Hmisc/
#install.packages("/tmp/Hmisc_5.1-3.tar.gz", repos = NULL, type="source")

##it contains dice similarity metrics
#install.packages("epos")

#library("epos")

