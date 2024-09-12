## 安装包
# remotes::install_github("irudnyts/openai", ref = "r6")

## 注释函数
## modified from the https://github.com/Winnie09/GPTCelltype/tree/master
gptcelltype <- function(input, tissuename=NULL, model='gpt-3.5-turbo', topgenenumber = 10, 
                        p_val_adj.threshold = 0.05, avg_log2FC.threshold = 0, 
                        base_url='https://api.openai.com/v1') {
  OPENAI_API_KEY <- Sys.getenv("OPENAI_API_KEY")
  if (OPENAI_API_KEY == "") {
    message("Note: OpenAI API key not found: returning the prompt itself.")
    return(data.frame(Cell_Type = "API key not found", Explanation = "API key not found"))
  }

  # API test module
  tryCatch({
    client <- openai::OpenAI(base_url = base_url)
    test_completion <- client$chat$completions$create(
      model = model,
      messages = list(list("role" = "user", "content" = "What's up?"))
    )
    message("API test successful. Response: ", strsplit(test_completion$choices[[1]]$message$content, '\n')[[1]][1])
  }, error = function(e) {
    stop("API test failed. Error: ", e$message)
  })

  if (class(input) == 'list') {
    input <- sapply(input, paste, collapse=',')
  } else {
    input <- input[input$avg_log2FC > avg_log2FC.threshold & input$p_val_adj < p_val_adj.threshold, , drop=FALSE]
    input <- tapply(input$gene, list(input$cluster), function(i) paste0(i[1:min(topgenenumber, length(i))], collapse=','))
  }

  ## check input length
  if (length(input) == 0) {
    stop("No input provided. Please check your input data.")
  } else if (length(input) < topgenenumber) {
     message("Note: The number of input markers is less than the topgenenumber. Please check your input data.")
  }

  # Create OpenAI client with custom base_url if provided
  client <- if (!is.null(base_url)) openai::OpenAI(base_url = base_url) else openai::OpenAI()

  process_cluster <- function(cluster_name, markers) {
    message(sprintf("Processing cluster %s...", cluster_name))
    
    # First round: Analysis
    analysis_prompt <- sprintf('Analyze the following markers for %s cells in cluster %s and determine the most likely cell type(s). Provide a concise explanation for your reasoning:\n%s', tissuename, cluster_name, markers)
    analysis_response <- client$chat$completions$create(
      model = model,
      messages = list(list("role" = "user", "content" = analysis_prompt))
    )
    analysis <- analysis_response$choices[[1]]$message$content

    # Second round: Cell type name only
    name_prompt <- sprintf('Based on your previous analysis, provide only the cell type name(s) for the cluster. Do not include any explanation or numbering.')
    name_response <- client$chat$completions$create(
      model = model,
      messages = list(
        list("role" = "user", "content" = analysis_prompt),
        list("role" = "assistant", "content" = analysis),
        list("role" = "user", "content" = name_prompt)
      )
    )
    cell_type <- name_response$choices[[1]]$message$content

    list(cell_type = gsub(',$', '', cell_type), explanation = analysis)
  }

  # Process each cluster
  results <- lapply(seq_along(input), function(i) {
    cluster_name <- names(input)[i]
    markers <- input[[i]]
    process_cluster(cluster_name, markers)
  })

  # Combine results into a data frame
  result <- data.frame(
    Cluster = names(input),
    Markers = unlist(input),
    Cell_Type = sapply(results, function(x) x$cell_type),
    Explanation = sapply(results, function(x) x$explanation)
  )

  message('Note: It is always recommended to check the results returned by the model in case of AI hallucination, before proceeding to down-stream analysis.')
  return(result)
}

## test markers
# input <- list('CD3D,CD3E,CD3G,CD4')
# gptcelltype(input, tissuename='brain', model='gpt-4o-mini', topgenenumber = 10, base_url='https://aihubmix.com/v1')
