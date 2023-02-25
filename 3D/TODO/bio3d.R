# load required packages
library(bio3d)

# define paths to reference structure file and directory containing models
refs_file <- "reference_structure.pdb"
models_dir <- "models"

# read in reference structure
refs <- read.pdb(refs_file)

# create an empty list to store rmsd values
rmsd_values <- list()

# loop over all model files in models directory
for (model_file in list.files(models_dir, pattern = "\\.pdb$")) {
  
  # read in model structure
  model <- read.pdb(file.path(models_dir, model_file))
  
  # select the backbone atoms for fitting
  core <- atom.select(model, elety = c("C", "CA", "N"))
  
  # fit the model to the reference structure
  pdbfit_result <- pdbfit.pdb(refs, inds = core)
  
  # extract the rmsd value from the result
  rmsd <- pdbfit_result$rmsd
  
  # add the rmsd value to the list
  rmsd_values[[model_file]] <- rmsd
}

# print out the rmsd values
print(rmsd_values)
