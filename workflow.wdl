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
    
    String docker = "gcr.io/broad-getzlab-mm-germline/combine_tables@sha256:dbf747de8061c5fcebc635cc11597e513618d80cbfa672883a2254c89cf9246e"
    String? fieldseparator = "auto"
    String? outputfieldseparator = "$'\t'"
    Boolean quote_delimited_fields = true
  }
    
  String output_name = pSetID + "." + extension
  
  command {
    Rscript /app/combine_tables.R \
      --filelist=${sep="," input_files} \
      --outputfile=${output_name} \
      --fieldseparator=${fieldseparator} \
      --outputfieldseparator=${outputfieldseparator} \
      --quote=${true="\\\"" false="" quote_delimited_fields} \
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