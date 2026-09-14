# codeg — collaborative multi-agent AI coding workspace (https://github.com/xintaofei/codeg)
#
# Upstream publishes multi-arch images, so this is a thin pin rather than a build.
# 0.30.7 index digest: sha256:8700beeaf1b16a9099b280fb76e297f3664fbe767aab0a1043c1d8d3084e3a3a
ARG CODEG_VERSION=0.30.7
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
