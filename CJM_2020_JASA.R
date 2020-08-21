######################################################################
# Empirical Illustration
# M.D. Cattaneo, M. Jansson, X. Ma
# 21-AUG-2020
######################################################################

# install.packages("ggplot2")
# install.packages("lpdensity")
# install.packages("rddensity")
# install.packages("rdd")

# NOTE: if you are using RDDENSITY version 2020 or newer, the option 
# masspoints=FALSE may be needed to replicate the results in the monograph.
# For example:
#    out = rddensity(X)
# should be replaced by:
#    out = rddensity(X,masspoints=FALSE)

######################################################################
######################################################################
# Headstart Data
######################################################################
######################################################################
rm(list=ls(all=TRUE))
library(foreign); library(MASS); library(Hmisc)
library(rddensity); library(lpdensity); library(ggplot2); library(rdd)

data <- read.csv("headstart.csv", header=T)
data$povrate60 <- data$povrate60 - 59.198
X <- data[!is.na(data[, "povrate60"]), "povrate60"]

######################################################################
# Table: Manipulation Testing
######################################################################
Result <- matrix(NA, ncol=8, nrow=7)
colnames(Result) <- c("hl", "hr", "nhl", "nhr", "t", "pval", "binl", "binr")

j <- 1
model <- rddensity(X, p=1, bwselect="each")
Result[j, 1] <- model$h$left    ; Result[j, 2] <- model$h$right
Result[j, 3] <- model$N$eff_left; Result[j, 4] <- model$N$eff_right
Result[j, 5] <- model$test$t_jk ; Result[j, 6] <- model$test$p_jk

j <- j + 1
model <- rddensity(X, p=2, bwselect="each")
Result[j, 1] <- model$h$left    ; Result[j, 2] <- model$h$right
Result[j, 3] <- model$N$eff_left; Result[j, 4] <- model$N$eff_right
Result[j, 5] <- model$test$t_jk ; Result[j, 6] <- model$test$p_jk

j <- j + 1
model <- rddensity(X, p=3, bwselect="each")
Result[j, 1] <- model$h$left    ; Result[j, 2] <- model$h$right
Result[j, 3] <- model$N$eff_left; Result[j, 4] <- model$N$eff_right
Result[j, 5] <- model$test$t_jk ; Result[j, 6] <- model$test$p_jk

j <- j + 1
model <- rddensity(X, p=1, bwselect="diff")
Result[j, 1] <- model$h$left    ; Result[j, 2] <- model$h$right
Result[j, 3] <- model$N$eff_left; Result[j, 4] <- model$N$eff_right
Result[j, 5] <- model$test$t_jk ; Result[j, 6] <- model$test$p_jk

j <- j + 1
model <- rddensity(X, p=2, bwselect="diff")
Result[j, 1] <- model$h$left    ; Result[j, 2] <- model$h$right
Result[j, 3] <- model$N$eff_left; Result[j, 4] <- model$N$eff_right
Result[j, 5] <- model$test$t_jk ; Result[j, 6] <- model$test$p_jk

j <- j + 1
model <- rddensity(X, p=3, bwselect="diff")
Result[j, 1] <- model$h$left    ; Result[j, 2] <- model$h$right
Result[j, 3] <- model$N$eff_left; Result[j, 4] <- model$N$eff_right
Result[j, 5] <- model$test$t_jk ; Result[j, 6] <- model$test$p_jk

McCrary <- DCdensity(runvar = X, cutpoint = 0, verbose = TRUE, plot = TRUE, ext.out = TRUE)
Result[7, 7] <- sum(McCrary$data$cellmp < 0); Result[7, 8] <- sum(McCrary$data$cellmp >= 0)
Result[7, 1] <- Result[7, 2] <- McCrary$bw
Result[7, 3] <- sum(McCrary$data$cellmp <  0 & McCrary$data$cellmp >= -1 * McCrary$bw)
Result[7, 4] <- sum(McCrary$data$cellmp >= 0 & McCrary$data$cellmp <=      McCrary$bw)
Result[7, 5] <- McCrary$z; Result[7, 6] <- McCrary$p

latex(round(Result[, c(7:8, 1:6)], 3),
      file="output/headstart.txt" ,append=FALSE,table.env=FALSE,center="none",title="",
      n.cgroup=c(2,2,2, 2),
      cgroup=c("Pre-binning", "Bandwidths", "Eff. $n$", "Test"),
      colheads=c("left", "right", "left", "right", "left", "right", "$T$", "$p$-val"),
      n.rgroup=c(3, 3, 1), 
      rgroup=c("$h_-\\neq h_+$", "$h_-= h_+$", "McCrary"),
      rowname=c("$T_2(\\hat{h}_1)$", "$T_3(\\hat{h}_2)$", "$T_4(\\hat{h}_3)$", 
                "$T_2(\\hat{h}_1)$", "$T_3(\\hat{h}_2)$", "$T_4(\\hat{h}_3)$", 
                "")
)

######################################################################
# Figure: RD plot, p = 2, different bandwidth on each sides
######################################################################
RDfig <- rddensity(X, bwselect="each") 
RDfig <- rdplotdensity(RDfig, X, plotRange=c(-40, 20), plotN=100, 
                       lcol=c("blue", "red"), xlabel="Running Varaible")$Estplot + 
  scale_x_continuous("", breaks=seq(-40, 20, 20), labels=seq(-40, 20, 20)+59.1984, limits=c(-40, 20)) +
  geom_vline(xintercept=0, linetype="dashed") + ylim(0, 0.032) + theme(legend.position="none")
ggsave("output/headstart_lpdensity.pdf", 
       plot=RDfig, 
       device="pdf", 
       width=8, height=8, units="in")

######################################################################
# Figure: Histogram
######################################################################
data$side <- data$povrate60 > 0
ggsave("output/headstart_hist.pdf", 
       plot=ggplot() + theme(legend.position="none") + theme_bw() + labs(x="Running Variable", y="") + ggtitle("") + 
         geom_histogram(data=data, aes(x=povrate60, alpha=0.8, y=..density..), colour="white", fill=c(rep("blue", 30), rep("red", 20)), 
                        show.legend=F, na.rm=T, position="identity", breaks=seq(-60, 40, 2)) + 
         geom_vline(xintercept=0, linetype="dashed") + ylim(0, 0.035) + 
         scale_x_continuous("", breaks=seq(-40, 20, 20), labels=seq(-40, 20, 20)+59.1984, limits=c(-40, 20)), 
       device="pdf",
       width=8, height=8, units="in")

######################################################################
# Figure: Overlay
######################################################################
overlay <- RDfig + 
  geom_histogram(data=data, aes(x=povrate60, alpha=0.8, y=..density..*0.8858773), colour="grey", fill=c(rep("white", 25), rep("white", 20)), 
                 show.legend=F, na.rm=T, position="identity", breaks=seq(-50, 40, 2))
overlay$layers <- overlay$layers[c(6,1,2,3,4,5)]

ggsave("output/headstart.pdf", 
       plot=overlay, 
       device="pdf",
       width=8, height=8, units="in")