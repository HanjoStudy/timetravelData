#' Return the traveller information for given journey id
#'
#' @param journey_id Journey global unique identifier to look up in the elasticsearch (see \code{document_journey}). 
#' @param tidy Tidy the results into a nested tibble [DEFAULT: TRUE].
#'
#' @return tibble.
#' @export
#'
#' @examples
#' # Search for traveller.
#' \dontrun{
#' document_traveller(journey_id ="adams_j_1823")
#' }
#' 

document_traveller <- function(journey_id, tidy = TRUE){
  
  url <- glue(base_url(), "/travellers/{journey_id}")
  
  response <- GET(url)
  
  check_response_error(response)
  check_response_json(response)
  
  if(!tidy){
    return(content(response))
  }
  
  out <- content(response) %>% lapply(parser_meta) %>% bind_rows
  
  return(out)
  
}