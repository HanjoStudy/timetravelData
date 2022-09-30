#' Search the database and return how many hits
#'
#' @param query Specify the text query to send to elasticsearch. 
#'
#' @return tibble.
#' @export
#'
#' @examples
#' # How many hits were there for a term.
#' \dontrun{
#' query_hits(
#'    query ="cotton" 
#'    )
#' }
#' 
query_hits <- function(query){
  
  url <- glue(base_url(), "/journals_text/{URLencode(query)}")
  
  response <- GET(url)
  
  check_response_error(response)
  check_response_json(response)
  
  out <- content(response)$total_hits
  return(out)

}