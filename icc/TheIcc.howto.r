#this line will load dm,dr,d502,d535 and puts them together into D
source("/home/leductrung/Documents/dataInput.r")

#D collect all radiomic parameters in columns, one row for one patient. The category var for segmMethods
#dplyr::sample_n(D[,1:2], 5)
#  segmMethod original_shape_Elongation
#1         RE                 0.7054135
#2       n535                 0.9036973
#3         MS                 0.7843403
#4       n502                 0.7149982
#5         MS                 0.8711184

#install.packages("irr")
#install.packages("psych")
library("irr")
library("psych")

#remove the modeln502 from D
D=D[-which(D$segmMethod=='n502'),]

#rule out radiomics params whose value is NA in first line of Recomia
notNAColumnIndices=which(!is.na(D[which(D$segmMethod=='RE'),][1,]))
D=D[notNAColumnIndices]

#collect segm method relating data in separated data.frames
MS   = D[which(D$segmMethod=='MS'),]
RE   = D[which(D$segmMethod=='RE'),]
n535 = D[which(D$segmMethod=='n535'),]

#remove the 1st column that is the type of segmMethod
MS[,1]=NULL
RE[,1]=NULL
n535[,1]=NULL

#not necc
#colnames(MS)=paste0('MS-',colnames(MS))

#check: every rad params are three times
#sort(colnames(data))

dataMSRE=cbind(MS,RE)
dataMSn535=cbind(MS,n535)


icc(dataMSRE,    model = 'twoway', type = 'agreement', unit = 'average')
icc(dataMSn535,  model = 'twoway', type = 'agreement', unit = 'average')


#this is our case: MODEL: 2way mixed effects model, TYPE: mean of k raters, Definition: absolute agreement

print(icc(dataMSRE,    model = 'twoway', type = 'agreement', unit = 'average'))
# Average Score Intraclass Correlation
#   Model: twoway 
#   Type : agreement 
#   Subjects = 28 
#     Raters = 120 
# ICC(A,120) = 0.149
# F-Test, H0: r0 = 0 ; H1: r0 > 0 
# F(27,1037) = 1.25 , p = 0.179 
# 95%-Confidence Interval for ICC Population Values:
#  -0.189 < ICC < 0.482

print(icc(dataMSn535,  model = 'twoway', type = 'agreement', unit = 'average'))
# Average Score Intraclass Correlation
#   Model: twoway 
#   Type : agreement 
#   Subjects = 28 
#     Raters = 120 
# ICC(A,120) = 0.165
# F-Test, H0: r0 = 0 ; H1: r0 > 0 
# F(27,1031) = 1.28 , p = 0.154 
# 95%-Confidence Interval for ICC Population Values:
#  -0.17 < ICC < 0.493


print(ICC(dataMSRE))
#Call: ICC(x = dataMSRE)
#Intraclass correlation coefficients 
#                         type     ICC    F df1  df2    p lower bound	upper bound
#Single_raters_absolute   ICC1 -0.0010 0.88  27 3332 0.65     -0.0038	0.0052
#Single_random_raters     ICC2  0.0015 1.25  27 3213 0.18     -0.0013	0.0077
#Single_fixed_raters      ICC3  0.0021 1.25  27 3213 0.18     -0.0019	0.0109
#Average_raters_absolute ICC1k -0.1394 0.88  27 3332 0.65     -0.8277	0.3860
#Average_random_raters   ICC2k  0.1488 1.25  27 3213 0.18     -0.1845	0.4807
#Average_fixed_raters    ICC3k  0.1992 1.25  27 3213 0.18     -0.2847	0.5685			<----this is our case: MODEL: 2way mixed effects model, TYPE: mean of k raters, Definition: absolute agreement
# Number of subjects = 28     Number of Judges =  120

print(ICC(dataMSn535))
#Call: ICC(x = dataMSn535)
#Intraclass correlation coefficients 
#                         type      ICC   F df1  df2    p lower bound	upper bound
#Single_raters_absolute   ICC1 -0.00084 0.9  27 3332 0.61     -0.0037	0.0056
#Single_random_raters     ICC2  0.00164 1.3  27 3213 0.15     -0.0012	0.0080
#Single_fixed_raters      ICC3  0.00233 1.3  27 3213 0.15     -0.0017	0.0113
#Average_raters_absolute ICC1k -0.11132 0.9  27 3332 0.61     -0.7827	0.4011
#Average_random_raters   ICC2k  0.16454 1.3  27 3213 0.15     -0.1655	0.4916
#Average_fixed_raters    ICC3k  0.21887 1.3  27 3213 0.15     -0.2532	0.5791			<----this is our case: MODEL: 2way mixed effects model, TYPE: mean of k raters, Definition: absolute agreement
#Number of subjects = 28     Number of Judges =  120

