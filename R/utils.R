#' Check that API response is JSON
#'
#' @param response A response object.
#'
#' @return NULL. Raises an error if the response is not JSON.
check_response_json <- function(response) {
  if (http_type(response) != "application/json") {
    stop("API did not return json.", call. = FALSE)
  }
}

#' Helps to parse the output from the query API
#'
#' @param x A response object.
#'
#' @return tibble
parser_meta <- function(x, full_text = FALSE){
  tibble(data.frame( lapply(x, function(x) ifelse(is.null(x), NA, x))))
  
}

#' Helps to parse the output from the query API
#'
#' @param x A response object.
#'
#' @return tibble
parser <- function(x, full_text = FALSE){
  
  res <- tibble(
    guid_hash = unlist(x$source$guid_hash),
    translate = unlist(x$source$translate),
    pg_nr = unlist(x$source$pg_nr),
    tokens = unlist(x$source$tokens),
    english_words = unlist(x$source$english_words),
    hightlight = lapply(x$hightlight, function(x) unlist(x$text))
  ) 
  
  if(full_text){
    out <- x$full_text
    if(length(out))
      res$full_text <- x$full_text
  }
  
  return(res)
}

#' Check API response for errors
#'
#' @param response A response object.
#'
#' @return NULL. Raises an error if response has an error code.
check_response_error <- function(response) {
  if (http_error(response)) {
    status <- status_code(response)
    error <- glue("API request failed [{status}]")
    
    message <- content(response)$detail
    if (!is.null(message)) {
      error <- glue("{error}: {message}")
    }
    
    stop(error, call. = FALSE)
  }
}

#' Wrapper for httr::GET()
#'
#' @param url URL to retrieve.
#' @param config Additional configuration settings.
#' @param ... Further named parameters.
#' @param retry Number of times to retry request on failure.
GET <- function(url = NULL, config = list(), retry = 5, ...) {
  headers = list()
  
  api_key <- NULL
  try(api_key <- get_api_key(), silent = TRUE)
  
  if (!is.null(api_key)) {
    headers = list("token" = api_key)
  }
  
  response <- httr::RETRY(
    "GET",
    url,
    config,
    httr::user_agent(glue("timetravelData [R] ({PKG_VERSION})")),
    ...,
    do.call(add_headers, headers),
    handle = NULL,
    times = retry,
    terminate_on = c(400, 404, 429, 500)
  )
  
  # Check for "400 UNAUTHORISED".
  # Check for "429 LIMIT EXCEEDED".
  if (response$status_code %in% c(400, 429)) {
    out <- response %>% 
      content(as = "text", encoding = "UTF-8") %>%
      fromJSON() %>%
      toJSON(pretty = TRUE)
    
    stop(out, call. = FALSE)
  }
  
  response
}