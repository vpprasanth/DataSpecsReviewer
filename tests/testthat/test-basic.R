testthat::test_that("package namespace loads", {
  testthat::expect_true(is.function(DataSpecsReviewer::data_review))
})
