
# Extract the FASTA file
zcat /mnt/e/桌/KUMC\ task/hiriing_task2/NC_000913.faa.gz > NC_000913.faa

# Calculate the total number of sequences
num_sequences=$(grep -c '^>' NC_000913.faa)

# Calculate the total number of amino acids
total_aa=$(grep -v '^>' NC_000913.faa | tr -d '\n' | wc -c)

# Calculate the average length of protein
average_length=$(echo "scale=2; $total_aa / $num_sequences" | bc)

# Display the result
echo "The average length of protein is: $average_length"
