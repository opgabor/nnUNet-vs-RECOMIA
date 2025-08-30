#This script finds the proper origin of nnunet535 lungtumor mask, because the model was trained by a segment of whole pet image,
#consequently the predicted mask is also a segment of the whole image matrix of original pet. We need to reposition the predicted mask
#into the iamge matrix of original pet.

#setwd("/mnt/raid6_dmis0/proj/petlesion/etc/lung_lesion_test_dataset/erdos_samuel_laszlone_ID_065890536_STID_1_63749674581860127100001_5110211211837483820")
#wd="/home/leductrung/Compare_nnunet502_nnunet535/p009"
wd="/home/leductrung/Compare_nnunet502_nnunet535_manual_DSC_Hausdorff/p008"
setwd(wd)
print(wd)

library("fslr")
#wbpet=readnii("volume_382___detailwb_ctac__body_detail.nii", reorient = FALSE)
#wbpet=readnii("original.pet.nii", reorient = FALSE)
wbpet=readnii("ctac_pet.nii", reorient = FALSE)
#pet=readnii("volume_382___detailwb_ctac__body_detail_axi_cut.nii", reorient = FALSE)
#pet=readnii("original.pet.axi_cut.nii", reorient = FALSE)
pet=readnii("ctac_pet_axi_cut.nii", reorient = FALSE)
#n535mask=readnii("nnunet_535_f0_mask.nii.gz", reorient = FALSE)
n535mask=readnii("NNUNET_535_petlungtumor_mask.nii", reorient = FALSE)

#examine the dimensions
#dim(wbpet@.Data)
#[1] 288 288 382
#dim(pet@.Data)
#[1] 288 288 125

#visualize it
#one slice
#image(pet,z=62,plot.type="single")
#image(wbpet,z=62,plot.type="single")
#orthographic(pet,xyz=c(144,144,62)) 
#wholebody
#image(pet)

#1st slice of smaller pet
pet1stSlice=pet[,,1]
for(i in seq(1,dim(wbpet@.Data)[3]))
{    
    eq=all.equal(pet1stSlice,wbpet[,,i]); 
    if(is.logical(eq))
    {
	print(i);
#	only at patient p027: +1
#	n535mask@srow_z[4] = n535mask@srow_z[4] + (i-1)*wbpet@pixdim[2] +1;	#pixdim[4]: this is the step along z axis, it should be here, but sometimes this value is bad. I replace it with value along x axis
	#z origin offset
	n535mask@srow_z[4] = n535mask@srow_z[4] + (i-1)*wbpet@pixdim[2];	#pixdim[4]: this is the step along z axis, it should be here, but sometimes this value is bad. I replace it with value along x axis

	#1 0 0 -287.586 <------><------><------><------>2 0 0 -287.586
	#0 1 0 -217.586 <------><------><------><------>0 2 0 -217.586
	#0 0 1 158.1 <-><------><------><------><------>0 0 2.00465 158.1
	#0 0 0 1 <-----><------><------><------><------>0 0 0 1
	#2.00465 -> 2
	n535mask@srow_z[3] = n535mask@srow_x[1];				#it must be the same in all the 3 dimensions. Elements in diagonal correspond to scaling! Sometimes it could be 2.00465 instead of 2.0, this upscale value causes shift along z axis.

	#pixdim1<------>2.000000
	#pixdim2<------>2.000000
	#pixdim3<------>2.004651
	#2.00465 -> 2
	n535mask@pixdim[4] = wbpet@pixdim[2];
    }
}
writenii(n535mask, "NNUNET_535_petlungtumor_mask_offsetOK.nii" )

#p027
#ctac_pet.nii
#slicewidth=2mm
#|--------------------| 1020.1 mm = 431. slice
#|                    |
#| 63 slices          |          63 x 2 mm = 126 mm
#|                    |
#|                    |
#|--------------------| 894.1 mm = 367. slice
#| 127 slices         |
#|                    |          127 x 2 mm = 254 mm   (ctac_pet_axi_cut.nii)
#|                    |
#|--------------------| 640.1 mm = 241. slice
#| 241 slices         |
#|                    |
#|                    |
#|                    |          241 x 2 mm = 482 mm
#|                    |
#|                    |
#|                    |
#|--------------------| 158.1 mm = 1. slice (read out from s- or q-form)

#identity of ctac_pet_axi_cut.nii and ctac_pet.nii will be at 242. slice of ctac_pet.nii

#Sform = standard form, Qform = device form

###########################
##fslinfo ctac_pet.nii.gz #
###########################
#data_type	FLOAT32
#dim1		288
#dim2		288
#dim3		431
#dim4		1
#datatype	16
#pixdim1	2.000000
#pixdim2	2.000000
#pixdim3	2.004651
#pixdim4	0.000000
#cal_max	31.029215
#cal_min	0.000000
#file_type	NIFTI-1+

##fslorient -getsform ctac_pet.nii.gz 		qform
#1 0 0 -287.586 				2 0 0 -287.586
#0 1 0 -217.586 				0 2 0 -217.586
#0 0 1 158.1 					0 0 2.00465 158.1
#0 0 0 1 					0 0 0 1

################################
##fslinfo ctac_pet_axi_cut.nii #		origin_z is wrong (158.1)
################################
#data_type	FLOAT32
#dim1		288
#dim2		288
#dim3		127
#dim4		1
#datatype	16
#pixdim1	2.000000
#pixdim2	2.000000
#pixdim3	2.004651
#pixdim4	1.000000
#cal_max	31.029215
#cal_min	0.000000
#file_type	NIFTI-1+

##fslorient -getsform ctac_pet_axi_cut.nii 	qform
#1 0 0 -287.586 				2 0 0 -287.586 
#0 1 0 -217.586 				0 2 0 -217.586 
#0 0 1 158.1 					0 0 2.00465 158.1 
#0 0 0 1 					0 0 0 1 

############################################
##fslinfo NNUNET_535_petlungtumor_mask.nii #
############################################
#data_type	UINT8
#dim1		288
#dim2		288
#dim3		127
#dim4		1
#datatype	2
#pixdim1	2.000000
#pixdim2	2.000000
#pixdim3	2.004651
#pixdim4	0.000000
#cal_max	0.000000
#cal_min	0.000000
#file_type	NIFTI-1+

##fslorient -getsform NNUNET_535_petlungtumor_mask.nii		qform
#2 0 -0 -287.586 						2 0 0 -287.586
#0 2 -0 -217.586 						0 2 0 -217.586
#0 0 2.00465 158.1 						0 0 2.00465 158.1
#0 0 0 1 							0 0 0 1

########################################################
##fslinfo NNUNET_535_petlungtumor_mask_offsetOK.nii.gz #
########################################################
#data_type	UINT8
#dim1		288
#dim2		288
#dim3		127
#dim4		1
#datatype	2
#pixdim1		2.000000
#pixdim2		2.000000
#pixdim3		2.000000
#pixdim4		1.000000
#cal_max		1.000000
#cal_min		0.000000
#file_type	NIFTI-1+

#fslorient -getqform NNUNET_535_petlungtumor_mask_offsetOK.nii.gz	qform
#2 0 -0 -287.586							2 0 0 -287.586
#0 2 0 -217.586 							0 2 -0 -217.586
#0 0 2 158.1 								0 0 2 640.1		= 158.1+(242-1)*2
#0 0 0 1								0 0 0 1

###########################
##fslinfo manual_mask.nii #
###########################
#filename	manual_mask.nii
#data_type	FLOAT32
#dim1		288
#dim2		288
#dim3		432
#dim4		1
#datatype	16
#pixdim1	2.000000
#pixdim2	2.000000
#pixdim3	2.000000
#pixdim4	0.000000
#cal_max	44960.000000
#cal_min	0.000000
#file_type	NIFTI-1+

##fslorient -getsform manual_mask.nii 			qform
#2 0 0 -287.586 					2 0 0 -287.586
#0 2 0 -217.586 					0 2 0 -217.586
#0 0 2 158.1 						0 0 2 158.1				: Can 779.1 mm be the first slice of a ROI (see offset in manual_mask.roi)? (779.1-158.1) mod 2 = 1. No!
#0 0 0 1						0 0 0 1

