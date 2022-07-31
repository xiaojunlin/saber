#' @title Standardization of address
#' @description Standardization of address using Baidu natural language processing api easily in R
#' @import data.table
#' @import httr
#' @importFrom jsonlite fromJSON toJSON
#' @importFrom stats complete.cases
#' @importFrom utils txtProgressBar setTxtProgressBar
#' @param data Data set
#' @param address The column name of address
#' @param confidence This parameter is used to trigger the supplementary resolution strategy, and perform supplementary resolution on the results with confidence below the configuration value to improve the accuracy of the results. confidence = 100 by default.
#' @param retry The times of retry when return empty results. retry = 3 by default.
#' @return data.table
#' @references  https://cloud.baidu.com/doc/NLP/s/Qk3pmn3s7
#' @export getAddress
#' @examples
#' \dontrun{
#' results <- getAddress(data = df, address = "addr")
#' }
#'

getAddress <- function(data, address, confidence = 100, retry = 3) {
  if (is.null(getOption("access_token"))) {
    stop("Please fill your access token using ' options(access_token = 'xxxxxxxxxxxx') ' ")
  }
  # settings
  options(digits=9)
  baidu_api <- paste0("https://aip.baidubce.com/rpc/2.0/nlp/v1/address?access_token=", getOption("access_token"), "&charset=UTF-8" )
  df <- as.data.table(data)
  results <- data.table()
  pb <- txtProgressBar(max = df[, .N], style = 3, char = ":", width = 70)
  # loop
  for (i in seq(1, df[, .N], 1)){
    body_addr <- toJSON(list(text = df[[address]][i], confidence = confidence), auto_unbox = TRUE)
    res <- POST(url = baidu_api, body = body_addr)
    tmp <- as.data.table(content(res))
    # if return missing data, then try again
    for (j in 1:retry) {
      if (ncol(tmp) != 15) {
        res <- POST(url = baidu_api, body = body_addr)
        tmp <- as.data.table(content(res))
      }
    }
    # if the returns remain empty, then fill missing data with NA
    if (ncol(tmp) != 15) {
      tmp <- data.table(lat = NA, detail= NA, town = NA,
                                    phonenum = NA, city_code = NA,  province = NA,
                                    person = NA, lng = NA, province_code = NA, text = df[[address]][i],
                                    county = NA, city = NA, county_code = NA, town_code = NA,   log_id = NA )
    }
    results <- rbind(results, tmp)
    setTxtProgressBar(pb, i)
  }
  # clean results
  results <- results[, formatted_address := paste0(province, city, county, town, detail)
                     ][, .(text, formatted_address, lng, lat, province, city, county, town, detail,
                           province_code, city_code, county_code, town_code)
                       ][is.na(province) == T, formatted_address := NA]
  setnames(results, "text", "original_address")
  final_results <- cbind(data, results)
  # mini report
  succ_rate <- round(sum(complete.cases(results[, lng])) / results[,.N] * 100, 1)
  fail_rate <- round(100 - succ_rate, 1)
  cat(paste0("\nSuccess:", succ_rate, "%", " | ", "Failure:", fail_rate, "%\n"))
  return(final_results)
}
