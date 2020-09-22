#' build_service
#' @description The workhorse
#' @importFrom purrr map
#' @importFrom glue glue
#' @importFrom furrr future_map2
#' @importFrom fs file_delete
#' @importFrom ndexssh execute_command_to_server
#' @importFrom ndexssh send_file
#' @export build_service
build_service <- function(dns_names = NULL, stages = NULL) {

  stage_scripts <-
    map(stages,
        function(stage) {
          command_block <- c(
            "#!/bin/bash",
            "exec &> /home/ubuntu/post_install.txt",
            "ls -lah",
            "sudo apt-get update -y",
            "git clone https://github.com/fdrennan/docker_pull_postgres.git || echo 'Directory already exists...'",
            "docker-compose -f docker_pull_postgres/docker-compose.yml pull",
            "docker-compose -f docker_pull_postgres/docker-compose.yml down",
            "docker-compose -f docker_pull_postgres/docker-compose.yml up -d",
            "git clone https://github.com/fdrennan/interface.git",
            "echo NDEXR_VERBOSE=true >> interface/.Renviron.docker",
            "docker-compose -f interface/docker-compose.yml up -d",
            "touch /home/ubuntu/productor_logs_complete"
          )
        })

  response <-
    future_map2(stage_scripts,
                dns_names,
                function(script, dns) {
                  script_name <- glue('{dns}script.sh')
                  message(script)
                  writeLines(text = script, con = script_name)
                  message(glue('Building: ssh -i "~/fdren.pem" ubuntu@{dns}'))
                  send_file(
                    hostname = dns,
                    username = "ubuntu",
                    keyfile = "/Users/fdrennan/fdren.pem",
                    local_path = script_name,
                    remote_path = glue('/home/ubuntu/{script_name}')
                  )
                  cmd_response <- execute_command_to_server(command = glue('. /home/ubuntu/{script_name}'),
                                                            hostname = dns)
                  file_delete(script_name)
                  cmd_response
                }, .progress = TRUE)

}



