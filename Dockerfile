ARG VERSION=2412

FROM opencfd/openfoam-default:$VERSION
USER 0
RUN apt-get update \
    && apt-get install -y gmsh \
    && rm -rf /var/lib/apt/lists/*
USER $FOAM_USER

