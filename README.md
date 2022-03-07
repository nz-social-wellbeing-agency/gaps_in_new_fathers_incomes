# Gaps in New Fathers Incomes

Investigation into patterns of new fathers being outside paid employment about the time of the birth.

# Overview

Our previous joint project with The Southern Institute (TSI), Having a Baby in South Auckland, generated further interest (quick guide [here](https://swa.govt.nz/assets/Publications/reports/J000443_SIA_Case_study_Quick_guide_DIGITAL.pdf)). One of the strongest findings emerging from this work showed fathers exhibit a pattern of being outside paid employment (not earning income) about the time of the birth. Together TSI and the Agency decided to continue the work by investigating this finding further. The [report](https://www.tsi.nz/s/What-About-the-Menz) from this research can be found under reports on [TSI's website](https://www.tsi.nz/).

# Dependencies

The code is designed to run inside the Integrated Data Infrastructure (IDI), which is built and maintained by Stats NZ. It is necessary to have an IDI project if you wish to run the code. Visit the Stats NZ website for more information about this.

This analysis has been developed for the 20201020 refresh of the IDI. As changes in database structure can occur between refreshes, the initial preparation of the input information may require updating to run the code in other refreshes.

# Installation

To install the code, download this repository, copy it to your working location and unzip it. Researchers will first want to run the SQL files to build the analysis dataset. There are four SQL files: three setup files, followed by the main assembly script. Second, researchers will want to run the R scripts to produce summarised outputs.

Note that some SQL scripts contain parameterisation. However setting command-line parameters is not enabled by default, hence users need to activate this by clicking **Query->SQLCMD** Mode.

The codes have been tested to work on Microsoft SQL Server 2018 and R version 3.6.3, the versions in the IDI at the time of writing.

# Related work

Code from our previous partnership project with The Southern Initiative, Having a Baby in South Auckland (HaBiSA), can be found in two other repositories: The analysis and data preparation can be found under [representative timelines](https://github.com/nz-social-wellbeing-agency/representative_timelines) and the visualisation app can be found under [timeline visualisation](https://github.com/nz-social-wellbeing-agency/timeline_visualisation). You can read about the original research [here](https://swa.govt.nz/assets/Publications/reports/J000443-SIA-Print-Collateral-_-Case-study-2.3-FINAL-DIGITAL-v2.pdf) on the Agency's [website](https://swa.govt.nz/).

# Citation

Social Wellbeing Agency (2021). Gaps in new fathers incomes. Source code. https://github.com/nz-social-wellbeing-agency/gaps_in_new_fathers_incomes

# Getting Help
General enquiries can be sent to info@swa.govt.nz.  

