library(RODBC)
library(DBI)
# Functions ------------------------------------------------------------------------------------------------------

# Random Rounding for count data
#' Random round to base n
#'
#' Developed by Chris Hansen (Statistics NZ)
#' Date: 30/05/16
#'
#' This function takes an object and randomly rounds integer values
#' to a base of the user's choosing
#' @param x The object to pass to the function.
#' @param n The base to randomly round to. Defaults to 3.
#' @param seed A numeric input for the seed. Optional.
#' @keywords random round
#' @export
#' @examples


rand_round <- function(x, n = 3, seed, na.rep = NA)
{
  if (!missing(seed))
    set.seed(seed)
  
  rr <- function(x, n) {
    if (is.na(x))
      return(na.rep) #modified; NA should be replaced afterwards; random round should just apply on non-missing
    if ((x %% n) == 0)
      return(x)
    res <- abs(x)
    lo <- (res %/% n) * n
    if ((runif(1) * n) <= res %% n)
      res <- lo + n
    else
      res <- lo
    return(ifelse(x < 0, (-1) * res, res))
  }
  
  isint <- function(x) {
    if (!is.numeric(x))
      return(FALSE)
    #add
    
    x <- x[!is.na(x)]
    sum(as.integer(x) == x) == length(x)
  }
  
  if (class(x) %in% c("numeric", "integer")) {
    if (isint(x))
      return(sapply(x, rr, n))
    else
      return(x)
  }
  
  for (i in 1:ncol(x))
  {
    if (class(x[, i]) %in% c("numeric", "integer") &
        isint(x[, i]))
      x[, i] <- sapply(x[, i], rr, n)
  }
  x
}

# Remove counts less than 6
apply_r6 <- function(x) {
  x <- ifelse(x < 6, NA, x)
}

# Apply confidentiality
apply_conf <- function(x) {
  x <- x %>% apply_r6() %>% rand_round()
}

# Round to nearest 1000
nearest_thousand <- function(x, base = 1000) {
  remainder <- x %% base
  x <-
    ifelse(remainder >= base / 2, base + (x - remainder), (x - remainder))
  return(x)
}

# not in function
'%!in%' <- function(x, y) {
  !('%in%'(x, y))
}


odbc_con <- function(port = "1433", db = "Database=IDI_Sandpit") {
  # Connection details
  driver <- "Driver=ODBC Driver 17 for SQL Server"
  trusted_connection <- "Trusted_Connection=YES"
  server_name <- "Server=PRTPRDSQL36.stats.govt.nz"
  
  server <- stringr::str_c(server_name, port, sep = ',')
  connection <-
    stringr::str_c(driver, trusted_connection, server, db, sep = ';')
  
  # Initiate connection
  odbc_con <- odbcDriverConnect(connection)
}


dbi_con <- function(port = "1433", db = "Database=IDI_Sandpit") {
  # Connection details
  driver <- "Driver=ODBC Driver 17 for SQL Server"
  trusted_connection <- "Trusted_Connection=YES"
  server_name <- "Server=PRTPRDSQL36.stats.govt.nz"
  
  server <- stringr::str_c(server_name, port, sep = ',')
  connection <-
    stringr::str_c(driver, trusted_connection, server, db, sep = ';')
  
  # Initiate connection
  dbi_con <-
    DBI::dbConnect(odbc::odbc(), .connection_string = connection)
  
}

#-------------- LISTS ------------------ #

par_industry <- c(
  'Agriculture_Forestry_Fishing',
  'Mining',
  'Manufacturing',
  'Electricity_Gas_Water_Waste_Services',
  'Construction',
  'Wholesale_trade',
  'Retail_trade',
  'Accomodation_and_food_services',
  'Transport_postal_and_warehousing',
  'Information_Media_and_Teleco',
  'Finance_and_Insurance_Services',
  'Rental_hiring_and_real_estate_services',
  'Professional_scientific_and_technical_services',
  'Administration_and_support_Services',
  'Public_Admin_and_safety',
  'Education_and_training',
  'Health_care_and_social_assitance',
  'Arts_and_rec_services',
  'Other_services',
  'Not_elsewhere_included'
)

par_eth <- c(
  'parent_eu',
  'parent_maori',
  'parent_pasific',
  'parent_asian',
  'parent_melaa',
  'parent_other_eth'
)

# concordance tables
high_qual_concord <- data.table(
  parent_highqual_at_birth = c(NA, 0:10),
  high_qual_grp = c(
    "0-3",
    "0-3",
    "0-3",
    "0-3",
    "0-3",
    "4-6",
    "4-6",
    "4-6",
    "7+",
    "7+",
    "7+",
    "7+"
  )
)
