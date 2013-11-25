# USAGE:
# ruby abundant_peps_with_ratio_no_normalization.rb ../data/WT_F001778_with_pipes.csv ../data/PIA_F001774_with_pipes.csv 0.05 20.0 ../results/WT_PIA_analysis_no_normalization.xlsx

# create a protein list with the unique proteins in each sample
# create a list with all proteins identified in each sample, that don't overlap with the ones in the other samples
# create a list with the identified proteins that are common in these experiments and calculate the significant and total 'matched peptides' normalized ratios and log ratios for WT and PIA samples

require 'rubygems'
require 'axlsx'
require 'mascot_hits_csv_parser'

wt_infile = ARGV[0]
pia_infile = ARGV[1]
pep_expectancy_cutoff = ARGV[2].to_f
pep_score_cutoff = ARGV[3].to_f # do we need to filter by peptide score?
results_ofile = ARGV[4]

######################
# initialize arguments
######################

wt_mascot_csvp = MascotHitsCSVParser.open(wt_infile, pep_expectancy_cutoff, pep_score_cutoff)
pia_mascot_csvp = MascotHitsCSVParser.open(pia_infile, pep_expectancy_cutoff, pep_score_cutoff)

################################################
# make the lists for uniques and common proteins
################################################

# get the unique proteins of WT (get the highest scored protein that has pep_score >= pep_score_cutoff)
wt_unique_proteins = {}
wt_mascot_csvp.each_protein do |protein|
	highest_scored_hit_per_protein = wt_mascot_csvp.highest_from_cutoff_scored_hit_for_prot(protein)
	if !highest_scored_hit_per_protein.nil?
		wt_unique_proteins[protein] = highest_scored_hit_per_protein
	end
end

puts "WT proteins identified"

# get the unique proteins of PIA (get the highest scored protein that has pep_score >= pep_score_cutoff)
pia_unique_proteins = {}
pia_mascot_csvp.each_protein do |protein|
	highest_scored_hit_per_protein = pia_mascot_csvp.highest_from_cutoff_scored_hit_for_prot(protein)
	if !highest_scored_hit_per_protein.nil?
		pia_unique_proteins[protein] = highest_scored_hit_per_protein
	end
end

puts "PIA proteins identified"

# get the common proteins between the experiments WT and PIA
common_proteins = Hash.new { |h,k| h[k] = [] }
total_wt_prot_matches = 0.0
total_pia_prot_matches = 0.0
pia_unique_proteins.each do |protein, hit|
	if wt_unique_proteins.include?(protein)
		common_proteins[protein] = [wt_unique_proteins[protein], pia_unique_proteins[protein]]
		total_pia_prot_matches += hit.prot_matches_sig.to_f
		total_wt_prot_matches += wt_unique_proteins[protein].prot_matches_sig.to_f
	end
end

puts "Common proteins identified"
puts "Total PIA matches: #{total_pia_prot_matches}"
puts "Total WT matches: #{total_wt_prot_matches}"

#########
# results
#########

# output
results_xlsx = Axlsx::Package.new
results_wb = results_xlsx.workbook
# add some styles to the worksheet		
header = results_wb.styles.add_style :b => true, :alignment => { :horizontal => :left }
alignment = results_wb.styles.add_style :alignment => { :horizontal => :left }

# create sheet1 - all proteins identified in WT
results_wb.add_worksheet(:name => "WT Unique Proteins") do |sheet|
	sheet.add_row ["PROT_HIT_NUM", "PROT_ACC", "UNIPROT_LINK", "GENENAME", "PROT_DESC", "REPLICATE", "PROT_SCORE", "PROT_MASS", "PROT_MATCH_SIG", "PROT_MATCH"], :style=>header
	wt_unique_proteins.each do |protein, hit|
		prot_hit_num = hit.prot_hit_num.to_i
		prot_acc = hit.prot_acc.to_s
		uniprot_link = "http://www.uniprot.org/uniprot/#{prot_acc}"
		prot_desc = hit.prot_desc.to_s
		if prot_desc.include? "GN="
			genename = prot_desc.split("GN=")[1].split(" ")[0].to_s
		else
			genename = 'NA'
		end
		replicate = hit.pep_scan_title.split('_')[3]
		if !replicate.eql?('2') && !replicate.eql?('3')
			replicate = 1
		end
		prot_score = hit.prot_score.to_f
		prot_mass = hit.prot_mass.to_i
		prot_matches_sig = hit.prot_matches_sig.to_f
		prot_matches = hit.prot_matches.to_i

		row = sheet.add_row [prot_hit_num, prot_acc, uniprot_link, genename, prot_desc, replicate, prot_score, prot_mass, prot_matches_sig, prot_matches], :style=>alignment
		sheet.add_hyperlink :location => uniprot_link, :ref => "C#{row.index + 1}"
		sheet["C#{row.index + 1}"].color = "0000FF"
	end
end

puts "WT Unique Proteins listed"

# create sheet2 - PIA proteins list
results_wb.add_worksheet(:name => "PIA Unique Proteins") do |sheet|
	sheet.add_row ["PROT_HIT_NUM", "PROT_ACC", "UNIPROT_LINK", "GENENAME", "PROT_DESC", "REPLICATE","PROT_SCORE", "PROT_MASS", "PROT_MATCH_SIG", "PROT_MATCH"], :style=>header
	pia_unique_proteins.each do |protein, hit|
		prot_hit_num = hit.prot_hit_num.to_i
		prot_acc = hit.prot_acc.to_s
		uniprot_link = "http://www.uniprot.org/uniprot/#{prot_acc}"
		prot_desc = hit.prot_desc.to_s
		if prot_desc.include? "GN="
			genename = prot_desc.split("GN=")[1].split(" ")[0].to_s
		else
			genename = 'NA'
		end
		replicate = hit.pep_scan_title.split('_')[3]
		if !replicate.eql?('2') && !replicate.eql?('3')
			replicate = 1
		end
		prot_score = hit.prot_score.to_f
		prot_mass = hit.prot_mass.to_i
		prot_matches_sig = hit.prot_matches_sig.to_f
		prot_matches = hit.prot_matches.to_i

		row = sheet.add_row [prot_hit_num, prot_acc, uniprot_link, genename, prot_desc, replicate, prot_score, prot_mass, prot_matches_sig, prot_matches], :style=>alignment
		sheet.add_hyperlink :location => uniprot_link, :ref => "C#{row.index + 1}"
		sheet["C#{row.index + 1}"].color = "0000FF"
	end
end

puts "PIA Unique Proteins listed"

# create sheet3 - all proteins identified in WT but not in PIA
results_wb.add_worksheet(:name => "WT-only Unique Proteins") do |sheet|	
	sheet.add_row ["PROT_HIT_NUM", "PROT_ACC", "UNIPROT_LINK", "GENENAME", "PROT_DESC", "REPLICATE", "PROT_SCORE", "PROT_MASS", "PROT_MATCH_SIG", "PROT_MATCH"], :style=>header
	wt_unique_proteins.each do |protein, hit|
		if !common_proteins.include?(protein)
			prot_hit_num = hit.prot_hit_num.to_i
			prot_acc = hit.prot_acc.to_s
			uniprot_link = "http://www.uniprot.org/uniprot/#{prot_acc}"
			prot_desc = hit.prot_desc.to_s
			if prot_desc.include? "GN="
				genename = prot_desc.split("GN=")[1].split(" ")[0].to_s
			else
				genename = 'NA'
			end
			replicate = hit.pep_scan_title.split('_')[3]
			if !replicate.eql?('2') && !replicate.eql?('3')
				replicate = 1
			end
			prot_score = hit.prot_score.to_f
			prot_mass = hit.prot_mass.to_i
			prot_matches_sig = hit.prot_matches_sig.to_f
			prot_matches = hit.prot_matches.to_i

			row = sheet.add_row [prot_hit_num, prot_acc, uniprot_link, genename, prot_desc, replicate, prot_score, prot_mass, prot_matches_sig, prot_matches], :style=>alignment
			sheet.add_hyperlink :location => uniprot_link, :ref => "C#{row.index + 1}"
			sheet["C#{row.index + 1}"].color = "0000FF"
		end
	end
end

puts "WT-only Unique Proteins listed"

# create sheet4 - all proteins identified in PIA but not in WT
results_wb.add_worksheet(:name => "PIA-only Unique Proteins") do |sheet|
	sheet.add_row ["PROT_HIT_NUM", "PROT_ACC", "UNIPROT_LINK", "GENENAME", "PROT_DESC", "REPLICATE", "PROT_SCORE", "PROT_MASS", "PROT_MATCH_SIG", "PROT_MATCH"], :style=>header
	pia_unique_proteins.each do |protein, hit|
		if !common_proteins.include?(protein)
			prot_hit_num = hit.prot_hit_num.to_i
			prot_acc = hit.prot_acc.to_s
			uniprot_link = "http://www.uniprot.org/uniprot/#{prot_acc}"
			prot_desc = hit.prot_desc.to_s
			if prot_desc.include? "GN="
				genename = prot_desc.split("GN=")[1].split(" ")[0].to_s
			else
				genename = 'NA'
			end
			replicate = hit.pep_scan_title.split('_')[3]
			if !replicate.eql?('2') && !replicate.eql?('3')
				replicate = 1
			end
			prot_score = hit.prot_score.to_f
			prot_mass = hit.prot_mass.to_i
			prot_matches_sig = hit.prot_matches_sig.to_f
			prot_matches = hit.prot_matches.to_i

			row = sheet.add_row [prot_hit_num, prot_acc, uniprot_link, genename, prot_desc, replicate, prot_score, prot_mass, prot_matches_sig, prot_matches], :style=>alignment
			sheet.add_hyperlink :location => uniprot_link, :ref => "C#{row.index + 1}"
			sheet["C#{row.index + 1}"].color = "0000FF"
		end
	end
end

puts "PIA-only Unique Proteins listed"

# create sheet5 - ratios
results_wb.add_worksheet(:name => "WT-PIA differential expression") do |sheet|
	sheet.add_row ["PROT_ACC", "UNIPROT_LINK", "PROT_DESC", "WT PROT_HIT_NUM", "WT REPLICATE", "PIA PROT_HIT_NUM", "PIA REPLICATE", "WT PROT_SCORE", "PIA PROT_SCORE", "WT PROT_MATCH_SIG", "PIA PROT_MATCH_SIG", "PROT_MATCH_SIG PIA:WT", "LOG(PROT_MATCH_SIG PIA:WT)", "WT PROT_MATCH", "PIA PROT_MATCH", "PROT_MATCH PIA:WT", "LOG(PROT_MATCH PIA:WT)"], :style=>header
	norm_pia_prot_matches = 0.0
	norm_wt_prot_matches = 0.0
	common_proteins.each do |protein, hits|
		uniprot_link = "http://www.uniprot.org/uniprot/#{protein}"
		prot_desc = hits[0].prot_desc.to_s
		wt_replicate = hits[0].pep_scan_title.split('_')[3]
		if !wt_replicate.eql?('2') && !wt_replicate.eql?('3')
			wt_replicate = 1
		end
		pia_replicate = hits[1].pep_scan_title.split('_')[3]
		if !pia_replicate.eql?('2') && !pia_replicate.eql?('3')
			pia_replicate = 1
		end
		wt_prot_hit_num = hits[0].prot_hit_num.to_i
		pia_prot_hit_num = hits[1].prot_hit_num.to_i
		wt_prot_score = hits[0].prot_score.to_f
		pia_prot_score = hits[1].prot_score.to_f
		wt_prot_matches_sig = hits[0].prot_matches_sig.to_f
		pia_prot_matches_sig = hits[1].prot_matches_sig.to_f
		if pia_prot_matches_sig != 0.0 && wt_prot_matches_sig != 0.0
			ratio_sig = (pia_prot_matches_sig/wt_prot_matches_sig).to_f
			logratio_sig = Math::log(ratio_sig)
		else
			logratio_sig = ""
		end
		wt_prot_matches = hits[0].prot_matches.to_f
		pia_prot_matches = hits[1].prot_matches.to_f
		if pia_prot_matches != 0.0 && wt_prot_matches != 0.0 # there is no need for this check
			ratio_total = (pia_prot_matches/wt_prot_matches).to_f
			logratio_total = Math::log(ratio_total)
		else
			logratio_total = ""
		end

		row = sheet.add_row [protein, uniprot_link, prot_desc, wt_prot_hit_num, wt_replicate, pia_prot_hit_num, pia_replicate, wt_prot_score, pia_prot_score, wt_prot_matches_sig, pia_prot_matches_sig, pia_prot_matches_sig.to_s+":"+wt_prot_matches_sig.to_s, logratio_sig, wt_prot_matches, pia_prot_matches, pia_prot_matches.to_s+":"+wt_prot_matches.to_s, logratio_total], :style=>alignment
		sheet.add_hyperlink :location => uniprot_link, :ref => "B#{row.index + 1}"
		sheet["B#{row.index + 1}"].color = "0000FF"
	end
end

puts "WT-PIA differential expression listed"

# write xlsx file
results_xlsx.serialize(results_ofile)

puts "Results ready"


