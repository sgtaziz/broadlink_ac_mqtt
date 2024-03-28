FROM python:alpine as builder

COPY . /app
WORKDIR /app

RUN apk add --no-cache binutils gcc libstdc++-dev musl-dev libffi-dev
RUN pip install -r requirements.txt
RUN find /usr/local -name '*.so' | xargs strip -s
RUN pip uninstall -y pip
RUN set -ex && \
    cd /usr/local/lib/python*/config-*-x86_64-linux-musl/ && \
    rm -rf *.o *.a
RUN rm -rf /usr/local/lib/python*/ensurepip
RUN rm -rf /usr/local/lib/python*/idlelib
RUN rm -rf /usr/local/lib/python*/distutils/command
RUN rm -rf /usr/local/lib/python*/lib2to3
RUN rm -rf /usr/local/lib/python*/__pycache__/*
RUN find /usr/local/include/python* -not -name pyconfig.h -type f -exec rm {} \;
RUN find /usr/local/bin -not -name 'python*' \( -type f -o -type l \) -exec rm {} \;
RUN rm -rf /usr/local/share/*
RUN apk del binutils gcc libstdc++-dev musl-dev libffi-dev

FROM alpine:latest as final

ENV LANG C.UTF-8
RUN apk add --no-cache libbz2 expat libffi xz-libs sqlite-libs readline ca-certificates
COPY --from=builder /usr/local/ /usr/local/

COPY . /app
WORKDIR /app

CMD ["python3", "monitor.py"]