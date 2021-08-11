#################################################
# Project: Gaps in New Fathers Income
# Author: Raj Kulkarni
# Purpose: Produce descriptive summaries of income
#################################################

library(RODBC)
library(DBI)
library(tidyverse)
library(data.table)
library(stringr)
library(openxlsx)
library(combinat)

source("./functions.R")

# Initiate connection
db_connection <- dbi_con()

# Query from SQL
query <- "SELECT * 
  FROM [IDI_Sandpit].[DL-MAA20xx-xx].[population]" # Change this to your sandpit name

# Execute query and store results in R
gnife_main <- 
  DBI::dbGetQuery(db_connection, statement = query %>% as.character())

# Disconnect connectiion
DBI::dbDisconnect(db_connection)
rm(db_connection)

# Mutating variables to fit purpose of analysis
gnife_mod <- gnife_main %>%
  left_join(high_qual_concord) %>%
  select(-parent_highqual_at_birth) %>%
  filter(parent_age_at_birth > 13) %>%
  mutate(
    parent_age_at_birth_grp = ifelse(
      parent_age_at_birth < 20,
      "<20",
      ifelse(
        parent_age_at_birth >= 20 & parent_age_at_birth < 30,
        "20-30",
        ifelse(
          parent_age_at_birth >= 30 & parent_age_at_birth < 40,
          "30-40",
          ifelse(
            parent_age_at_birth >= 40 & parent_age_at_birth < 50,
            "40-50",
            ifelse(parent_age_at_birth >= 50, "50+", parent_age_at_birth)
          )
        )
      )
    ),
    
    work_hours = ifelse(total_fte_worked >= 0.9, "full_time", 
                        ifelse(total_fte_worked >= 0.5 & total_fte_worked < 0.9, "part_time_20-35",
                               ifelse(total_fte_worked < 0.5 & total_fte_worked > 0, "part_time_less_20", 
                                      ifelse(total_fte_worked == 0, "not_working", total_fte_worked
                                      )
                               )
                        )
    )
    
  ) %>%
  group_by(snz_uid, parent_snz_uid) %>%
  mutate(cu_n_emp_changes = cumsum(new_emp_change_flag)) %>%
  ungroup() %>% 
  mutate(
    cu_n_emp_changes = ifelse(cu_n_emp_changes > 6, "6+", as.character(cu_n_emp_changes-1)),
    n_months_with_employer_mod = ifelse(
      time_with_employer >= 12, "12", round(time_with_employer, 0) %>% as.character()),
    n_months_with_employer_mod = ifelse(
      n_months_with_employer_mod %in% c("1", "2", "3"),
      "1-3",
      ifelse(
        n_months_with_employer_mod %in% c("4", "5"),
        "4-5",
        ifelse(
          n_months_with_employer_mod %in% c("6", "7", "8", "9", "10", "11"),
          "6-11",
          ifelse(
            n_months_with_employer_mod %in% c("12"),
            "12+",
            ifelse(
              n_months_with_employer_mod %>% is.na(),
              "0",
              n_months_with_employer_mod
            )
          )
        )
      )
    )
  )

rm(high_qual_concord)

###-------------------------------------------------------------------------------------------------------------------###
### ---- INCOME TRAJECTORIES : ONE WAY INTERACTION WITH GEO ---- ###

## Population of Interest
poi <- c("DIA_father",
            "DIA_mother"
         )

# Geography of interest 
geos <- c("south_auckland",
          "nz")

# Income variables of interest
inc_vars <- c("inc_wages",
              "total_inc_wages_sei",
              "total_inc"
              )


# Type 1 Variables -- where variables do not change month by month (e.g. Parents age at birth is constant throughout)
type_1_vars <- c(
  "parent_age_at_birth_grp",
  "ethnicity",
  "high_qual_grp",
  "cen_occupation_description_l1"
) 

# Type 2 Variables -- where variables change month by month (e.g. Cumulative Income Group)
# Type 2 Variables are filtered for status at Month 0 (e.g. Cumulative Income Group at Month 0)
type_2_vars <- c(
  "inc_wages_grp",
  "inc_total_grp",
  "cu_n_emp_changes",
  "fluc_wages",
  "parental_leave_status"
)


t1 <- Sys.time()

inc_path <- list()
inc_path_conf <- list()


for (pop in poi) {
  message(pop)
  
  inc_table <- data.frame(
    month_after_birth = as.integer(),
    geo = as.character(),
    geo_val = as.character(),
    variable = as.character(),
    variable_name = as.character(),
    inc_type = as.character(),
    inc_value = as.double(),
    conf_inc_value = as.double(),
    count = as.integer(),
    conf_count = as.double()
  )
  
  for(geo in geos) {
    message(geo)
    
    for (inc in inc_vars) {
      
      for (var in type_1_vars) {
        
        if (var == "ethnicity") {
          people <- gnife_mod %>%
            filter(month_after_birth == 0,
                   parent_relationship %in% pop) %>%
            select(snz_uid, parent_snz_uid, par_eth) %>%
            distinct() %>%
            rename(
              "European" = parent_eu,
              "Maori" = parent_maori,
              "Pasific" = parent_pasific,
              "Asian" = parent_asian,
              "MELAA" = parent_melaa,
              "Other" = parent_other_eth
            ) %>%
            gather(ethnicity, val, -c(snz_uid, parent_snz_uid)) %>%
            filter(val == T) %>%
            select(-val) %>%
            select(parent_snz_uid, ethnicity) %>%
            distinct()
        } else{
          people <- gnife_mod %>%
            filter(month_after_birth == 0,
                   parent_relationship %in% pop) %>%
            select(parent_snz_uid) %>%
            distinct()
        }
        
        inc_name <- str_c("avg_", inc, collapse = T)
        
        if(geo == "nz") grp = var else grp = c(geo, var)
        
        df <- gnife_mod %>%
          inner_join(people) %>%
          select(snz_uid,
                 parent_snz_uid,
                 month_after_birth,
                 one_of(grp, inc)) %>%
          group_by_at(.vars = c('month_after_birth', grp)) %>%
          summarise(count = n(), !!inc_name := mean(get(inc))) %>%
          ungroup() 
        
        if(geo == "nz"){
          df <- df %>% 
            mutate(!!geo := geo) 
        }
        
        df <- df %>% 
          gather(variable,
                 variable_name,-c(month_after_birth, count, geo, all_of(inc_name))) %>%
          gather(inc_type,
                 inc_value,-c(month_after_birth, variable, variable_name, geo, count)) %>%
          gather(geo,
                 geo_val,-c(month_after_birth, variable, variable_name, inc_type, inc_value, count)) %>%
          mutate(
            variable_name = as.character(variable_name),
            geo_val = as.character(geo_val),
            conf_count = count %>% apply_conf(),
            conf_inc_value = ifelse(count < 20, NA, inc_value)
          ) %>%
          select(
            month_after_birth,
            geo,
            geo_val,
            variable,
            variable_name,
            inc_type,
            inc_value,
            conf_inc_value,
            count,
            conf_count
          )
        
        inc_table <- inc_table %>%
          bind_rows(df)
        
      }
      
      print("Type 2 Variables")
      ######################################################################################################################
      #----- Type 2 Variables 
      for(var in type_2_vars){
        
        if(geo == "nz") grp = var else grp = c(geo, var)
        
        # geo, inc, var
        people <- gnife_mod %>%
          filter(month_after_birth == 0,
                 parent_relationship %in% pop) %>%
          select(snz_uid, parent_snz_uid, all_of(grp)) %>%
          distinct()
        
        inc_name <- str_c("avg_", inc, collapse = T)
        
        df <- gnife_mod %>%
          select(snz_uid, parent_snz_uid, month_after_birth, inc) %>%
          inner_join(people) %>%
          group_by_at(.vars = c('month_after_birth', grp)) %>%
          summarise(count = n(), 
                    !!inc_name := mean(get(inc))
          ) %>%
          ungroup() 
        
        if(geo == "nz"){
          df <- df %>% 
            mutate(!!geo := geo) 
        }
        
        df <- df %>% 
          gather(variable,
                 variable_name,
                 -c(month_after_birth, count, geo, all_of(inc_name))) %>%
          gather(inc_type,
                 inc_value,-c(month_after_birth, variable, geo, variable_name, count)) %>%
          gather(geo,
                 geo_val,-c(month_after_birth, variable, variable_name, inc_type, inc_value, count)) %>%
          mutate(
            variable_name = as.character(variable_name),
            geo_val = as.character(geo_val),
            conf_count = count %>% apply_conf(),
            conf_inc_value = ifelse(count < 20, NA, inc_value)
          ) %>%
          select(
            month_after_birth,
            geo,
            geo_val,
            variable,
            variable_name,
            inc_type,
            inc_value,
            conf_inc_value,
            count,
            conf_count
          )
        
        inc_table <- inc_table %>%
          bind_rows(df)

      }
    }
  }
  inc_path[[pop]] <- inc_table
  inc_path_conf[[pop]] <- inc_table %>% select(-c(inc_value, count))
  
}

(Sys.time() - t1)

# 
# # Saving otuputs 
# for(pop in poi){
#   fname <- str_c(pop, "INC_income_trajectories")
#   saveRDS(inc_path[[pop]], file = str_c("./",fname,".rds"))
#   saveRDS(inc_path_conf[[pop]], file = str_c("./",fname,".rds"))
#   
# }
