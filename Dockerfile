FROM gcr.io/broad-getzlab-workflows/base_image:v0.0.5

WORKDIR /build
# build steps go here
# remember to clear the build directory!
RUN apt-get update && \
	apt-get install -y r-base
RUN R -e "install.packages(c('optparse', 'data.table'), dependencies=TRUE, repos='http://cran.rstudio.com/')"
WORKDIR /app
ENV PATH=$PATH:/app
COPY src/ .
