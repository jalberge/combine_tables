version 1.0

workflow CombineTablesWorkflow {
  call combine_tables
  output {
    File output_table = combine_tables.output_table
  }
}

task combine_tables {
  input {
    String? memGB = 2
    String? diskGB = 10
    String pSetID
    String? extension = "txt"
    String? cpus = 2
    
    Array[File] input_files
    Array[String]? sample_names
    
    String docker = "gcr.io/broad-getzlab-mm-germline/combine_tables@sha256:bc362443c091e81c84d718c7d7f1fd64184cfb884695497f9c06f84b7d724b55"
    String? fieldseparator = "auto"
    String? outputfieldseparator = "$'\t'"
    Boolean quote_delimited_fields = true
    Boolean fix_dates = false
  }
    
  String output_name = pSetID + "." + extension
  
  command {
    Rscript /app/combine_tables.R \
      --filelist=${sep="," input_files} \
      --outputfile=${output_name} \
      --fieldseparator=${fieldseparator} \
      --outputfieldseparator=${outputfieldseparator} \
      --quote=${true="\\\"" false="" quote_delimited_fields} \
      ${true="--fixdates" false=" " fix_dates} \
      --samplenames=${sep="," default="NULL" sample_names}
      
  }
  
  output {
    File output_table=output_name
  }
  
  runtime {
    docker: docker
    disks: "local-disk " + diskGB + " HDD"
    cpu: cpus
    memory: memGB + " GB"
  }
}