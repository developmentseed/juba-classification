# blocks = read.csv("~/devseed/juba-classification/histograms.csv")
# blocks = reshape(blocks,
#                timevar="category",
#                idvar="gid",
#                direction="wide"
#                )
# households = read.csv("~/devseed/juba-classification/DevSeed_SampleBlocks40_5Nov2015 - Sheet1.csv")
# merged = merge(blocks, households, by.x="gid", by.y="postgis_block", all.x=TRUE)
# fit = lm(households ~ count, data=merged)
# summary(fit)

blocks = read.csv("~/Downloads/juba-blocks-eroded.csv")
all_blocks = read.csv("~/Downloads/juba-blocks-eroded-full.csv")
fit = lm(Households ~ Boma + Class1 + Class2 + Class3 + Class4 + Class5 + Class6 + Class7 + Class8 + Class9 + Class10, data=blocks)
summary(fit)
all_blocks$hh_count_predicted = predict(fit, newdata=all_blocks)

blocks$hh_exist = as.numeric(blocks$Households > 0)
fit = glm(hh_exist ~ Boma + Class1 + Class2 + Class3 + Class4 + Class5 + Class6 + Class7 + Class8 + Class9 + Class10, data=blocks, family=binomial())
summary(fit)
all_blocks$hh_exist_predicted = predict(fit, newdata=all_blocks)

all_blocks = all_blocks[c("Boma", "Block", "hh_count_predicted", "hh_exist_predicted")]
write.csv(all_blocks, file="~/devseed/juba-classification/predicted_values.csv")
