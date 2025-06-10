library(dplyr)
library(magrittr)
library(facets)


set.seed(20020208)
HOME="/home/polly_hung/ccoc/output/facets"
samples <- list.files("/home/polly_hung/ccoc/output/facets/snp-pileup")
samples <- gsub(".snp-pileup.csv", "", samples) %>% unique()


## Define Files 
for(sample in samples){
  
  print(sample)
  
  ## Prepare -------------------------------------------------------------------
  # define file
  datafile <- file.path(HOME, "snp-pileup", paste0(sample, ".snp-pileup.csv"))
  cncf_csv <- file.path(HOME, "facets/cncf", paste0(sample, ".cncf.csv"))
  plot_pdf <- file.path(HOME, "facets/plot", paste0(sample, ".facets_plot.pdf"))
  rdata <- file.path(HOME, "facets/rdata", paste0(sample, ".image.RData"))
  

  ## Run Facets ----------------------------------------------------------------
  # rcmat <-  readSnpMatrix(datafile)
  pileup <- read.csv(datafile, colClasses = rep(c("character", "numeric", "character", "numeric"), c(1, 1, 2, 8)), 
                     stringsAsFactors = FALSE)
  pileup$Chromosome <- factor(pileup$Chromosome, levels = c(1:22, "X", "Y"), ordered = TRUE) 
  pileup <- pileup %>% arrange(Chromosome, Position)
  
  ii <- which(pileup$File1E <= Inf & 
                pileup$File1D <= Inf & 
                pileup$File2E <= Inf & 
                pileup$File2D <= Inf)
  rcmat <- pileup[ii, c("Chromosome", "Position")]
  rcmat$NOR.DP <- pileup$File1R[ii] + pileup$File1A[ii]
  rcmat$NOR.RD <- pileup$File1R[ii]
  rcmat$TUM.DP <- pileup$File2R[ii] + pileup$File2A[ii]
  rcmat$TUM.RD <- pileup$File2R[ii]
  
  xx <- preProcSample(rcmat, 
                      het.thresh = 0.10, 
                      snp.nbhd = 150, 
                      cval = 50, 
                      gbuild = "hg38", 
                      unmatched = TRUE)
  oo <- procSample(xx, cval = 150) 

  ## fitting
  fit <- emcncf(oo)

  # plotting the results and diagnostic plot
  pdf(file = plot_pdf, width = 6, height = 4, title = paste0(sample, " FACETS plot"))
  plotSample(x = oo, emfit = fit)
  logRlogORspider(oo$out, oo$dipLogR)
  dev.off()
  
  ## write the table and save rds object
  cncf <- fit$cncf
  cncf$ordered <- cncf$end >= cncf$start
  write.csv(cncf, cncf_csv, quote = F, col.names = T, row.names = F)
  save.image(rdata)
  
  ## remove everything 
  rm(list = setdiff(ls(), c("samples", "HOME")))
  gc()
}

## combine all output 
cncf_files <- list.files("/home/polly_hung/ccoc/output/facets/facets/cncf")
cncf_list <- lapply(cncf_files, function(x){
  df <- read.csv(x)
  df$sample <- gsub(".cncf.csv", "", x)
  return(df)
})
cncf_df <- do.call(rbind, cncf_list)
cncf_df$ordered2 <- cncf_df$start <= cncf_df$end
write.table(cncf_df, "/home/polly_hung/ccoc/output/facets/gistic2/cncf_df.txt", sep = "\t", quote = F, row.names = F, col.names = T)

## create segmentation 
seg <- cncf_df %>% dplyr::select(sample, chrom, start, end, num.mark, cnlr.median)
colnames(seg) <- c("Sample", "Chromosome", "Start Position", "End Position", "Num Markers", "Seg.CN")
write.table(seg, "/home/polly_hung/ccoc/output/facets/gistic2/segmentation.seg", sep = "\t", quote = F, row.names = F, col.names = T)












