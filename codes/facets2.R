library(dplyr)
library(magrittr)
library(httr)
library(facets)

samples <- c("Kura_A15_DNA", "Kura_A2_DNA", "Kura_GFP_DNA", 
             "OAW28_A14_DNA", "OAW28_A16_DNA", "OAW28_GFP_DNA")

base_dir <- "~/Desktop/WES/pileup/"
datafiles <- file.path(base_dir, paste0(samples, ".snp-pileup.csv.gz"))
cncf_csv <- file.path(base_dir, paste0(samples, ".cncf.csv"))
plot_pdf <- file.path(base_dir, paste0(samples, ".facets_plot.pdf"))
rdata <- file.path(base_dir, paste0(samples, ".RData"))

## execute facets 
for(datafile in datafiles){
   
  ## preprocessing 
  set.seed(1234)
  rcmat <-  readSnpMatrix(datafile)
  xx <- preProcSample(rcmat)
  oo <- procSample(xx) ## cval 100
  
  ## fitting 
  fit <- emcncf(oo)
  
  ## plotting the results and diagnostic plot 
  pdf(paste0("~/MRes_project_1/docs/HH_lung/facets_original/plots/", cancer, ".pdf"), 
      width = 10, height = 7)
  plotSample(x = oo, emfit = fit) %>% print
  logRlogORspider(oo$out, oo$dipLogR) %>% print
  dev.off()
  
  ## write the table and save rds object
  cncf <- fit$cncf
  write.csv(cncf, output, quote = FALSE, col.names = TRUE, row.names = FALSE)
  saveRDS(fit, rds)
  #}
  
  print(paste0("finish running facets on ", cancer))
}


