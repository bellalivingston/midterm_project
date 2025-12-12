.PHONY: init install testing_rule midterm.html points_cont points_cat rank efficiency

# Initialize renv in the project 
init:
	Rscript -e "if (!requireNamespace('renv', quietly = TRUE)) install.packages('renv'); renv::init()"

# Restore Package Library
install:
	Rscript -e "renv::restore(prompt = FALSE)"

# Test report with different data conditions
testing_rule:
	Rscript -e "message('Testing report build with rows removed'); \
	            df <- read.csv('raw_data/nba_2025-10-30.csv'); \
	            df_subset <- df[1:floor(nrow(df)/2), ]; \
	            write.csv(df_subset, 'raw_data/temp_subset.csv', row.names = FALSE); \
	            rmarkdown::render('midterm.Rmd', quiet = TRUE, params = list(data_file = 'raw_data/temp_subset.csv'))"
	Rscript -e "message('Testing report build with fake rows'); \
	            df <- read.csv('raw_data/nba_2025-10-30.csv'); \
	            df_extra <- rbind(df, df[sample(nrow(df), 20, replace = TRUE), ]); \
	            write.csv(df_extra, 'raw_data/temp_extra.csv', row.names = FALSE); \
	            rmarkdown::render('midterm.Rmd', quiet = TRUE, params = list(data_file = 'raw_data/temp_extra.csv'))"
	Rscript -e "message('All tests completed successfully.')"
	

# DATA variable for analysis scripts
DATA = raw_data/nba_2025-10-30.csv

# Ensure output directories exist
output/figures:
	mkdir -p output/figures

# Continuous age scatter plots
output/figures/points_by_age.png: code/points_by_age.R $(DATA) | output/figures
	Rscript code/points_by_age.R

# Categorical age boxplots
output/figures/points_by_age_cat.png: code/points_by_age_cat.R $(DATA) | output/figures
	Rscript code/points_by_age_cat.R

# Age by rank scatterplot
output/figures/rank_by_age.png: code/rank_by_age.R $(DATA) | output/figures
	Rscript code/rank_by_age.R

# Player efficiency
output/figures/player_eff.png: code/player_eff.R $(DATA) | output/figures
	Rscript code/player_eff.R

# PHONY targets for each analysis part
points_cont: output/figures/points_by_age.png
points_cat: output/figures/points_by_age_cat.png
rank: output/figures/rank_by_age.png
efficiency: output/figures/player_eff.png

# Make report

Report: midterm.Rmd
	Rscript -e "rmarkdown::render('midterm.Rmd', output_file='midterm.html', quiet=FALSE)"
	
testing_html:
	Rscript -e "message('Building HTML report with new dataset'); \
              df <- read.csv('raw_data/f75_interim.csv'); \
              df_new <- rbind(df, df[sample(nrow(df), 20, replace = TRUE), ]); \
              write.csv(df_new, 'raw_data/new_data.csv', row.names = FALSE); \
              rmarkdown::render('midterm.Rmd', output_file='midterm_new.html', quiet=FALSE, params=list(data_file='raw_data/new_data.csv'))"
              
