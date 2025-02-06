FROM greycubesgav/slackware-docker-base:latest AS builder

# Install the dependancies binaries for the build
COPY src /root/src/

# Setup the build environment
ENV TAG='_GG'

# Install package requirements
RUN echo 'y' | slackpkg install lzip

# Build the base libraries
# guile
WORKDIR /root/src/guile
RUN BUILD=1${TAG} ./guile.SlackBuild
RUN installpkg /tmp/guile-*-x86_64*${TAG}.txz

# gc
WORKDIR /root/src/gc
RUN BUILD=1${TAG} ./gc.SlackBuild
RUN installpkg /tmp/gc-*-x86_64*${TAG}.txz

# libffi
WORKDIR /root/src/libffi
RUN BUILD=1${TAG} ./libffi.SlackBuild
RUN installpkg /tmp/libffi-*-x86_64*${TAG}.txz

# libunistring
WORKDIR /root/src/libunistring
RUN BUILD=1${TAG} ./libunistring.SlackBuild
RUN installpkg /tmp/libunistring-*-x86_64*${TAG}.txz

# Build the main package
WORKDIR /root/src/make
RUN BUILD=3${TAG} ./make.SlackBuild
RUN installpkg /tmp/make-*-x86_64*${TAG}.txz
RUN make -v

#ENTRYPOINT [ "bash" ]

# Create a clean image with only the artifact
FROM scratch AS artifact
COPY --from=builder /tmp/*.txz .