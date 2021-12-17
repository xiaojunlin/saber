#' @title Get your access token
#' @description Get your access token
#' @import httr
#' @param api_key The API Key
#' @param secret_key The Secret Key
#' @return access token.
#' @references  https://cloud.baidu.com/doc/NLP/s/Qk3pmn3s7
#' @export getAccesstoken 
#' @examples
#' \dontrun{
#' access_token = getAccesstoken(api_key = "xxxxxxxx", secret_key = "xxxxxxxx")
#' }
#' 
getAccesstoken <- function(api_key, secret_key){
  url = paste0("https://aip.baidubce.com/oauth/2.0/token?grant_type=client_credentials&client_id=", api_key,
             "&client_secret=", secret_key)
  res <- POST(url = url)
  access_token <- content(res)$access_token
  return(access_token)
}