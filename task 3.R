library(data.table)
library(GenomicRanges)
library(ggplot2)
library(forcats)
library(dplyr)

# read the gene file
gene_info_path <- "E:/桌/KUMC task/hiriing_task2/Homo_sapiens.gene_info.gz"
gene_info <- read.delim(gzfile(gene_info_path), header = TRUE, stringsAsFactors = FALSE)

# delete rows with ambiguous chromosome values
gene_info <- gene_info[!grepl("\\|", gene_info$chromosome), ]

# count chromosome by symbol
gene_count <- gene_info %>%
  group_by(chromosome) %>%
  summarise(Count = n_distinct(Symbol))

gene_count <- data.frame(gene_count[gene_count$chromosome!=c("-",c("X"),c("Y")),])
View(gene_count)

# order chromosome
gene_count[-c(23,24),"chromosome"]=as.numeric(unlist(gene_count[-c(23,24),"chromosome"]))
gene_count$chromosome <- factor(gene_count$chromosome, levels = c(seq(1,22,1), "MT", "Un"))

# Plot the data using ggplot2
ggplot(gene_count, aes(x = as.factor(chromosome), y = Count)) +
  geom_bar(stat = "identity", fill = "grey") +
  labs(title = "Number of genes in each chromosome",
       x = "Chromosome",
       y = "Gene count") +
  theme_minimal()+
  theme( plot.title = element_text(hjust = 0.5),
         axis.line.x = element_line(color = "black"),
         axis.line.y = element_line(color = "black"),
         panel.grid.major = element_blank(),
         panel.grid.minor = element_blank()) 

ggsave("Number of genes in each chromosome.pdf", width = 8, height = 5)

