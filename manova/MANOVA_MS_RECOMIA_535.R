#idea: https://www.sthda.com/english/wiki/one-way-anova-test-in-r

#this line will load dm,dr,d502,d535 and puts them together into D
source("/Users/leduc/Downloads/ICC/dataInput.r")

###################
# normality check #
###################
#install.packages("mvnormtest")
#library("mvnormtest")

#dm,dr,d502,d535

#the header of first column must be "Case" w/o quotation marks
dmNorm=vector()
drNorm=vector()
d502Norm=vector()
d535Norm=vector()
for ( col_idx in 1:ncol(dm)   ){pv=0; try(pv<<-shapiro.test(as.numeric(  dm[,col_idx]))$p.value, silent=TRUE); if(pv>=0.05){   dmNorm = c(   dmNorm,   colnames(dm)[col_idx] ) } }
for ( col_idx in 1:ncol(dr)   ){pv=0; try(pv<<-shapiro.test(as.numeric(  dr[,col_idx]))$p.value, silent=TRUE); if(pv>=0.05){   drNorm = c(   drNorm,   colnames(dr)[col_idx] ) } }
for ( col_idx in 1:ncol(d502) ){pv=0; try(pv<<-shapiro.test(as.numeric(d502[,col_idx]))$p.value, silent=TRUE); if(pv>=0.05){ d502Norm = c( d502Norm, colnames(d502)[col_idx] ) } }
for ( col_idx in 1:ncol(d535) ){pv=0; try(pv<<-shapiro.test(as.numeric(d535[,col_idx]))$p.value, silent=TRUE); if(pv>=0.05){ d535Norm = c( d535Norm, colnames(d535)[col_idx] ) } }

#radiomics_SUV.original_shape_MajorAxisLength  ->  original_shape_MajorAxisLength
#drNorm=gsub("^.*SUV.","",drNorm)
#Case-1_original_shape_Elongation:  ->  original_shape_Elongation
#d535Norm=gsub("Case-1_(.*):","\\1",d535Norm)
d535Norm=gsub("Case-1_(.*)","\\1",d535Norm)

#hold radiomic parameters that do meet the normality condition

#we need to exclude n502, because there is no common part with the others, So, we keep n535 model
#dm=manual, dr=recomia, d535=nnunet535
DepVars = intersect(intersect(dmNorm,drNorm),d535Norm)

# Print parameters used in tests (passed normality) #

if (length(DepVars) > 0) {
  for (p in DepVars) {
    cat("-", p, "\n")
  }
} else {
  cat("No parameters passed the normality check.\n")
}

#indices
normindices=which(colnames(D)%in%DepVars)

###################################
# check the equality of variances #
###################################
#e.g. var.test(weight ~ group, data = my_data)

#subset of D with columns meet normality check and the first column which describes the categories: MS,RE,n502m 535
Dsub=D[c(1,normindices)]
#we remove rows coming from n502
Dsub=Dsub[-which(Dsub$segmMethod=='n502'),]
#refactorization of category var
Dsub$segmMethod=factor(Dsub$segmMethod)


#look into data
library(dplyr)
group_by(Dsub, segmMethod) %>%
  summarise(
    count = n(),
    mean1 = mean(original_shape_SurfaceVolumeRatio, na.rm = TRUE),

    sd1 = sd(original_shape_SurfaceVolumeRatio, na.rm = TRUE),
  )
library(car)
leveneTest(original_shape_SurfaceVolumeRatio ~ segmMethod, data = Dsub)


#################
# (M)ANOVA test #
#################
#special, non parametric alternative for anova: Welch one-way test: oneway.test()
oneway.test(original_shape_SurfaceVolumeRatio ~ segmMethod, data = Dsub)

pairwise.t.test(Dsub$original_shape_SurfaceVolumeRatio, Dsub$segmMethod, p.adjust.method = "BH", pool.sd = FALSE)

oneway.test(original_glrlm_RunEntropy ~ segmMethod, data = Dsub)

pairwise.t.test(Dsub$original_glrlm_RunEntropy, Dsub$segmMethod, p.adjust.method = "BH", pool.sd = FALSE)

# MANOVA
manova_model <- manova(cbind(original_shape_SurfaceVolumeRatio, original_glrlm_RunEntropy) ~ segmMethod, data = Dsub)
summary(manova_model, test = "Wilks")  # Wilks' Lambda
summary(manova_model, test = "Pillai") # Pillai's Trace

# Follow-up univariate ANOVAs
summary.aov(manova_model)
