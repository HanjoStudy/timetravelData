#' Return the meta data for a given document
#'
#' @param guid_hash Document global unique identifier to look up in the elasticsearch. 
#' @param tidy Tidy the results into a nested tibble [DEFAULT: TRUE].
#'
#' @return tibble.
#' @export
#'
#' @examples
#' # Search for document.
#' \dontrun{
#' document_meta(guid_hash ="1c5c4be6f456e84d992c")
#' }
#' 

document_meta <- function(guid_hash, tidy = TRUE){
  
  url <- glue(base_url(), "/doc_meta/{guid_hash}")
  
  response <- GET(url)
  
  check_response_error(response)
  check_response_json(response)
  
  if(!tidy){
    return(content(response))
  }
  
  out <- tibble(data.frame(content(response)))
  return(out)
  
}