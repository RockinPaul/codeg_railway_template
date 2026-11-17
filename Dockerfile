# codeg — collaborative multi-agent AI coding workspace (https://github.com/xintaofei/codeg)
#
# Upstream publishes multi-arch images, so this is a thin pin rather than a build.
# 0.45.0 index digest: sha256:3afd5a478ef259f7b5bbb491474fcbcf3fbcb615d94ad0a7eb2b26e790a87e32
ARG CODEG_VERSION=0.45.0
FROM xintaofei/codeg:${CODEG_VERSION}

# Baked rather than set as service variables: template generation turns a literal
# default into a REQUIRED composer field with no value, which would ask the deployer
# to type a port number. Only CODEG_TOKEN stays a variable, because ${{secret()}}
# references survive generation intact.
#
# The upstream image already sets CODEG_DATA_DIR=/data and CODEG_HOST=0.0.0.0;
# both are restated here so this file is the single place to read the runtime shape.
ENV CODEG_PORT=8080 \
    CODEG_HOST=0.0.0.0 \
    CODEG_DATA_DIR=/data

EXPOSE 8080
