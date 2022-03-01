#!/usr/bin/env Rscript

require(data.table)
require(optparse)

option_list <- list( 
  make_option(c("-l", "--filelist"), action="store", type='character', 
              help="comma-separated list of files to combine"), 
  make_option(c("-s", "--fieldseparator"), default="auto", action="store", type='character',
              help="Input file field separator (default: trust R/data.table)"),
  make_option(c("-t", "--outputfieldseparator"),  default="\t", action="store", type='character',
              help="Output file field separator"), 
  make_option(c("-m", "--matchcolumnsbyname"), action="store_true", default=TRUE,
              help="Match columns by 'name' (or by 'position')"),  
  make_option(c("-o", "--outputfile"), default="out.txt", action="store",
              help="Output file name"),
  make_option(c("-c", "--fillcolumns"), default=TRUE, action="store_true",
              help="(from rbindlist doc) 'fills missing columns'. Automatically sets matchcolumnsbyname to TRUE")
)

# get command line options, if help option encountered print help and exit,
# otherwise if options not found on command line then set defaults, 
opt <- parse_args(OptionParser(option_list=option_list))

message("arguments: ")
str(opt)

file.list <- as.list(strsplit(opt$filelist, ",")[[1]])

message("list of files: ", file.list)
message("number of elements: ", length(file.list))
ptm <- proc.time()
lf <- lapply(file.list, fread, sep=opt$fieldseparator)
message("finished reading")
proc.time() - ptm
dt <- rbindlist(lf, use.names = opt$matchcolumnsbyname, fill=opt$fillcolumns)
message("writing ", nrow(dt), " rows.")
ptm <- proc.time()
fwrite(dt, file = opt$outputfile, sep=opt$outputfieldseparator)
proc.time() - ptm
message("finished writing")

