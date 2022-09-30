#' Search the database
#'
#' @param query Specify the text query to send to elasticsearch. 
#' @param tidy Tidy the results into a nested tibble [DEFAULT: TRUE].
#' @param from_pos [OPTIONAL] Parameter to paginate through result.
#'
#' @return tibble.
#' @export
#'
#' @examples
#' # Look for the term cotton.
#' \dontrun{
#' query_text(
#'    query ="cotton", 
#'    from_pos = 0, 
#'    tidy = TRUE
#'    )
#' }
#' 
query_text <- function(query, from_pos = 0, tidy = TRUE){
  
  url <- glue(base_url(), "/journals_text/{URLencode(query)}?from_pos={from_pos}")
  
  response <- GET(url)
  
  check_response_error(response)
  check_response_json(response)
  
  if(!tidy){
    return(content(response))
  }
  
  out <- content(response) %>% parser
  return(out)

}