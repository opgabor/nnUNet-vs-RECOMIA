#idea: https://www.sthda.com/english/wiki/one-way-anova-test-in-r

#data representation for MANOVA analysis

#category(ManualSegmentations, RecomiaSegmentations, Model502, Model_535),	param1, param2,...,	param107
#MSp001,										1,	2,    ,...,	107
#RSp001
#MSp002
#M502p001
#M535p001
#RSp002
#M502p002
#...




########################################
# load manual masks's radiomics values #
########################################
dm=read.csv("/home/leductrung/Downloads/Pyradiomics/data/oldManualMaskPyradiomics.csv")
rownames(dm)=dm[,1]
dm=dm[,-1]
dm=t(dm)
dm=data.frame(dm)
dm$subject=rownames(dm)
dm$method=rep(c('manual'), times = nrow(dm))
#rownames(dm)=rep(c('MS'), times = nrow(dm))

#sample
#dm[1:2,1:2]
#   original_shape_Elongation original_shape_Flatness
#MS                  0.953128               0.7425525
#MS                  0.668592               0.6337731

#################################
# load RECOMIA radiomics values #
#################################
#prefix: radiomics_SUV. in front of each parameternames
dr=read.csv("/home/leductrung/Downloads/Pyradiomics/data/RECOMIAPyradiomics.csv")
#remove the preficies
dr[,1]=gsub("^.*SUV.","",dr[,1])
rownames(dr)=dr[,1]
dr=dr[,-1]
dr=t(dr)
#rownames(dr)=rep(c('RE'), times = nrow(dr))

#get the missing parameternames from RECOMIA datatable, making set difference of manual, and RECOMIA datatables
index=colnames(dm)%in%colnames(dr)
#store it in a variable (!index = shows the prameternames are not in the table dr)
cn=colnames(dm)[!index]
#generate an array filled with NAs
missingData=array(NA,dim=c(nrow(dr),length(cn)))
#column names coming from manually segmented datatable
colnames(missingData) = cn
#rownames are the same as dr
rownames(missingData)=rep(c('RE'), times = nrow(dr))
#put together the two tables dr and missingData
dr=cbind(dr,missingData)

#reorder the columns corresponding to the columns of dm, match is the same as %in%
dr=dr[,match(colnames(dm),colnames(dr))]

#sample
#dr[1:2,1:2]
#   radiomics_SUV.original_shape_Elongation    radiomics_SUV.original_shape_Flatness
#RE                               0.9639335    0.7877407
#RE                               0.7824300    0.7079807

dr=data.frame(dr)
dr$subject=rownames(dr)
dr$method=rep(c('RECOMIA'), times = nrow(dr))



###########################################
# load nnunet502 model's radiomics values #
###########################################
d502=read.csv("/home/leductrung/Downloads/Pyradiomics/data/nnUNet502Pyradiomics.csv")
rownames(d502)=d502[,1]
d502=d502[,-1]
d502=t(d502)
#rownames(d502)=rep(c('n502'), times = nrow(d502))
d502=data.frame(d502)
d502$subject=rownames(d502)
d502$method=rep(c('nnUNet502'), times = nrow(d502))

#sample
#d502[1:2,1:2]
#     original_shape_Elongation original_shape_Flatness
#n502                 0.9445821               0.7352391
#n502                 0.3806253               0.2835332


###########################################
# load nnunet535 model's radiomics values #
###########################################
#d535old=read.csv("/home/leductrung/Project_535/old/pyradiomic_result_Project_535.csv")
#d535=read.csv("/home/leductrung/Project_535/Project535_pyradiomic_data_V5.csv")
#d535=read.csv("/home/leductrung/Project_535/NewConfig/Project535_pyradiomic_data_V5.csv")
#d535=read.csv("/home/leductrung/Project_535/OldConfig/old_proj_535_pyradiomic_data.csv")
d535=read.csv("/home/leductrung/Project_535/NewConfig/Project535_pyradiomic_data_V6.csv")
rownames(d535)=d535[,1]
d535=d535[,-1]
d535=t(d535)
#rownames(d535)=rep(c('n535'), times = nrow(d535))
d535=data.frame(d535)
d535$subject=rownames(d535)
d535$method=rep(c('nnUNet535'), times = nrow(d535))
colnames(d535)=gsub('Case.1_','',colnames(d535))

#sample
#d535[1:2,1:2]
#     Case-1_original_shape_Elongation: Case-1_original_shape_Flatness:
#n535                         0.6694862                       0.6168732
#n535                         0.8959054                       0.7670164


#####################
# put them together #
#####################
#D=rbind(dm,dr,d502,d535)
D=rbind(dm,dr,d535)
rn=rownames(D)
#rows
#manual:1-28		#28
#recomia: 29-56		#28
#nnunet502: 57-84	#28
#nnuet535: 85-125	#41
D=data.frame(D)
rownames(D)=NULL

#######################
# look into the table #
#######################
#at first, need to be installed: install.packages("dplyr")
library("dplyr")
dplyr::sample_n(D[,1:2], 10)
#        original_shape_Elongation original_shape_Flatness
#MS.15                   0.9051983               0.7517902
#MS.3                    0.8172627               0.5475591
#n535.13                 0.7964745               0.6697672
#n535.18                 0.8007055               0.6825321
#n535.1                  0.8959054               0.7670164
#n535.5                  0.9004547               0.7236509
#n502.13                 0.7437210               0.6207444
#n502.22                 0.5975793               0.3359644
#n502.21                 0.7206474               0.6440683
#n535.31                 0.6949907               0.6525821

#to make sampling from D by dplyr, it need to be a data.frame not an array, but in data.frame is not allowed the rownames to be equal
#So, we copy the rownames into the first column, which will be used later in MANOVA as a category variable (in R terminology: factor variable).
#more sophisticated sample
#tmp=data.frame(segmMethod=rn)
#rownames(D)=NULL
#tmp$segmMethod=as.factor(tmp$segmMethod)
#sample
#    segmMethod
#1           MS
#2           MS
#3           MS

#D=cbind(tmp,D)

#dplyr::sample_n(D[,1:2], 10)
#   segmMethod original_shape_Elongation
#1       MS                 0.8660596
#2     n502                 0.6453799
#3       RE                 0.7169433
#4     n535                 0.6350440
#5     n535                 0.5686323
#6     n535                 0.9004547
#7     n535                 0.7631601
#8     n502                 0.7437210
#9       MS                 0.8441119
#10      RE                 0.5192078

#str(D[,1:3])
#'data.frame':	125 obs. of  3 variables:
# $ segmMethod               : Factor w/ 125 levels "MS","MS.1","MS.10",..: 1 2 13 22 23 24 25 26 27 28 ...
# $ original_shape_Elongation: num  0.953 0.669 0.866 0.817 0.829 ...
# $ original_shape_Flatness  : num  0.743 0.634 0.723 0.548 0.774 ...

df_long=data.frame()
for(f in seq(1,ncol(D)-2) )  #run through rad param names
{
    for(row in seq(1,nrow(D)))  #run through patients
    {
        #print(paste(f,", ",row))
        df_long = rbind(df_long, data.frame(feature=colnames(D)[f], subject=D[row,108], method=D[row,109], value=D[row,f]))
    }
}

#check the conversion
#D[which(D$subject=="p031"),c( which(colnames(D)=="original_shape_Maximum2DDiameterColumn"),108,109)];df_long[550,]

