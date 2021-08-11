#################################################
# Project: Gaps in New Fathers Income
# Author: Raj Kulkarni
# Purpose: Produce descriptive counts
#################################################

library(RODBC)
library(DBI)
library(tidyverse)
library(data.table)
library(stringr)
library(openxlsx)
library(combinat)
library(doParallel)
library(parallel)
library(doMPI)
library(doSNOW)
source("./functions.R")

# Initiate connection
db_connection <- dbi_con()


# Query from SQL

query <- "SELECT *
  FROM [IDI_Sandpit].[DL-MAA2020-73].[time_population]" 

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


# ---------- 1 way split descriptives -------------- #

# Variables of interest to split the population
grp_vars <- c(
  'parent_age_at_birth_grp',
  'ethnicity',
  'high_qual_grp',
  'south_auckland',
  'cen_occupation_description_l1',
  'inc_total_grp'
)

# Outcome Measures of Interest
fluc_vars <- c(
  "fluc_wages",
  "fluc_wage_sei",
  "gap_wages_below_min",
  "parental_leave_status",
  "income_status"
)

# Population of Interest
poi <- c("DIA_father",
         "DIA_mother")

final_list <- list()

cl <- makeCluster(length(fluc_vars))
registerDoParallel(cl)

time <- Sys.time()

for (pop in poi) {
  final_tab <- data.frame(
    month_after_birth = as.integer(),
    variable = as.character(),
    variable_value = as.character(),
    outcome = as.character(),
    outcome_value = as.character(),
    count = as.integer(),
    conf_count = as.integer()
  )
  
  gnife_mod_1 <- gnife_mod %>%
    filter(parent_relationship %in% pop) %>%
    select(
      snz_uid,
      parent_snz_uid,
      month_after_birth,
      fluc_vars,
      any_of(grp_vars),
      par_eth
    )
  
  
  for (var in grp_vars) {
    message(paste0("Running ", paste0(var)))
    if (var == "ethnicity") {
      gnife_mod_2 <- gnife_mod_1 %>%
        select(snz_uid,
               parent_snz_uid,
               month_after_birth,
               fluc_vars,
               par_eth) %>%
        distinct() %>%
        rename(
          "European" = parent_eu,
          "Maori" = parent_maori,
          "Pasific" = parent_pasific,
          "Asian" = parent_asian,
          "MELAA" = parent_melaa,
          "Other" = parent_other_eth
        ) %>%
        gather(ethnicity,
               val,
               -c(snz_uid, parent_snz_uid, month_after_birth, fluc_vars)) %>%
        filter(val == T) %>%
        select(-val)
    } else if (var == "industry") {
      gnife_mod_2 <- gnife_mod_1 %>%
        select(snz_uid,
               parent_snz_uid,
               month_after_birth,
               fluc_vars,
               par_industry) %>%
        distinct() %>%
        gather(industry,
               val,
               -c(snz_uid, parent_snz_uid, month_after_birth, fluc_vars)) %>%
        filter(val == 1) %>%
        select(-val)
      
    } else{
      gnife_mod_2 <- gnife_mod_1 %>%
        select(snz_uid,
               parent_snz_uid,
               month_after_birth,
               fluc_vars,
               var)
    }
    
    rm(output)
    
    output <-
      foreach(
        j = 1:length(fluc_vars),
        .combine = rbind,
        .packages = c("tidyverse"),
        .verbose = F
      ) %dopar% {
        temp <- data.frame(
          month_after_birth = as.integer(),
          variable = as.character(),
          variable_value = as.character(),
          outcome = as.character(),
          outcome_value = as.character(),
          count = as.integer(),
          conf_count = as.integer()
        )
        
        fluc <- fluc_vars[j]
        
        main <- gnife_mod_2 %>%
          select(snz_uid,
                 parent_snz_uid,
                 month_after_birth,
                 all_of(var),
                 all_of(fluc)) %>%
          distinct() %>%
          group_by_at(.vars = c('month_after_birth', var, fluc)) %>%
          summarise(count = n()) %>%
          ungroup() %>%
          mutate(conf_count = count %>% apply_conf()) %>%
          gather(
            variable,
            variable_value,
            -c('month_after_birth', fluc, 'count', 'conf_count')
          ) %>%
          gather(
            outcome,
            outcome_value,
            -c(
              'month_after_birth',
              'variable',
              'variable_value',
              'count',
              'conf_count'
            )
          ) %>%
          select(
            month_after_birth,
            variable,
            variable_value,
            outcome,
            outcome_value,
            count,
            conf_count
          ) %>%
          mutate(
            variable_value = as.character(variable_value),
            outcome_value = as.character(outcome_value)
          )
        
        temp <- temp %>%
          bind_rows(main)
        
        temp
      }
    
    final_tab <- final_tab %>%
      bind_rows(output)
  }
  final_list[[pop]] <- final_tab
  
}

stopCluster(cl)

Sys.time() - time
# saveRDS(final_list, "./R/Descriptives/12-04-2021/Raw/1way_descriptive_new.rds")
# write.xlsx(final_list, "./R/Descriptives/12-04-2021/Raw/1way_descriptive_new.xlsx")
# 
# final_list_conf <- list()
# 
# final_list_conf$DIA_father <- final_list$DIA_father %>% 
#   select(-count)
# final_list_conf$DIA_mother <- final_list$DIA_mother %>% 
#   select(-count)
# 
# saveRDS(final_list_conf, "./R/Descriptives/12-04-2021/Raw/conf_1way_descriptive_new.rds")
# write.xlsx(final_list_conf, "./R/Descriptives/12-04-2021/Raw/conf_1way_descriptive_new.xlsx")

