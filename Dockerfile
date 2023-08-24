FROM --platform=linux/aarch64 ubuntu:20.04 AS aws_builder
RUN : \
    && apt update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        unzip \
    && apt-get clean \
       # software-properties-common \
    && :

RUN : \
    && curl "https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && ./aws/install --bin-dir /aws-cli-bin \
    && :

FROM quay.io/skopeo/stable:v1.11.1
# Attempt 4
# FROM golang
#
# RUN \
#      : \
#      && go install github.com/sethkor/s3kor@latest \
#      && :

# Attempt 3
# FROM minio/mc
# Attempt 2
# FROM rust
# RUN \
#      : \
#      && cargo install \
#               s3-util \
#      && :

RUN \
    : \
    && dnf install -y \
        gron \
        jq \
    && :

COPY --from=aws_builder /usr/local/aws-cli/ /usr/local/aws-cli/
COPY --from=aws_builder /aws-cli-bin/ /usr/local/bin/
