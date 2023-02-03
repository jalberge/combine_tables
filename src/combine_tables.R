#!/usr/bin/env Rscript

require(data.table)
require(optparse)

option_list <- list( 
  make_option(c("-l", "--filelist"), action="store", type='character', 
              help="comma-separated list of files to combine"), 
  make_option(c("-n", "--samplenames"), default=NULL, action="store", type='character', 
              help="comma-separated list of names (optional)"), 
  make_option(c("-s", "--fieldseparator"), default="auto", action="store", type='character',
              help="Input file field separator (default: trust R/data.table)"),
  make_option(c("-t", "--outputfieldseparator"),  default="\t", action="store", type='character',
              help="Output file field separator"), 
  make_option(c("-m", "--matchcolumnsbyname"), action="store_true", default=TRUE,
              help="Match columns by 'name' (or by 'position')"),    
  make_option(c("-fd", "--fixdates"), action="store_true", default=FALSE,
              help="Convert IDate / Date to character column type"),  
  make_option(c("-o", "--outputfile"), default="out.txt", action="store",
              help="Output file name"),  
  make_option(c("-q", "--quote"), default="\"", action="store",
              help="Read this character as a quote (see data.table::fread documentation). Set to '' for maf files"),
  make_option(c("-c", "--fillcolumns"), default=TRUE, action="store_true",
              help="(from rbindlist doc) 'fills missing columns'. Automatically sets matchcolumnsbyname to TRUE")
)

# get command line options, if help option encountered print help and exit,
# otherwise if options not found on command line then set defaults, 
opt <- parse_args(OptionParser(option_list=option_list))

message("arguments: ")
str(opt)

if(opt$samplenames=="NULL") opt$samplenames <- NULL

file.list <- as.list(strsplit(opt$filelist, ",")[[1]])
if(!is.null(opt$samplenames)) names.list <- as.list(strsplit(opt$samplenames, ",")[[1]])
  
message("list of files: ", file.list)
message("number of elements: ", length(file.list))
ptm <- proc.time()
lf <- lapply(file.list, fread, sep=opt$fieldseparator, quote=opt$quote, )
if(!is.null(opt$samplenames)) names(lf) <- names.list

message("finished reading")
proc.time() - ptm

if(opt$fixdates==TRUE) {
  message("fix bug where dates imported in text vs date in two data frames can't be merged with rbindlist")
  message("converting back dates to character")
  lf <- lapply(lf, function(x) {
    names_dates <- which(sapply(x, function(y) "Date" %in% class(y)))
    for(col in names_dates)
      set(x, j = col, value = as.character(x[[col]]))
    x
  })
}

dt <- rbindlist(lf, 
                use.names = opt$matchcolumnsbyname, 
                fill=opt$fillcolumns, 
                idcol = !is.null(opt$samplenames))

message("writing ", nrow(dt), " rows.")
ptm <- proc.time()
fwrite(dt, file = opt$outputfile, sep=opt$outputfieldseparator)
proc.time() - ptm
message("finished writing")

