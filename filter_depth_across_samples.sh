#ADD names here
input_vcf=""
output_vcf=""



#getting total depth across all samples at a site
grep -oP '(?<=DP=)[0-9]+' $input_vcf > depth_across_samples.txt

#getting the 10th and 90th percentile of reads
cat depth_across_samples.txt|(percentile=90; (sort -n;echo)|nl -ba -v0|tac|(read count;cut=$(((count * percentile + 99) / 100)); tac|sed -n "${cut}s/.*\t//p")) > upper_limit.txt
sed -i '1s/^/upper=/' upper_limit.txt

cat depth_across_samples.txt|(percentile=10; (sort -n;echo)|nl -ba -v0|tac|(read count;cut=$(((count * percentile + 99) / 100)); tac|sed -n "${cut}s/.*\t//p")) > lower_limit.txt
sed -i '1s/^/lower=/' lower_limit.txt


# removing variants with a depth outside the middle 80th percentile
. lower_limit.txt
. upper_limit.txt

bcftools filter $input_vcf -i "INFO/DP>$lower && INFO/DP<$upper" > $output_vcf
