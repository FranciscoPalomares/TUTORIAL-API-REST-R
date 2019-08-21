library(plumber)
r <- plumb("plumber.R")
r$run(port=4000, host='0.0.0.0',swagger=FALSE)
