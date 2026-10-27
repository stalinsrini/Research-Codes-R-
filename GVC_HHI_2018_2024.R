# Global Value Chain (GVC) foreign-input sourcing concentration
# HHI calculation for 2018-2024
#
# Expected input: a data.frame/data.table named bilateral_all with columns:
#   year, supplier_country, purchaser_country, flow
# Each row represents a bilateral intermediate-input flow.
#
# This is a reconstructed implementation of the HHI calculation recovered
# from a prior ChatGPT discussion, not the complete original script.
# Validate the OECD ICIO extraction and flow definitions before use.

suppressPackageStartupMessages({
  library(data.table)
})

calculate_gvc_hhi <- function(bilateral_all) {
  required_cols <- c("year", "supplier_country", "purchaser_country", "flow")
  missing_cols <- setdiff(required_cols, names(bilateral_all))

  if (length(missing_cols) > 0) {
    stop("Input is missing required column(s): ",
         paste(missing_cols, collapse = ", "))
  }

  dt <- as.data.table(copy(bilateral_all))

  if (!is.numeric(dt$flow)) stop("`flow` must be numeric.")
  if (anyNA(dt[, ..required_cols])) {
    stop("Required input columns contain missing values.")
  }
  if (any(dt$flow < 0, na.rm = TRUE)) {
    warning("Negative flows detected; standard HHI interpretation assumes non-negative flows.")
  }

  # Exclude domestic supplier-purchaser flows.
  foreign_flows <- dt[supplier_country != purchaser_country]
  if (nrow(foreign_flows) == 0L) {
    stop("No foreign supplier flows remain after excluding domestic flows.")
  }

  # Aggregate duplicate supplier-purchaser-year rows.
  foreign_flows <- foreign_flows[
    , .(flow = sum(flow)),
    by = .(year, supplier_country, purchaser_country)
  ]

  # Calculate total foreign inputs and supplier shares by purchaser and year.
  foreign_flows[
    , total_foreign_inputs := sum(flow),
    by = .(year, purchaser_country)
  ]
  foreign_flows[
    , foreign_share := fifelse(
      total_foreign_inputs > 0, flow / total_foreign_inputs, NA_real_
    )
  ]

  # HHI = sum of squared supplier shares; effective partners = 1 / HHI.
  diversification <- foreign_flows[
    , {
      valid_shares <- foreign_share[!is.na(foreign_share)]
      hhi <- if (length(valid_shares) > 0L) sum(valid_shares^2) else NA_real_
      .(
        total_foreign_inputs = unique(total_foreign_inputs)[1],
        HHI = hhi,
        effective_partners = if (!is.na(hhi) && hhi > 0) 1 / hhi else NA_real_,
        supplier_count = uniqueN(supplier_country)
      )
    },
    by = .(year, purchaser_country)
  ]

  list(
    supplier_shares = foreign_flows[],
    diversification = diversification[order(year, purchaser_country)]
  )
}

# Example:
# library(data.table)
# bilateral_all <- fread("CIPS_bilateral_intermediate_flows.csv")
# bilateral_all <- bilateral_all[year >= 2018 & year <= 2024]
# hhi_results <- calculate_gvc_hhi(bilateral_all)
# fwrite(hhi_results$supplier_shares, "GVC_foreign_supplier_shares_2018_2024.csv")
# fwrite(hhi_results$diversification, "GVC_HHI_effective_partners_2018_2024.csv")
#
# This calculation includes ALL foreign suppliers. To calculate an HHI for
# selected partners only (e.g., China, USA, India), filter supplier_country
# before calling the function and label that measure separately.
