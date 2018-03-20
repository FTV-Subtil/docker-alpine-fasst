FROM alpine:3.6 AS fasst_builder

WORKDIR /app
ADD . .

RUN apk update && \
    apk add python py-numpy cmake qt-dev libsndfile-dev g++ make ca-certificates wget && \
    update-ca-certificates

RUN wget http://bitbucket.org/eigen/eigen/get/3.2.0.tar.bz2 && \
    tar xjf 3.2.0.tar.bz2 && \
    cd eigen-eigen-* && mkdir build && cd build && cmake .. && make install

RUN wget http://fasst.gforge.inria.fr/files/fasst-2.1.0.tar.gz && \
    tar xvf fasst-2.1.0.tar.gz && \
    cd fasst-2.1.0 && \
    sed -i 's/-Wall -Wextra -Werror/-Wall -Wextra/' CMakeLists.txt && \
    mkdir build && \
    cd build && \
    cmake .. && \
    make

FROM alpine:3.6

WORKDIR /app

RUN apk update && \
    apk add python py-numpy qt libsndfile g++

COPY --from=fasst_builder /app/fasst-2.1.0/build/bin /usr/bin
COPY --from=fasst_builder /app/fasst-2.1.0/build/scripts/python/fasst.py /app/fasst.py

ENV PYTHONPATH /app
