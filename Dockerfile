FROM rstudio/plumber:latest

RUN apt-get update && apt-get install -y \
	tini \
	libmariadb-dev \
	libmysqlclient21 \
	openjdk-8-jdk-headless \
	&& rm -rf /var/lib/apt/lists/*

RUN install2.r --error --skipinstalled \
	tidyverse \
	pool \
	clock \
	config \
	uuid \
	readr \
	RMariaDB \
	DBI \
	&& rm -rf /tmp/downloaded_packages

RUN Rscript -e "remotes::install_version('h2o', '3.36.1.2')"

COPY ./IIT-Prediction/model/V4 /app/model
COPY ./SQL/iit_prod_data_extract.sql /app/iit_prod_data_extract.sql
COPY ./Docker Files/plumber.R /app/plumber.R

EXPOSE 8000

ENTRYPOINT ["tini", "--", "R", "-e", "pr <- plumber::plumb(rev(commandArgs())[1]); args <- list(host = '0.0.0.0', port = 8000); if (packageVersion('plumber') >= '1.0.0') { pr$setDocs(TRUE) } else { args$swagger <- TRUE }; do.call(pr$run, args)"]

CMD ["/app/plumber.R"]
