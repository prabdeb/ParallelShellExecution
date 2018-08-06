# Base image
FROM perl:5.20

# Copy the code
COPY . /opt/parallel
RUN chmod u+x /opt/parallel/parallel.perl
ENV PATH=$PATH:/opt/parallel/

# For dumping the logs
RUN mkdir -p /root/logs
WORKDIR /root/logs

# Execute command
CMD ["/opt/parallel/parallel.perl"]