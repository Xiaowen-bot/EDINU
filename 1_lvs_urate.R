#############################################################################################
#
# 12/2024
# The purpose of this program is to extract the urate metabolite data for the LVS for 
# subsequent merging with dietary data
#
#############################################################################################

# Run this code to install the chanmetab package 
# which is needed for the merge_metab_data function
# devtools::install("/proj/nhmngs/nhmng00/R/chanmetab", build_vignettes = TRUE, upgrade = FALSE)
# install.packages("MetabolAnalyze")
# install.packages("rlist")
# install.packages("ppcor")
# install.packages("ggplot2")
# Load the required packages
library(chanmetab)
library(dplyr) 
library(readxl)
library(readr)
library(tidyverse)
# library(MetabolAnalyze)
library(rlist)
# library(ppcor)
library(gdata)
# library(xlsx)
library(caret)
library(glmnet)
library(dplyr)
library(ggplot2)


# Set your working directory 
setwd("/udd/n2xwa/urate_Wang")
getwd()


################# Code from Yang Hu emailed on 09/22/2023 #################

lvs.lnz.new <- merge_metab_data(endpoints = c("lvs"),
                                collection_to_use = "substudy",
                                # cohorts="hpfs",
                                # methods = c("C8-pos", "HILIC-neg", "HILIC-pos"),
                                transformation = "transform_ln_z_score",
                                keep_unknown_metabolites = F,
                                keep_failed_pm_metabolites = F,
                                impute_cutoff=0.05)

temp_met<-as.data.frame(t(lvs.lnz.new$expr_set$hpfs@assayData$exprs))
temp_met$id<-substr(rownames(temp_met),1,6) # creates a new variable ID

# Create a data frame 
temp_phe<-as.data.frame(lvs.lnz.new$expr_set$hpfs@phenoData@data)
temp_phe$id<-substr(temp_phe$id,1,6) # again creates a new variable ID

lvs_hpfs_pm<-merge(temp_phe,temp_met) # metabolite and phenotype data


# Create a data frame 
lvs_hpfs_fea<-as.data.frame(lvs.lnz.new$expr_set$hpfs@featureData@data)
# this contains metabolite information such as their name etc 

################# Now adapt this from here #################

names(lvs_hpfs_pm)
lvs_hpfs_final = subset(lvs_hpfs_pm, select = c(id, cohort, HMDB0000289,HMDB0000562))

# NHS1 #
temp_met<-as.data.frame(t(lvs.lnz.new$expr_set$nhs1@assayData$exprs))
temp_met$id<-substr(rownames(temp_met),1,6) # creates a new variable ID
temp_phe<-as.data.frame(lvs.lnz.new$expr_set$nhs1@phenoData@data)
temp_phe$id<-substr(temp_phe$id,1,6) # again creates a new variable ID
lvs_nhs1_pm<-merge(temp_phe,temp_met) # metabolite and phenotype data
lvs_nhs1_fea<-as.data.frame(lvs.lnz.new$expr_set$nhs1@featureData@data)

names(lvs_nhs1_pm)
lvs_nhs1_final = subset(lvs_nhs1_pm, select = c(id, cohort, HMDB0000289,HMDB0000562))

# NHS2 #
temp_met<-as.data.frame(t(lvs.lnz.new$expr_set$nhs2@assayData$exprs))
temp_met$id<-substr(rownames(temp_met),1,6) # creates a new variable ID
temp_phe<-as.data.frame(lvs.lnz.new$expr_set$nhs2@phenoData@data)
temp_phe$id<-substr(temp_phe$id,1,6) # again creates a new variable ID
lvs_nhs2_pm<-merge(temp_phe,temp_met) # metabolite and phenotype data
lvs_nhs2_fea<-as.data.frame(lvs.lnz.new$expr_set$nhs2@featureData@data)

names(lvs_nhs2_pm)
lvs_nhs2_final = subset(lvs_nhs2_pm, select = c(id, cohort, HMDB0000289,HMDB0000562)) 
lvs_all_final <- dplyr::bind_rows(lvs_hpfs_final, lvs_nhs1_final, lvs_nhs2_final)

################# Merge with dietary data #################

############################################################################
#
# July 9, 2024
# Alternatively can merge with the dietary data in R instead of in SAS
#
############################################################################

# Read in the dietary dataset prepared by Yang Hu
lvs_diet <- read.csv("/udd/hpyah/project/food_biomarker/lvs_diet.csv")

names(lvs_diet)
table(lvs_diet$women)

lvs_cb <- merge(lvs_all_final,lvs_diet,by.x="id") # specify that need to have observation in metab dataset


### Get rid of unnecessary variables (keep id, covariates of interest, serum urate, and all foods)

names(lvs_cb)
lvs_cb_final <- lvs_cb %>% dplyr::select(id, women, ageyr, act, alco, calor, smoke, white, bmi,
                                           cohort, HMDB0000289,HMDB0000562, skim07:crucif07)

# group food data 

lvs_cb_final <- mutate(
  lvs_cb_final,
  apple   = rowSums(cbind(appl07), na.rm = TRUE),
  avo     = rowSums(cbind(avo07), na.rm = TRUE),
  beer    = rowSums(cbind(lbeer07, beer07), na.rm = TRUE),
  blueb   = rowSums(cbind(blueb07), na.rm = TRUE),
  candy   = rowSums(cbind(cdyw07, cdywo07), na.rm = TRUE),
  cereal  = rowSums(cbind(cer07), na.rm = TRUE),
  cheese  = rowSums(cbind(otch07, cotch07, crmch07), na.rm = TRUE),
  choc    = rowSums(cbind(dchoc07, mchoc07), na.rm = TRUE),
  citrus  = rowSums(cbind(oran07, grfr07), na.rm = TRUE),  # Note that the grapefruit variable includes juice
  coffee  = rowSums(cbind(coff07, decaf07), na.rm = TRUE),
  cond    = rowSums(cbind(jam07, ketch07, marg07), na.rm = TRUE),
  corn    = rowSums(cbind(corn07, ffpop07, popc07), na.rm = TRUE),
  cruc    = rowSums(cbind(brocc07, bruss07, cabb07, cauli07, kale07), na.rm = TRUE),
  daidess = rowSums(cbind(icecr07, sherb07), na.rm = TRUE),
  dessert = rowSums(cbind(cokh07, coknf07, cokr07, cakh07, pieh07, srolf07, srolh07, srolr07, donut07), na.rm = TRUE),
  dietbev = rowSums(cbind(lccaf07, lcnoc07), na.rm = TRUE),
  egg     = rowSums(cbind(egg07, eggom07), na.rm = TRUE),
  fish    = rowSums(cbind(bfsh07, dkfsh07, ofish07, ctuna07, shrim07), na.rm = TRUE),
  rmeat   = rowSums(cbind(bmain07, bmix07, hamb07, hambl07, pmain07), na.rm = TRUE),
  juice   = rowSums(cbind(aj07, prunj07, othj07), na.rm = TRUE),
  grape   = rowSums(cbind(rais07), na.rm = TRUE),
  hidai   = rowSums(cbind(sbu07, cream07), na.rm = TRUE),
  himilk  = rowSums(cbind(whole07), na.rm = TRUE),
  lett    = rowSums(cbind(ilett07, rlett07), na.rm = TRUE),
  liq     = rowSums(cbind(liq07), na.rm = TRUE),
  lomilk  = rowSums(cbind(m1or207, skim07), na.rm = TRUE),
  mayo    = rowSums(cbind(lmayo07, mayo07), na.rm = TRUE),
  bar     = rowSums(cbind(brbar07, enbar07, lcbar07), na.rm = TRUE),
  misc    = rowSums(cbind(misc07), na.rm = TRUE),
  nightsh = rowSums(cbind(eggpl07, grpep07), na.rm = TRUE),
  nuts    = rowSums(cbind(onut07, wnut07, pwnut07), na.rm = TRUE),
  onion   = rowSums(cbind(oniog07, oniov07), na.rm = TRUE),
  oj      = rowSums(cbind(oj07, ojca07), na.rm = TRUE),
  liver   = rowSums(cbind(livb07, livc07), na.rm = TRUE),
  othfru  = rowSums(cbind(ban07, cant07), na.rm = TRUE),
  leg     = rowSums(cbind(peas07, rsbean07wkt, bean07), na.rm = TRUE),
  othveg  = rowSums(cbind(mixv07), na.rm = TRUE),
  peanut  = rowSums(cbind(pbut07, pnut07), na.rm = TRUE),
  pizza   = rowSums(cbind(pizza07), na.rm = TRUE),
  potato  = rowSums(cbind(fries07, pot07, pchip07), na.rm = TRUE),
  poultry = rowSums(cbind(chwi07, chwo07, chksa07), na.rm = TRUE),
  prmeat  = rowSums(cbind(bacon07, pmsan07, procm07, ctdog07, dog07), na.rm = TRUE),
  rgrain  = rowSums(cbind(whbr07, wrice07, pcake07, engl07, muff07, pasta07, wbrice07, tort07), na.rm = TRUE),
  dress   = rowSums(cbind(dress07), na.rm = TRUE),
  savsnk  = rowSums(cbind(crack07, pretz07), na.rm = TRUE),
  soup    = rowSums(cbind(chowd07), na.rm = TRUE),
  soy     = rowSums(cbind(tofu07, soy07), na.rm = TRUE),
  spin    = rowSums(cbind(cspin07, rspin07), na.rm = TRUE),
  straw   = rowSums(cbind(straw07), na.rm = TRUE),
  ssb     = rowSums(cbind(cola07, otsug07, punch07), na.rm = TRUE),
  tea     = rowSums(cbind(dtea07, tea07), na.rm = TRUE),
  tom     = rowSums(cbind(rtoj0ywkt, rtosau0ywkt, salsa07, tom07), na.rm = TRUE),
  umb     = rowSums(cbind(ccar07, cel07, rcar07), na.rm = TRUE),
  wgrain  = rowSums(cbind(bran07, brice07, dkbr07, ckcer07, oat07, oatbr07, ryebr07), na.rm = TRUE),
  wine    = rowSums(cbind(rwine07, wwine07), na.rm = TRUE),
  yelveg  = rowSums(cbind(osqua07, yam07), na.rm = TRUE),
  yelfru  = rowSums(cbind(prune07, apric07, peach07), na.rm = TRUE),
  yog     = rowSums(cbind(flyog07, plyog07), na.rm = TRUE),
 # artswt  = rowSums(cbind(otswt07, splnd07), na.rm = TRUE),
    egg = ifelse(egg < 0, 0, egg),
    bmi = tidyr::replace_na(bmi, median(bmi, na.rm = TRUE))
  )

write.csv(lvs_cb_final, "lvs_cb_final.csv")

#############################################################################################

# Analysis among LVS with low eGFR
# calculate eGFR

#############################################################################################

# eGFR calculation based on MDRD equation
calculate_eGFR <- function(scr, age, women) {
  if (women == "1") {
    eGFR <- 175 * (scr)^(-1.154) * (age)^(-0.203) * 0.742 
  } else {
    eGFR <- 175 * (scr)^(-1.154) * (age)^(-0.203)
  }
  return(eGFR)
}

lvs_cb_final$scr <- lvs_cb_final$HMDB0000562 + abs(min(lvs_cb_final$HMDB0000562, na.rm = TRUE))
lvs_cb_final$eGFR <- mapply(calculate_eGFR,lvs_cb_final$scr,lvs_cb_final$ageyr,  lvs_cb_final$women)

tertiles <- quantile(lvs_cb_final$eGFR, probs = c(0, 1/3, 2/3, 1), na.rm = TRUE)
lvs_cb_final$eGFR_group2 <- cut(lvs_cb_final$eGFR, 
                                breaks = tertiles, 
                                labels = c("low", "medium", "high"), 
                                include.lowest = TRUE)

# women=0 tertiles
tertiles_w0 <- quantile(lvs_cb_final$eGFR[lvs_cb_final$women == 0], probs = c(0, 1/3, 2/3, 1), na.rm = TRUE)

# women=1 tertiles
tertiles_w1 <- quantile(lvs_cb_final$eGFR[lvs_cb_final$women == 1], probs = c(0, 1/3, 2/3, 1), na.rm = TRUE)

# women=0 eGFR
lvs_cb_final$eGFR_group2[lvs_cb_final$women == 0] <- cut(lvs_cb_final$eGFR[lvs_cb_final$women == 0], 
                                                         breaks = tertiles_w0, 
                                                         labels = c("low", "medium", "high"), 
                                                         include.lowest = TRUE)

# women=1 eGFR
lvs_cb_final$eGFR_group2[lvs_cb_final$women == 1] <- cut(lvs_cb_final$eGFR[lvs_cb_final$women == 1], 
                                                         breaks = tertiles_w1, 
                                                         labels = c("low", "medium", "high"), 
                                                         include.lowest = TRUE)
table(lvs_cb_final$eGFR_group2)

# subgroup

mlvs_cb_final <- lvs_cb_final %>% 
  filter(eGFR_group2 == "low")

###########################lasso method#############################################

library(caret)
library(glmnet)

# Define the lasso function
lasso <- function(var, hmdb_incl){
  x <- mlvs_cb_final[, hmdb_incl]
  y <- mlvs_cb_final[, var]
  z <- as.data.frame(scale(cbind(x, y)))
  # Split the data into training set and test set (70/30)
  set.seed(123)
  n <- floor(nrow(z) * 0.7)
  train_ind <- sample(seq_len(nrow(z)), size = n)
  test_ind <- setdiff(seq_len(nrow(z)), train_ind)
  train <- z[train_ind, ]
  test <- z[test_ind, ]
  
  # Train the lasso model using LOOCV
  lasso_mdl <- train(y ~ ., data = train, method = "glmnet", 
                     trControl = trainControl(method = "LOOCV"),
                     tuneGrid = expand.grid(alpha = 1, lambda = 10^seq(-3, -1, length = 201)))
  
  # Get the coefficients
  lasso_coef <- coef(lasso_mdl$finalModel, lasso_mdl$bestTune$lambda)
  
  # Predict the scores for both training and test sets
  predicted_scores_train <- predict(lasso_mdl, newdata = train)
  predicted_scores_test <- predict(lasso_mdl, newdata = test)
  
  return(list(lasso_coef = lasso_coef[-1], train = train, test = test, 
              predicted_scores_train = predicted_scores_train, 
              predicted_scores_test = predicted_scores_test,
              train_ind = train_ind, test_ind = test_ind))
}

# Apply the function and obtain results
lasso_uric <- lasso("HMDB0000289", colnames(mlvs_cb_final)[203:260]) # food

# Retrieve the predicted scores and indices
predicted_scores_train <- lasso_uric$predicted_scores_train
predicted_scores_test <- lasso_uric$predicted_scores_test
train_ind <- lasso_uric$train_ind
test_ind <- lasso_uric$test_ind

# Add `predicted_scores` column to the original dataframe
mlvs_cb_final$predicted_scores <- NA
mlvs_cb_final$predicted_scores[train_ind] <- predicted_scores_train
mlvs_cb_final$predicted_scores[test_ind] <- predicted_scores_test

# Check the dataframe
head(mlvs_cb_final)

met_list <- colnames(mlvs_cb_final[c(203:260)])


lasso_coef_uric <- lasso_uric$lasso_coef
lasso_coef_df <- data.frame(
  feature = met_list,
  coefficient = as.numeric(lasso_coef_uric)
)

met_uric <- lasso_coef_df %>% filter(coefficient!= 0.00) %>% pull(feature)
met_uric
uric_coef <- lasso_coef_df %>% filter(coefficient!= 0.00) %>% pull(coefficient) 
uric_coef

## draw food index coefficient plot ##
met_uric <- c("blueberry", "cheese", "artificially-sweetened beverages", "red meat", "grape", "liquor","low-fat milk","liver","mixed vegetables",
              "dressing","tomato products","wine")
data <- data.frame(
  FoodItem = met_uric,
  Coefficient = uric_coef
)

data <- data[order(data$Coefficient), ]

bar <- ggplot(data, aes(x = Coefficient, y = reorder(FoodItem, Coefficient), fill = Coefficient > 0)) +
  geom_bar(stat = "identity") +
  scale_fill_manual(values = c("TRUE" = "#F0654D", "FALSE" = "#5CA9F5"), guide = FALSE) +
  theme_minimal() +
  labs(title = "Food groups",
       x = "Coefficient",
       y = "") +
  theme(
    axis.text.x = element_text(face = "bold", size = 12),  # Make x-axis labels bold and larger
    axis.text.y = element_text(face = "bold", angle = 0, hjust = 1, size = 12),
    axis.title.x = element_text(face = "bold")
  )

# Print the plot
print(bar)
ggsave("food_groups_plot.png", plot = bar, width = 8, height = 8, dpi = 1200)

## draw food index and urate correlation plot ##

train <- as.data.frame(lasso_uric$train)
test <- as.data.frame(lasso_uric$test)

lasso_coef_uric <- as.data.frame(lasso_coef_uric)
lasso_coef_uric <- apply(lasso_coef_uric, 2, as.numeric)

# Flip the coeffecient for EDIEU
train_score <- as.matrix(train[,met_list])%*%as.vector(-lasso_coef_uric)
test_score <- as.matrix(test[,met_list])%*%as.vector(-lasso_coef_uric) 


cor_pearson_train <- cor(train$y, train_score, method = "pearson")
cor_spearman_train <- cor(train$y, train_score, method = "spearman")
cor_pearson_test <- cor(test$y, test_score, method = "pearson")
cor_spearman_test <- cor(test$y, test_score, method = "spearman")

print(cor_pearson_train)
print(cor_spearman_train)
print(cor_pearson_test)
print(cor_spearman_test)

plot1 <- ggplot(train, aes(x = train_score, y = y)) +
  geom_point(alpha = 0.5, color = "#1B3A4B") +
  geom_smooth(method = "lm", se = FALSE, color = "#2A9D8F")+
  theme_minimal() +
  labs(title = paste("Correlation (Training) :", round(cor_pearson_train, 2)),
       x = "EDIEU",
       y = "Urate(ln-Z)")+
  ylim(-2, 2) +
  xlim(-0.4, 0.4)+
  theme(
    axis.text.x = element_text(face = "bold", size = 12),  # Make x-axis labels bold and larger
    axis.text.y = element_text(face = "bold", angle = 0, hjust = 1, size = 12),
    axis.title.x = element_text(face = "bold"),
    axis.title.y = element_text(face = "bold")
  )

plot2 <- ggplot(test, aes(x = test_score, y = y)) +
  geom_point(alpha = 0.5, color = "#1B3A4B") +
  geom_smooth(method = "lm", se = FALSE, color = "#2A9D8F")+
  theme_minimal() +
  labs(title = paste("Correlation (Testing):", round(cor_pearson_test, 2)),
       x = "EDIEU",
       y = "Urate(ln-Z)")+
  ylim(-2, 2)  +
  xlim(-0.4, 0.4)+
  theme(
    axis.text.x = element_text(face = "bold", size = 12),  # Make x-axis labels bold and larger
    axis.text.y = element_text(face = "bold", angle = 0, hjust = 1, size = 12),
    axis.title.x = element_text(face = "bold"),
    axis.title.y = element_text(face = "bold")
  )
  
library(gridExtra)
combined_plot <- grid.arrange(plot1, plot2,  ncol = 2)
# Save the combined plot as a PNG file
ggsave("combined_plot.png", combined_plot, width = 16, height = 20,dpi = 600)

library(ggpubr)

# Arrange the two plots
figure1 <- ggarrange(
  bar,                        # First row
  combined_plot,                         # Second row
  labels = c("A", "B"),             # Labels for each plot
  ncol = 2,                         # One column (stacked rows)
  nrow = 1,                         # Two rows
  heights = c(1, 1)                 # Equal heights for the two rows
)

figure1
ggsave("/udd/n2xwa/urate_Wang/figure1.png", figure1, width = 20, height = 16,dpi = 800)

carbo_ela <- list(test, train, met_uric, uric_coef)
save(carbo_ela, file = "low_uric_lasso.RData")


# calculate correlation between selected food groups and urate
corr_mlvs <- mlvs_cb_final
corr_mlvs$m_predicted_scores <- - corr_mlvs$predicted_scores

colnames(corr_mlvs)[colnames(corr_mlvs) == "HMDB0000289"] <- "urate"
# colnames(corr_mlvs)[colnames(corr_mlvs) == "cheese"] <- "cheese"
colnames(corr_mlvs)[colnames(corr_mlvs) == "dietbev"] <- "artificiallysweetened_beverages"
colnames(corr_mlvs)[colnames(corr_mlvs) == "rmeat"] <- "red_meat"
colnames(corr_mlvs)[colnames(corr_mlvs) == "liq"] <- "liquor"
colnames(corr_mlvs)[colnames(corr_mlvs) == "lomilk"] <- "lowfat_milk"
colnames(corr_mlvs)[colnames(corr_mlvs) == "dress"] <- "dressing"
# colnames(corr_mlvs)[colnames(corr_mlvs) == "liver"] <- "liver"
colnames(corr_mlvs)[colnames(corr_mlvs) == "tom"] <- "tomato_products"
# colnames(corr_mlvs)[colnames(corr_mlvs) == "wine"] <- "wine"
colnames(corr_mlvs)[colnames(corr_mlvs) == "blueb"] <- "blueberry"
# colnames(corr_mlvs)[colnames(corr_mlvs) == "grape"] <- "grape"
colnames(corr_mlvs)[colnames(corr_mlvs) == "othveg"] <- "mixed_vegetables"
colnames(corr_mlvs)[colnames(corr_mlvs) == "m_predicted_scores"] <- "EDIEU"

selected_vars <- corr_mlvs[, c("urate", "cheese", "artificiallysweetened_beverages", "red_meat", 
                               "liquor", "lowfat_milk", "dressing", "liver", 
                               "tomato_products","wine", "blueberry", "grape", 
                               "mixed_vegetables","EDIEU")]

cor_matrix <- cor(selected_vars, use = "complete.obs", method = "spearman")


urate_correlation <- cor_matrix["urate", ]
urate_correlation_df1 <- data.frame(
  Variable = names(urate_correlation),
  Correlation = urate_correlation
)
urate_correlation_df1 <- urate_correlation_df1[urate_correlation_df1$Variable != "urate", ]
fixed_order <- c("cheese", "artificiallysweetened_beverages", "red_meat", 
                 "liquor", "lowfat_milk", "dressing", "liver", 
                 "tomato_products","wine", "blueberry", "grape", 
                 "mixed_vegetables","EDIEU")
library(reshape2)
urate_correlation_long <- melt(urate_correlation_df1)

ggplot(urate_correlation_long, aes(x = factor(Variable, levels = fixed_order), y = "urate", fill = value)) +
  geom_tile(color = "white") +
  geom_text(aes(label = round(value, 2)), color = "black") +
  scale_fill_gradient2(low = "#3C8DAD", mid = "white", high = "#FF6767", midpoint = 0, name = "Correlation") +
  labs(title = "",
       x = "",
       y = "LVS") +
  theme_minimal() +
  theme(
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank())

