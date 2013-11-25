# USAGE:
# ruby common_peptides.rb ../results/RNA10_phospho_peps.csv ../results/RNA13_phospho_peps.csv ../results/RNA14_phospho_peps.csv ../results/KD10_phospho_peps.csv ../results/KD13_phospho_peps.csv ../results/KD14_phospho_peps.csv ../results/common_peptides.csv

# find the common findings (unique phospho peptides) in all 6 different experiments (3 new phospho exps and 3 old kd-rna profiling ones)

require 'rubygems'
require 'fastercsv'

exp1_infile = ARGV[0]
exp2_infile = ARGV[1]
exp3_infile = ARGV[2]
old_exp1_infile = ARGV[3]
old_exp2_infile = ARGV[4]
old_exp3_infile = ARGV[5]
results_ofile = ARGV[6]

# make the lists of peptides for each experiment
exp1_peps = {}
FasterCSV.foreach(exp1_infile) do |row|
	if !row[0].eql?("PROT_HIT_NUM")
		exp1_peps[row[12]] = row
	end
end
puts "PHOSPHO EXP1 PEPTIDES = #{exp1_peps.length}"

exp2_peps = {}
FasterCSV.foreach(exp2_infile) do |row|
	if !row[0].eql?("PROT_HIT_NUM")
		exp2_peps[row[12]] = row
	end
end
puts "PHOSPHO EXP2 PEPTIDES = #{exp2_peps.length}"

exp3_peps = {}
FasterCSV.foreach(exp3_infile) do |row|
	if !row[0].eql?("PROT_HIT_NUM")
		exp3_peps[row[12]] = row
	end
end
puts "PHOSPHO EXP3 PEPTIDES = #{exp3_peps.length}"

old_exp1_peps = {}
FasterCSV.foreach(old_exp1_infile) do |row|
	if !row[0].eql?("PROT_HIT_NUM")
		old_exp1_peps[row[12]] = row
	end
end
puts "OLD EXP1 PEPTIDES = #{old_exp1_peps.length}"

old_exp2_peps = {}
FasterCSV.foreach(old_exp2_infile) do |row|
	if !row[0].eql?("PROT_HIT_NUM")
		old_exp2_peps[row[12]] = row
	end
end
puts "OLD EXP2 PEPTIDES = #{old_exp2_peps.length}"

old_exp3_peps = {}
FasterCSV.foreach(old_exp3_infile) do |row|
	if !row[0].eql?("PROT_HIT_NUM")
		old_exp3_peps[row[12]] = row
	end
end
puts "OLD EXP3 PEPTIDES = #{old_exp3_peps.length}"


# get the peptides that are common in all of the experiments
common_peps = {}
common_peps_hits = Hash.new { |h,k| h[k] = [] }
exp1_peps.each do |peptide,row|
	if exp2_peps.has_key?(peptide) && exp3_peps.has_key?(peptide) && old_exp1_peps.has_key?(peptide) && old_exp2_peps.has_key?(peptide) && old_exp3_peps.has_key?(peptide)
		common_peps[peptide] = nil
		common_peps_hits[peptide] = [row, exp2_peps[peptide], exp3_peps[peptide], old_exp1_peps[peptide], old_exp2_peps[peptide], old_exp3_peps[peptide]]
	end
end
puts "COMMON PEPTIDES = #{common_peps.length}"


# write the peptide list to csv
FasterCSV.open(results_ofile, "w") do |csv|
	csv << ["EXPERIMENT", "PROT_ACC", "UNIPROT_LINK", "PROT_DESC", "KD PROT_HIT_NUM", "RNA PROT_HIT_NUM", "KD PROT_SCORE", "RNA PROT_SCORE", "KD PROT_MATCH_SIG", "RNA PROT_MATCH_SIG", "PROT_MATCH_SIG RNA:KD", "LOG(PROT_MATCH_SIG RNA:KD)", "KD PROT_MATCH", "RNA PROT_MATCH", "PROT_MATCH RNA:KD", "LOG(PROT_MATCH RNA:KD)"]
	common_peps_hits.each do |protein,rows|
		csv << ["phospho exp 1"].concat(rows[0])
		csv << ["phospho exp 2"].concat(rows[1])
		csv << ["phospho exp 3"].concat(rows[0])
		csv << ["old exp 1"].concat(rows[1])
		csv << ["old exp 2"].concat(rows[0])
		csv << ["old exp 3"].concat(rows[1])
	end
end


