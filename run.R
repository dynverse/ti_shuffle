#!/usr/local/bin/Rscript

task <- dyncli::main()

library(dplyr, warn.conflicts = FALSE)
library(purrr, warn.conflicts = FALSE)

#   ____________________________________________________________________________
#   Load data                                                               ####

expression <- task$expression
dataset <- task$priors$dataset

#   ____________________________________________________________________________
#   Infer trajectory                                                        ####

# TIMING: done with preproc
checkpoints <- list(method_afterpreproc = as.numeric(Sys.time()))

# permute cell labels
allcells <- rownames(expression)
mapper <- setNames(sample(allcells), allcells)
progressions <- dataset$progressions %>% mutate(
  cell_id = mapper[cell_id]
)

# TIMING: done with method
checkpoints$method_aftermethod <- as.numeric(Sys.time())

#   ____________________________________________________________________________
#   Save output                                                             ####
output <- dynwrap::wrap_data(cell_ids = rownames(expression)) %>%
  dynwrap::add_trajectory(
    milestone_network = dataset$milestone_network,
    progressions = progressions,
    divergence_regions = dataset$divergence_regions
  ) %>%
  dynwrap::add_timings(
    timings = checkpoints
  )

dyncli::write_output(output, task$output)
