FROM ubuntu:precise
MAINTAINER Stig Sandbeck Mathisen <ssm@fnord.no>

RUN [ "apt-get", "update" ]
RUN [ "apt-get", "-y", "install", "libmojolicious-perl" ]
RUN [ "apt-get", "-y", "install", "libmonitoring-livestatus-perl" ]
RUN [ "apt-get", "-y", "install", "libcontextual-return-perl", "libtimedate-perl", "liblist-moreutils-perl", "libquantum-superpositions-perl", "libtest-class-perl", "libtime-duration-perl", "liburi-perl" ]

# Method::Signatures does not exist on precise
# - Method::Signatures deps, to install
RUN [ "apt-get", "-y", "install", "make", "cpanminus" ]
# - Method::Signatures deps, to run

RUN [ "apt-get", "-y", "install", "libany-moose-perl", "libdata-alias-perl", "libdevel-declare-perl", "libmouse-perl", "libppi-perl", "libsub-name-perl" ]
RUN [ "apt-get", "-y", "install", "libtest-harness-perl" ]
RUN [ "apt-get", "-y", "install", "libtest-warn-perl" ]
RUN [ "cpanm", "-v", "Method::Signatures" ]

COPY . /srv/mynch

EXPOSE 3000
CMD [ "morbo", "/srv/mynch/script/mynch" ]
