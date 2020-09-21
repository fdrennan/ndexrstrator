library(renv)
library(fs)
file_delete("ec2*")
install('fdrennan/biggr', rebuild = TRUE)
install('fdrennan/ndexpg', rebuild = TRUE)
install('fdrennan/ndexssh', rebuild = TRUE)
devtools::install(
  reload = TRUE,
  dependencies = TRUE,
  force = TRUE,
  upgrade = "always"
)

