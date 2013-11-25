# USAGE:
# ruby abundant_peps_with_ratio.rb ../data/KD10_F001779_with_pipes.csv ../data/RNA10_F001782_with_pipes.csv 100.0 20.0 ../results/KD10_RNA10_analysis.xlsx

# ruby abundant_peps_with_ratio.rb ../data/KD14_F001781_with_pipes.csv ../data/RNA14_F001784_with_pipes.csv 100.0 20.0 ../results/KD14_RNA14_analysis.xlsx

# ruby abundant_peps_with_ratio.rb ../data/KD13_F001780_with_pipes.csv ../data/RNA13_F001783_with_pipes.csv 100.0 20.0 ../results/KD13_RNA13_analysis.xlsx

# ruby abundant_peps_with_ratio.rb ../data/KD_F001785_with_pipes.csv ../data/RNA_F001786_with_pipes.csv 100.0 20.0 ../results/KD_RNA_analysis.xlsx

# to compare with Camile's KD-RNA profiling 
# ruby abundant_peps_with_ratio.rb ../data/Zfish_KD_RNA_profiling/F001745_KD-ALL_with_pipes.csv ../data/Zfish_KD_RNA_profiling/F001746_RNA-ALL_with_pipes.csv 100.0 20.0 ../results/KD_RNA_Camile_analysis.xlsx

# check
# ruby abundant_peps_with_ratio.rb ../data/kd_test_with_pipes.csv ../data/rna_test_with_pipes.csv 100.0 20.0 ../results/test_KD_RNA_analysis.xlsx

# create a protein list with the unique proteins in each sample
# create a list with all proteins identified in each sample, that don't overlap with the ones in the other samples
# create a list with the identified proteins that are common in these experiments and calculate the significant and total 'matched peptides' normalized ratios and log ratios for WT and PIA samples
# cutoffs and modifications filters applied

require 'rubygems'
require 'axlsx'
require 'mascot_hits_csv_parser'

kd_infile = ARGV[0]
rna_infile = ARGV[1]
pep_expectancy_cutoff = ARGV[2].to_f
pep_score_cutoff = ARGV[3].to_f
results_ofile = ARGV[4]

######################
# initialize arguments
######################

kd_mascot_csvp = MascotHitsCSVParser.open(kd_infile, pep_expectancy_cutoff, pep_score_cutoff)
rna_mascot_csvp = MascotHitsCSVParser.open(rna_infile, pep_expectancy_cutoff, pep_score_cutoff)

################################################
# make the lists for uniques and common proteins
################################################

# get the unique proteins of KD (get the highest scored protein that has pep_score >= pep_score_cutoff)
kd_unique_proteins = {}
kd_mascot_csvp.each_protein do |protein|
	highest_scored_hit_per_protein = kd_mascot_csvp.highest_from_cutoff_scored_hit_for_prot(protein)
	if !highest_scored_hit_per_protein.nil?
		kd_unique_proteins[protein] = highest_scored_hit_per_protein
	end
end

puts "KD proteins identified"

# get the unique proteins of RNA (get the highest scored protein that has pep_score >= pep_score_cutoff)
rna_unique_proteins = {}
rna_mascot_csvp.each_protein do |protein|
	highest_scored_hit_per_protein = rna_mascot_csvp.highest_from_cutoff_scored_hit_for_prot(protein)
	if !highest_scored_hit_per_protein.nil?
		rna_unique_proteins[protein] = highest_scored_hit_per_protein
	end
end

puts "RNA proteins identified"

# get the common proteins between the experiments KD and RNA
common_proteins = Hash.new { |h,k| h[k] = [] }
rna_unique_proteins.each do |protein, hit|
	if kd_unique_proteins.include?(protein)
		common_proteins[protein] = [kd_unique_proteins[protein], rna_unique_proteins[protein]]
	end
end

puts "Common proteins identified"
puts "COMMON PROTEINS = #{common_proteins.length}"

#########
# results
#########

# output
results_xlsx = Axlsx::Package.new
results_wb = results_xlsx.workbook
# add some styles to the worksheet		
header = results_wb.styles.add_style :b => true, :alignment => { :horizontal => :left }
alignment = results_wb.styles.add_style :alignment => { :horizontal => :left }

# create sheet1 - all proteins identified in KD
results_wb.add_worksheet(:name => "KD Unique Proteins") do |sheet|
	sheet.add_row ["PROT_HIT_NUM", "PROT_ACC", "UNIPROT_LINK", "GENENAME", "PROT_DESC", "PROT_SCORE", "PROT_MASS", "PROT_MATCH_SIG", "PROT_MATCH"], :style=>header
	kd_unique_proteins.each do |protein, hit|
		prot_hit_num = hit.prot_hit_num.to_i
		prot_acc = hit.prot_acc.to_s
		uniprot_link = "http://www.uniprot.org/uniprot/#{prot_acc}"
		prot_desc = hit.prot_desc.to_s
		if prot_desc.include? "GN="
			genename = prot_desc.split("GN=")[1].split(" ")[0].to_s
		else
			genename = 'NA'
		end
		prot_score = hit.prot_score.to_f
		prot_mass = hit.prot_mass.to_i
		prot_matches_sig = hit.prot_matches_sig.to_f
		prot_matches = hit.prot_matches.to_i

		row = sheet.add_row [prot_hit_num, prot_acc, uniprot_link, genename, prot_desc, prot_score, prot_mass, prot_matches_sig, prot_matches], :style=>alignment
		sheet.add_hyperlink :location => uniprot_link, :ref => "C#{row.index + 1}"
		sheet["C#{row.index + 1}"].color = "0000FF"
	end
end

# create sheet2 - RNA proteins list
results_wb.add_worksheet(:name => "RNA Unique Proteins") do |sheet|
	sheet.add_row ["PROT_HIT_NUM", "PROT_ACC", "UNIPROT_LINK", "GENENAME", "PROT_DESC", "PROT_SCORE", "PROT_MASS", "PROT_MATCH_SIG", "PROT_MATCH"], :style=>header
	rna_unique_proteins.each do |protein, hit|
		prot_hit_num = hit.prot_hit_num.to_i
		prot_acc = hit.prot_acc.to_s
		uniprot_link = "http://www.uniprot.org/uniprot/#{prot_acc}"
		prot_desc = hit.prot_desc.to_s
		if prot_desc.include? "GN="
			genename = prot_desc.split("GN=")[1].split(" ")[0].to_s
		else
			genename = 'NA'
		end
		prot_score = hit.prot_score.to_f
		prot_mass = hit.prot_mass.to_i
		prot_matches_sig = hit.prot_matches_sig.to_f
		prot_matches = hit.prot_matches.to_i

		row = sheet.add_row [prot_hit_num, prot_acc, uniprot_link, genename, prot_desc, prot_score, prot_mass, prot_matches_sig, prot_matches], :style=>alignment
		sheet.add_hyperlink :location => uniprot_link, :ref => "C#{row.index + 1}"
		sheet["C#{row.index + 1}"].color = "0000FF"
	end
end

# create sheet3 - all proteins identified in KD but not in RNA
results_wb.add_worksheet(:name => "KD-only Unique Proteins") do |sheet|	
	sheet.add_row ["PROT_HIT_NUM", "PROT_ACC", "UNIPROT_LINK", "GENENAME", "PROT_DESC", "PROT_SCORE", "PROT_MASS", "PROT_MATCH_SIG", "PROT_MATCH"], :style=>header
	kd_only_proteins = {}
	kd_unique_proteins.each do |protein, hit|
		if !common_proteins.include?(protein)
			kd_only_proteins[protein] = nil
			prot_hit_num = hit.prot_hit_num.to_i
			prot_acc = hit.prot_acc.to_s
			uniprot_link = "http://www.uniprot.org/uniprot/#{prot_acc}"
			prot_desc = hit.prot_desc.to_s
			if prot_desc.include? "GN="
				genename = prot_desc.split("GN=")[1].split(" ")[0].to_s
			else
				genename = 'NA'
			end
			prot_score = hit.prot_score.to_f
			prot_mass = hit.prot_mass.to_i
			prot_matches_sig = hit.prot_matches_sig.to_f
			prot_matches = hit.prot_matches.to_i

			row = sheet.add_row [prot_hit_num, prot_acc, uniprot_link, genename, prot_desc, prot_score, prot_mass, prot_matches_sig, prot_matches], :style=>alignment
			sheet.add_hyperlink :location => uniprot_link, :ref => "C#{row.index + 1}"
			sheet["C#{row.index + 1}"].color = "0000FF"
		end
	end
	puts "KD ONLY PROTEINS = #{kd_only_proteins.length}"
end

# create sheet4 - all proteins identified in RNA but not in KD
results_wb.add_worksheet(:name => "RNA-only Unique Proteins") do |sheet|
	sheet.add_row ["PROT_HIT_NUM", "PROT_ACC", "UNIPROT_LINK", "GENENAME", "PROT_DESC", "PROT_SCORE", "PROT_MASS", "PROT_MATCH_SIG", "PROT_MATCH"], :style=>header
	rna_only_proteins = {}
	rna_unique_proteins.each do |protein, hit|
		if !common_proteins.include?(protein)
			rna_only_proteins[protein] = nil
			prot_hit_num = hit.prot_hit_num.to_i
			prot_acc = hit.prot_acc.to_s
			uniprot_link = "http://www.uniprot.org/uniprot/#{prot_acc}"
			prot_desc = hit.prot_desc.to_s
			if prot_desc.include? "GN="
				genename = prot_desc.split("GN=")[1].split(" ")[0].to_s
			else
				genename = 'NA'
			end
			prot_score = hit.prot_score.to_f
			prot_mass = hit.prot_mass.to_i
			prot_matches_sig = hit.prot_matches_sig.to_f
			prot_matches = hit.prot_matches.to_i

			row = sheet.add_row [prot_hit_num, prot_acc, uniprot_link, genename, prot_desc, prot_score, prot_mass, prot_matches_sig, prot_matches], :style=>alignment
			sheet.add_hyperlink :location => uniprot_link, :ref => "C#{row.index + 1}"
			sheet["C#{row.index + 1}"].color = "0000FF"
		end
	end
	puts "RNA ONLY PROTEINS = #{rna_only_proteins.length}"
end

# create sheet5 - ratios
results_wb.add_worksheet(:name => "KD-RNA differential expression") do |sheet|
	sheet.add_row ["PROT_ACC", "UNIPROT_LINK", "PROT_DESC", "KD PROT_HIT_NUM", "RNA PROT_HIT_NUM", "KD PROT_SCORE", "RNA PROT_SCORE", "KD PROT_MATCH_SIG", "RNA PROT_MATCH_SIG", "PROT_MATCH_SIG RNA:KD", "LOG(PROT_MATCH_SIG RNA:KD)", "KD PROT_MATCH", "RNA PROT_MATCH", "PROT_MATCH RNA:KD", "LOG(PROT_MATCH RNA:KD)"], :style=>header
	common_proteins.each do |protein, hits|
		uniprot_link = "http://www.uniprot.org/uniprot/#{protein}"
		prot_desc = hits[0].prot_desc.to_s
		kd_prot_hit_num = hits[0].prot_hit_num.to_i
		rna_prot_hit_num = hits[1].prot_hit_num.to_i
		kd_prot_score = hits[0].prot_score.to_f
		rna_prot_score = hits[1].prot_score.to_f
		kd_prot_matches_sig = hits[0].prot_matches_sig.to_f
		rna_prot_matches_sig = hits[1].prot_matches_sig.to_f
		if rna_prot_matches_sig != 0.0 && kd_prot_matches_sig != 0.0
			ratio_sig = (rna_prot_matches_sig/kd_prot_matches_sig).to_f
			logratio_sig = Math::log(ratio_sig)
		else
			logratio_sig = ""
		end
		kd_prot_matches = hits[0].prot_matches.to_f
		rna_prot_matches = hits[1].prot_matches.to_f
		if rna_prot_matches != 0.0 && kd_prot_matches != 0.0 # there is no need for this check
			ratio_total = (rna_prot_matches/kd_prot_matches).to_f
			logratio_total = Math::log(ratio_total)
		else
			logratio_total = ""
		end
		# analysis in the peptide level
		kd_pep_seq = hits[0].pep_seq.to_s
		rna_pep_seq = hits[1].pep_seq.to_s
		kd_pep_num_match = hits[0].pep_num_match.to_f
		rna_pep_num_match = hits[1].pep_num_match.to_f
		if rna_pep_num_match != 0.0 && kd_pep_num_match != 0.0 # there is no need for this check
			pep_ratio = (rna_pep_num_match/kd_pep_num_match).to_f
			pep_logratio = Math::log(pep_ratio)
		else
			pep_logratio = ""
		end

		row = sheet.add_row [protein, uniprot_link, prot_desc, kd_prot_hit_num, rna_prot_hit_num, kd_prot_score, rna_prot_score, kd_prot_matches_sig, rna_prot_matches_sig, rna_prot_matches_sig.to_s+":"+kd_prot_matches_sig.to_s, logratio_sig, kd_prot_matches, rna_prot_matches, rna_prot_matches.to_s+":"+kd_prot_matches.to_s, logratio_total, kd_pep_seq, rna_pep_seq, kd_pep_num_match, rna_pep_num_match, pep_logratio], :style=>alignment
		sheet.add_hyperlink :location => uniprot_link, :ref => "B#{row.index + 1}"
		sheet["B#{row.index + 1}"].color = "0000FF"
	end
end

# write xlsx file
results_xlsx.serialize(results_ofile)

puts "Results ready"


