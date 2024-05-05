#' Look up the journey id for a give document
#'
#' @param guid_hash Journey global unique identifier to look up in the elasticsearch. 
#' @param tidy Tidy the results into a nested tibble [DEFAULT: TRUE].
#'
#' @return tibble.
#' @export
#'
#' @examples
#' # Lookup the for journey.
#' \dontrun{
#' document_journey(guid_hash ="704016213cd70d8cdc58")
#' }
#' 

document_journey <- function(guid_hash, tidy = TRUE){
  
  url <- glue(base_url(), "/journeys/{guid_hash}")
  
  response <- GET(url)
  
  check_response_error(response)
  check_response_json(response)
  
  if(!tidy){
    return(content(response))
  }
  
  out <- content(response) %>% lapply(parser_meta) %>% bind_rows
  
  return(out)
  
}