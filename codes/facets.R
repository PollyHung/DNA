# Load required libraries
library(dplyr)
library(magrittr)
library(facets)

# Define paths (relative to current working directory)
samples <- c("Kura_A15_DNA", "Kura_A2_DNA", "Kura_GFP_DNA", 
             "OAW28_A14_DNA", "OAW28_A16_DNA", "OAW28_GFP_DNA")

base_dir <- "~/Desktop/WES/pileup/"
datafile <- file.path(base_dir, paste0(samples, ".snp-pileup.csv.gz"))
cncf_csv <- file.path(base_dir, paste0(samples, ".cncf.csv"))
plot_pdf <- file.path(base_dir, paste0(samples, ".facets_plot.pdf"))
rdata <- file.path(base_dir, paste0(samples, ".RData"))

# Read and process pileup data
pileup <- read.csv(gzfile(datafile), 
                   colClasses = rep(c("character", "numeric", "character", "numeric"), c(1,1,2,8)),
                   stringsAsFactors = FALSE)
pileup$Chromosome <- factor(pileup$Chromosome, levels = c(1:22, "X", "Y"), ordered = TRUE) 
pileup <- pileup %>% arrange(Chromosome, Position)

# Filter valid positions
ii <- which(pileup$File1E <= Inf & 
              pileup$File1D <= Inf & 
              pileup$File2E <= Inf & 
              pileup$File2D <= Inf)
rcmat <- pileup[ii, c("Chromosome", "Position")]
rcmat$NOR.DP <- pileup$File1R[ii] + pileup$File1A[ii]
rcmat$NOR.RD <- pileup$File1R[ii]
rcmat$TUM.DP <- pileup$File2R[ii] + pileup$File2A[ii]
rcmat$TUM.RD <- pileup$File2R[ii]

# Run FACETS pipeline
xx <- preProcSample(rcmat, 
                    het.thresh = 0.10, 
                    snp.nbhd = 150, 
                    cval = 50, 
                    gbuild = "hg38", 
                    unmatched = TRUE)
oo <- procSample(xx, cval = 150) 
fit <- emcncf(oo)

# Generate plot
pdf(plot_pdf, width = 6, height = 4)
plotSample(oo, emfit = fit)
logRlogORspider(oo$out, oo$dipLogR)
dev.off()

# Save results
cncf <- fit$cncf
write.csv(cncf, cncf_csv, row.names = FALSE)
save(xx, oo, fit, file = rdata)







