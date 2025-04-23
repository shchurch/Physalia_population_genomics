library(dplyr)
library(tidyr)
library(data.table)
library(ggplot2)
library(stringr)
library(GenomicRanges)
theme_set(theme_classic())

gtf_cols <- c("seqname", "source", "feature", "start", "end", "score", "strand", "frame", "attribute")
gtf_df <- fread("gene.primary_physalia_scaffolds_v0.4.gtf", sep = "\t", col.names = gtf_cols) %>%
  mutate(length = end - start + 1)

repeat_gff_df <- fread("repeat.primary_physalia_scaffolds_v0.4.gff", sep = "\t", skip = 3, col.names = gtf_cols) %>%
  filter(feature == "dispersed_repeat") %>%
  mutate(length = end - start + 1)

fai_df <- fread("primary_physalia_scaffolds_v0.4.modified.headers.fasta.masked.fai", header = FALSE,
                col.names = c("seqname", "scaffold_length", "offset", "linebases", "linewidth"))
scaffold_lengths <- fai_df %>% select(seqname, scaffold_length)

gene_summary <- gtf_df %>%
  group_by(seqname) %>%
  summarise(
    num_genes = sum(feature == "gene"),
    num_transcripts = sum(feature == "transcript"),
    num_exons = sum(feature == "exon"),
    gene_bp = sum(length[feature == "gene"]),
    transcript_bp = sum(length[feature == "transcript"]),
    exon_bp = sum(length[feature == "exon"]),
    .groups = "drop"
  )

repeat_summary <- repeat_gff_df %>%
  group_by(seqname) %>%
  summarise(
    num_repeats = n(),
    repeat_bp = sum(length),
    .groups = "drop"
  )

scaffold_summary <- scaffold_lengths %>%
  left_join(gene_summary, by = "seqname") %>%
  left_join(repeat_summary, by = "seqname") %>%
  mutate(across(c(num_genes, num_transcripts, num_exons, gene_bp, transcript_bp, exon_bp, num_repeats, repeat_bp), ~replace_na(., 0)))

chromosomes <- paste0("Scaffold", seq(1:10))
scaffolds <- paste0("Scaffold", seq_along(unique(scaffold_summary$seqname)))

non_chromosome_summary <- scaffold_summary %>%
  filter(!seqname %in% chromosomes) %>%
  summarise(
    seqname = "Unplaced",
    scaffold_length = sum(scaffold_length),
    gene_bp = sum(gene_bp),
    transcript_bp = sum(transcript_bp),
    exon_bp = sum(exon_bp),
    repeat_bp = sum(repeat_bp),
    num_genes = sum(num_genes),
    num_transcripts = sum(num_transcripts),
    num_exons = sum(num_exons),
    num_repeats = sum(num_repeats),
    .groups = "drop"
  )

scaffold_summary <- scaffold_summary %>%
  filter(seqname %in% chromosomes) %>%
  bind_rows(non_chromosome_summary) %>%
  mutate(
    seqname = factor(seqname, levels = c(chromosomes, "Unplaced")),
    gene_density = gene_bp / scaffold_length,
    transcript_density = transcript_bp / scaffold_length,
    exon_density = exon_bp / scaffold_length,
    repeat_density = repeat_bp / scaffold_length
  )

pdf("scaffold_feature_basepair_counts.pdf", width = 5, height = 3)
print(
  ggplot(scaffold_summary, aes(x = seqname)) +
    geom_col(aes(y = scaffold_length / 1e6), fill = "gray80") +
    geom_col(aes(y = repeat_bp / 1e6), fill = "tomato") +
    geom_col(aes(y = gene_bp / 1e6), fill = "steelblue") +
    labs(x = "", y = "length (Mbp)") +
    theme(axis.text.x = element_text(angle = 90, hjust = 1))
)
dev.off()

scaffold_summary_long <- scaffold_summary %>%
  select(seqname, gene_density, repeat_density) %>%
  pivot_longer(cols = -seqname, names_to = "feature", values_to = "density")

pdf("scaffold_feature_densities.pdf", width = 5, height = 3)
print(
  ggplot(scaffold_summary_long, aes(x = seqname, y = density, fill = feature)) +
    geom_col(position = "dodge") +
    labs(x = "", y = "fraction of scaffold") +
    scale_fill_manual(values = c(
      gene_density = "steelblue",
      repeat_density = "tomato"
    )) +
    scale_y_continuous(limits = c(0, 1), breaks = seq(0, 1, 0.1)) +
    theme(axis.text.x = element_text(angle = 90, hjust = 1),
          legend.position = "none")
)
dev.off()

gtf_gr <- makeGRangesFromDataFrame(gtf_df, seqnames.field = "seqname", start.field = "start", end.field = "end", strand.field = "strand", keep.extra.columns = TRUE)
repeats_gr <- makeGRangesFromDataFrame(repeat_gff_df, seqnames.field = "seqname", start.field = "start", end.field = "end", strand.field = "strand", keep.extra.columns = TRUE)

calculate_overlap_fraction <- function(feature_type) {
  feature_gr <- gtf_gr[gtf_gr$feature == feature_type]
  hits <- findOverlaps(feature_gr, repeats_gr)
  overlaps <- pintersect(feature_gr[queryHits(hits)], repeats_gr[subjectHits(hits)])
  overlap_bp <- sum(width(overlaps))
  total_bp <- sum(width(feature_gr))

  tibble(
    feature = feature_type,
    total_bp = total_bp,
    overlap_bp = overlap_bp,
    fraction_overlap = ifelse(total_bp > 0, overlap_bp / total_bp, NA)
  )
}

overlap_stats <- bind_rows(
  calculate_overlap_fraction("gene"),
  calculate_overlap_fraction("exon")
)

hits <- findOverlaps(gtf_gr[gtf_gr$feature == "exon"], repeats_gr)
overlapping_repeats <- repeats_gr[subjectHits(hits)]
non_overlapping_repeats <- repeats_gr[-unique(subjectHits(hits))]

extract_motif <- function(gr) {
  as.data.frame(gr) %>%
    mutate(motif = str_extract(attribute, "(?<=Motif:)[^\"]+"))
}

df_hits <- extract_motif(overlapping_repeats) %>% mutate(overlap = "yes")
df_nonhits <- extract_motif(non_overlapping_repeats) %>% mutate(overlap = "no")
motif_df <- bind_rows(df_hits, df_nonhits)

motif_counts <- motif_df %>% count(motif, overlap) %>% pivot_wider(names_from = overlap, values_from = n, values_fill = 0)
group_sizes <- motif_df %>% count(overlap) %>% tibble::deframe()
total_yes <- group_sizes[["yes"]]
total_no  <- group_sizes[["no"]]

motif_enrichment <- motif_counts %>%
  mutate(
    overlap_yes = yes,
    overlap_no = no,
    not_overlap_yes = total_yes - overlap_yes,
    not_overlap_no  = total_no - overlap_no
  ) %>%
  rowwise() %>%
  mutate(
    p_value = fisher.test(matrix(c(overlap_yes, overlap_no, not_overlap_yes, not_overlap_no), nrow = 2))$p.value
  ) %>%
  ungroup() %>%
  mutate(
    p_adj = p.adjust(p_value, method = "fdr"),
    log2_fc = log2((overlap_yes + 1) / (overlap_no + 1))
  ) %>%
  select(motif, overlap_yes, overlap_no, not_overlap_yes, not_overlap_no, p_value, p_adj, log2_fc)

motif_enrichment %>% filter(p_adj < 0.05, log2_fc < 0) %>% arrange(log2_fc) %>% as.data.frame()

exon_df <- gtf_df %>%
  filter(feature == "exon") %>%
  mutate(
    transcript_id = str_extract(attribute, 'transcript_id "[^"]+"') %>% str_remove_all('transcript_id "|"'),
    gene_ID = str_extract(attribute, 'gene_id "[^"]+"') %>% str_remove_all('gene_id "|"')
  )

exon_gr <- GRanges(
  seqnames = exon_df$seqname,
  ranges = IRanges(start = exon_df$start, end = exon_df$end),
  strand = exon_df$strand,
  transcript_id = exon_df$transcript_id,
  gene_ID = exon_df$gene_ID
)

exon_by_tx <- split(exon_gr, exon_gr$transcript_id)

intron_exon_stats <- purrr::map_df(exon_by_tx, function(exons) {
  exons <- sort(exons)
  exon_length <- sum(width(exons))

  if (length(exons) < 2) {
    intron_length <- 0
  } else {
    introns <- IRanges(start = end(exons)[-length(exons)] + 1, end = start(exons)[-1] - 1)
    intron_length <- sum(pmax(0, width(introns)))
  }

  tibble(
    transcript_id = exons$transcript_id[1],
    gene_ID = exons$gene_ID[1],
    exon_length = exon_length,
    intron_length = intron_length,
    intron_to_exon_ratio = ifelse(exon_length > 0, intron_length / exon_length, NA_real_)
  )
})

mean_intron_ratio <- intron_exon_stats %>%
  pull(intron_to_exon_ratio) %>%
  mean(na.rm = TRUE) %>%
  print()

mean_intron_ratio_intronless <- intron_exon_stats %>%
  filter(intron_length > 0) %>%
  pull(intron_to_exon_ratio) %>%
  mean(na.rm = TRUE) %>%
  print()

mean_intron_ratio
mean_intron_ratio_excluding_intronless
log10(mean_intron_ratio)
log10(mean_intron_ratio_excluding_intronless)