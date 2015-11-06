blocks = read.csv("~/devseed/juba-classification/histograms.csv")
#blocks = reshape(blocks,
#               timevar="category",
#               idvar="gid",
#               direction="wide"
#               )

households = read.csv("~/devseed/juba-classification/DevSeed_SampleBlocks40_5Nov2015 - Sheet1.csv")

merged = merge(blocks, households, by.x="gid", by.y="postgis_block", all.x=TRUE)

fit = lm(households ~ count, data=merged)
summary(fit)
