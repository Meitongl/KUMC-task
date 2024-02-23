library(dplyr)
library(tidyr)
library(data.table)

## Data 1: genes in the human genome
# read the gene file
file_path <- "E:/桌/KUMC task/hiring_task/Homo_sapiens.gene_info.gz"
Homo_sapiens <- read.delim(gzfile(file_path), header = T, quote = "", stringsAsFactors = FALSE)

View(Homo_sapiens)

# select interested variable
Homo_sapiens <- Homo_sapiens[, c(2, 3, 5)]

# extract gene names from Synonyms and combine
extract_gene <- function(synonyms) {
  gene_names <- unlist(strsplit(as.character(synonyms), "|", fixed = TRUE))
  gene_names <- gene_names[gene_names != ""]
  return(gene_names)
}
gene_synonyms <- lapply(Homo_sapiens$Synonyms, extract_gene)

gene_combined <- data.frame(
  GeneID = rep(Homo_sapiens$GeneID, sapply(gene_synonyms, length)),
  Symbol = rep(Homo_sapiens$Symbol, sapply(gene_synonyms, length)),
  Synonym = unlist(gene_synonyms)
)

symbol_to_geneid_mapping <- gene_combined %>%
  group_by(GeneID) %>%
  summarize(combine = list(unique(c(Synonym, Symbol)))) %>%
  unnest(combine)

colnames(symbol_to_geneid_mapping)=c("GeneID","Symbol")
View(symbol_to_geneid_mapping)

# Print the mapping
print(symbol_to_geneid_mapping)


##########################################################################################################################

## Data 2: gene matrix transposed file
# read gmt file 

gmt_file<- "E:/桌/KUMC task/hiring_task/h.all.v2023.1.Hs.symbols.gmt"
gmt_file<- readLines(gmt_file)

# replace with symbols with Entrez IDs
new_gmt <- c()

for (line in gmt_file) {
  # Split each line by tab
  data <- unlist(strsplit(line, "\t"))
  
  # Extract pathway name and description
  pathway_name <- data[1]
  pathway_description <- data[2]
  
  # Extract gene names from the rest of the fields
  gene_names <- data[-c(1, 2)]

  # Map gene names to Entrez ID
  entrez_ids <- symbol_to_geneid_mapping$GeneID[match(gene_names, symbol_to_geneid_mapping$Symbol)]
  
  # Replace gene names with Entrez ID in the line
  for (i in seq_along(gene_names)) {
    if (length(entrez_ids) > 0) {
      data[2 + i] <- entrez_ids[i]
    }else {
      data[2 + i] <- NA  # Replace with empty string if no Entrez ID
    }
  }
  
  new_gmt <- c(new_gmt, paste(data, collapse = "\t"))
}

# generate new gmt file
writeLines(new_gmt, "E:/桌/KUMC task/hiring_task/new.gmt", useBytes = TRUE)
