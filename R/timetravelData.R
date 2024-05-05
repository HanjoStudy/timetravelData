BASE_URL <- "https://elastic.timetraveller.voyage/v1/"

PKG_VERSION <- utils::packageDescription('timetravelData')$Version

cache <- new.env()

# Avoid some "no visible binding" notes with devtools::check().
# globalVariables(
#   c(
#   )
# )

#' @import jsonlite
#' @import tibble
#' @importFrom dplyr arrange bind_rows
#' @importFrom magrittr %>%
#' @importFrom utils URLencode
#' @importFrom glue glue
#' @importFrom glue glue_collapse
#' @importFrom httr add_headers
#' @importFrom httr http_error
#' @importFrom httr http_type
#' @importFrom httr content
#' @importFrom httr status_code

assign("base_url", BASE_URL, envir = cache)

#' Set IP and port for API server when testing
#'
#' @param ip IP address for API server.
#' @param port Port on which API is running.
#'
#' @export
#'
#' @examples
#' # Use local server
#' set_server("0.0.0.0", 8080)
set_server <- function(ip, port) {
  assign("base_url", sprintf("http://%s:%d/", ip, port), envir = cache)
}

#' Set base URL for API  when testing
#'
#' @param url URL to access API.
#'
#' @export
#'
#' @examples
#' # Use local server
#' set_base_url("http://0.0.0.0:8080/")
set_base_url <- function(url) {
  assign("base_url", url, envir = cache)
}

#' Get base URL for API
#'
#' @return API base URL.
base_url <- function() {
  get("base_url", envir = cache)
}

#' Set API key
#'
#' Specify the key for accessing the timetravelData API. 
#' Automatically determines which type of key is being used and authenticates appropriately.
#'
#' @param api_key API key.
#'
#' @export
#'
#' @examples
#' # Authenticate using an API key.
#' set_api_key("412dd2813fbf9037f5266557bbf5d1f5")
#'
set_api_key <- function(api_key) {
  
  if (nchar(api_key) > 10) {
    if(Sys.getenv("TIMETRAVELDATA_KEY") != ""){
      message("WARNING, an API key was found in .Renviron: TIMETRAVELDATA_KEY, it was replaced with key supplied.")  
      assign("api_key", api_key, envir = cache)
    } else {
      assign("api_key", api_key, envir = cache)
    }
  } else {
    if (api_key == "" || is.na(api_key) || is.null(api_key)) {
      stop("API key is missing.", call. = FALSE)
    } else {
      stop(glue("Unknown API key type: '{api_key}'."), call. = FALSE)
    }
  }
}

#' Retrieve API key
#'
#' @return API key.
#' @export
#'
#' @examples
#' \dontrun{
#' set_api_key("412dd2813fbf9037f5266557bbf5d1f5")
#' get_api_key()
#' }
get_api_key <- function() {
  if(Sys.getenv("TIMETRAVELDATA_KEY") == ""){
    api_key <- try(get("api_key", envir = cache), silent = TRUE)
  }
  
  if(Sys.getenv("TIMETRAVELDATA_KEY") != ""){
    api_key <- try(get("api_key", envir = cache), silent = TRUE)
    if (class(api_key) == "try-error" || api_key == ""){
      api_key <- Sys.getenv("TIMETRAVELDATA_KEY")
    } 
  }
  
  if (class(api_key) == "try-error" || api_key == "") {
    stop("Use set_api_key() to specify an API key.", call. = FALSE)
  } else {
    api_key
  }
}