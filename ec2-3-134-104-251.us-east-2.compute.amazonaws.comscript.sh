#!/bin/bash
exec &> /home/ubuntu/post_install.txt
ls -lah
sudo apt-get update -y
git clone https://github.com/fdrennan/docker_pull_postgres.git || echo 'Directory already exists...'
docker-compose -f docker_pull_postgres/docker-compose.yml pull
docker-compose -f docker_pull_postgres/docker-compose.yml down
docker-compose -f docker_pull_postgres/docker-compose.yml up -d
git clone https://github.com/fdrennan/productor.git
cd /home/ubuntu/productor && echo SERVER=beta >> .env
cd /home/ubuntu/productor && echo SERVER=beta >> .bashrc
cd /home/ubuntu/productor && echo SERVER=beta >> .Renviron
cd productor && git reset --hard
cd /home/ubuntu/productor && sudo /usr/bin/Rscript update_env.R
cd /home/ubuntu/productor && git checkout beta && git pull origin beta && git branch
cd /home/ubuntu/productor && docker-compose -f docker-compose-beta.yaml pull
cd /home/ubuntu/productor && docker-compose -f docker-compose-beta.yaml up -d --build productor_postgres
cd /home/ubuntu/productor && docker-compose -f docker-compose-beta.yaml up -d --build productor_initdb
cd /home/ubuntu/productor && docker-compose -f docker-compose-beta.yaml up -d
touch /home/ubuntu/productor_logs_complete
