# USAGE:
# ruby common_findings_through_experiments.rb ../results/common_phospho_KD_RNA.csv ../results/common_camile_KD_RNA.csv ../results/common_findings.csv

# This analysis doesn't make biological sense
# find common findings between different experiments

require 'rubygems'
require 'fastercsv'

exp1_infile = ARGV[0]
exp2_infile = ARGV[1]
results_ofile = ARGV[2]

# make the lists of proteins for each experiment

exp1_proteins = {}
FasterCSV.foreach(exp1_infile) do |row|
	if !row[0].eql?("PROT_ACC")
		exp1_proteins[row[0]] = row
	end
end
puts "EXP1 PROTEINS = #{exp1_proteins.length}"

exp2_proteins = {}
FasterCSV.foreach(exp2_infile) do |row|
	if !row[0].eql?("PROT_ACC")
		exp2_proteins[row[0]] = row
	end
end
puts "EXP2 PROTEINS = #{exp2_proteins.length}"

# get the common proteins between the experiments

common_proteins = Hash.new { |h,k| h[k] = [] }
exp1_proteins.each do |protein,row|
	if exp2_proteins.has_key?(protein)
		common_proteins[protein] = [row, exp2_proteins[protein]]
	end
end
puts "COMMON PROTEINS = #{common_proteins.length}"
# puts common_proteins.inspect

# write the list to csv
FasterCSV.open(results_ofile, "w") do |csv|
	csv << ["EXPERIMENT", "PROT_ACC", "UNIPROT_LINK", "PROT_DESC", "KD PROT_HIT_NUM", "RNA PROT_HIT_NUM", "KD PROT_SCORE", "RNA PROT_SCORE", "KD PROT_MATCH_SIG", "RNA PROT_MATCH_SIG", "PROT_MATCH_SIG RNA:KD", "LOG(PROT_MATCH_SIG RNA:KD)", "KD PROT_MATCH", "RNA PROT_MATCH", "PROT_MATCH RNA:KD", "LOG(PROT_MATCH RNA:KD)"]
	common_proteins.each do |protein,rows|
		csv << ["phospho exp"].concat(rows[0])
		csv << ["camile exp"].concat(rows[1])
	end
end

