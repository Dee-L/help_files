source("D:/Coding/R scripts/pkgs_and_fxns/load_pkgs_and_fxns.R") #load custom functions

setwd("D:/Coding/R scripts/")

my_wb <- loadWorkbook("R index matching.xlsx")

my_wb_sheets <- sheets(my_wb)

#pull in the tables used for lookups
newAllMice <- readWorkbook(my_wb, "AllMice")
newSampleLevels <- readWorkbook(my_wb, "SampleLevels")
newAssaySuffixes <- readWorkbook(my_wb, "AssaySuffixes")
newqPCRplate <- readWorkbook(my_wb, "qPCRplate")

#
#Pulling in and repopulating the "SampleNumbers" worksheet
#
newSampleNumbers <- readWorkbook(my_wb, "SampleNumbers") #load df

#Empty the vectors I want to repopulate
newSampleNumbers$Strain <- NULL
newSampleNumbers$Verified_genotype <- NULL
newSampleNumbers$Treatment <- NULL
newSampleNumbers$Strain_by_Genotype_by_Treatment_Level <- NULL

#
#Recreate multiple columns where only one lookup is needed
#
newSampleNumbers <-
  merge(newSampleNumbers, #df to populate with new column
        newAllMice[ , c("Mouse_Number", #df to reference and column to reference
                        "Strain", "Verified_genotype", "Treatment")], #columns to create
        by = "Mouse_Number", #column to match in both dfs
        all.x = T) %>% arrange(., Sample_Number)

#
#Recreating columns where two columns must match
#
newSampleNumbers <-
  merge(newSampleNumbers, #df to populate with new column
        newSampleLevels[ , c("Strain_by_Genotype_by_Treatment_Level", #df to reference and column to create
                             "Strain", "Verified_genotype", "Treatment", "Muscle")], #columns to reference
        by = c("Strain", "Verified_genotype", "Treatment", "Muscle"), #columns to match in both dfs
        all.x = T) %>%
  arrange(., Sample_Number)

#Now trying to replicate the lookups for the ProteinRNASamples
newProteinRNASamples <- readWorkbook(my_wb, "ProteinRNASamples")

#Nulling the columns I want to lookup
newProteinRNASamples$Protein_Sample_Number <- NULL
newProteinRNASamples$RNA_Sample_Number <- NULL

#Recreates ProteinSampleNumber by paste0 function
newProteinRNASamples$Protein_Sample_Number <-
  (merge(
    newProteinRNASamples, newSampleNumbers[ , c("Mouse_Number", "Muscle", "Sample_Number")], by = c("Mouse_Number", "Muscle"), all.x = T
  )
  ) %>% arrange(., Sample_Number) %>% .$Sample_Number %>% paste0(newAssaySuffixes[newAssaySuffixes$Assay == "Protein" , "Suffix"], .)

#Recreates RNASampleNumber by paste0 function
newProteinRNASamples$RNA_Sample_Number <-
  (merge(
    newProteinRNASamples, newSampleNumbers[ , c("Mouse_Number", "Muscle", "Sample_Number")], by = c("Mouse_Number", "Muscle"), all.x = T
  )
  ) %>% arrange(., Sample_Number) %>% .$Sample_Number %>% paste0(newAssaySuffixes[newAssaySuffixes$Assay == "RNA" , "Suffix"], .)

#Now trying to do lookups for WBmaps
newWBmaps <- readWorkbook(my_wb, "WBmaps")

#Nulling the columns I want to recreate
newWBmaps$Strain <- NULL
newWBmaps$Verified_genotype <- NULL
newWBmaps$Treatment <- NULL
newWBmaps$Muscle <- NULL

#Recreates columns by merging a table with another merged table. Also uses by.x and by.y arguments in order to match columns which have different names in different tables. Adds lookups for Strain, Verified_genotype, Treatment, Muscle
newWBmaps <-
  merge(newWBmaps, 
        merge(newProteinRNASamples,
              newSampleNumbers[ , c("Strain", "Verified_genotype", "Treatment", "Mouse_Number", "Muscle")],
              by = c("Mouse_Number", "Muscle"), all.x = T)[ , c("Protein_Sample_Number", "Strain", "Verified_genotype", "Treatment", "Muscle")],
        by.x = "Sample_Number",
        by.y = "Protein_Sample_Number", all.x = T
              )

my_wb_sheets

#Now trying to do lookups for qPCRplatelong
newqPCRplatelong <- readWorkbook(my_wb, "qPCRplatelong")

#Nulling the columns I want to recreate
newqPCRplatelong$Well_Position <- NULL
newqPCRplatelong$Sample_Number <- NULL

#Recreate Well_Position
newqPCRplatelong$Well_Position <- paste0(newqPCRplatelong$Row, newqPCRplatelong$Strip)

#The code below works for 2-dimensional indexing, i.e., indexing based on rows and columns.

rownames(newqPCRplate) <- newqPCRplate$Row

newqPCRplate$Row <- NULL

newqPCRplatelong$Sample_Number <- newqPCRplate[cbind(as.character(newqPCRplatelong$Row), as.character(newqPCRplatelong$Strip))]

#The above works. It creates a 2-column df/matrix which have the indices for the rows and columns. If you subset a df or matrix using the names of the rows and columns separated by a comma, then it will find the cell in the 2D structure to match it.
newqPCRplate[cbind("A", "1")]
cbind("A", "1") %>% class
newqPCRplate %>% class
newqPCRplate[ , 1:3] %>% .["A", "3"]

#The same can be extended to arrays, which can have more than 2 dimensions.
an.array <- array(1:12, dim = c(1, 2, 3), dimnames = list(c("Row1"), c("Column1", "Column2"), c("M1", "M2", "M3")))

an.array
an.array["Row1", "Column1", "M2"] == an.array[1, 1, 2]