#' Look up historical placenames
#'
#' @param country_iso Historical place iso. 
#' @param tidy Tidy the results into a nested tibble [DEFAULT: TRUE].
#'
#' @return tibble.
#' @export
#'
#' @examples
#' # Search for historical placename
#' \dontrun{
#' historical_placenames(country_iso ="KEN")
#' }
#' 

historical_placenames <- function(country_iso, tidy = TRUE){
  
  url <- glue(base_url(), "/country_names/{country_iso}")
  
  response <- GET(url)
  
  check_response_error(response)
  check_response_json(response)
  
  if(!tidy){
    return(content(response))
  }
  
  out <- content(response) %>% lapply(parser_meta) %>% bind_rows
  
  return(out)
  
}