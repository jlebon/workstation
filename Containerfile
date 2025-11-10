ARG RELEASEVER=43

FROM quay.io/jlebon/fedora-silverblue:${RELEASEVER} AS builder
COPY overlay /
RUN <<EOF
set -xeuo pipefail
# there is no dnf in the classic silverblue yet, so use rpm-opstree
# but also, rpm-ostree enforces base version locking
rpm-ostree override remove gnome-software gnome-software-rpm-ostree
# XXX: should be able to drop wireguard-tools once https://pagure.io/workstation-ostree-config/pull-request/705 merges
rpm-ostree install wireguard-tools fzf inotify-tools wl-clipboard
rm -rf /var && mkdir /var
EOF

# FROM builder AS chunker
# COPY --from=builder / /target-rootfs
# RUN mkdir -p /var/tmp
# # always nuke the output OCI archive so that rpm-ostree
# # doesn't try to use it as a baseline
# RUN --mount=type=bind,target=/run/src,rw \
#   rm -f /run/src/out.ociarchive
# RUN --mount=type=bind,target=/run/src,rw \
#       rpm-ostree compose build-chunked-oci --max-layers 64 \
#         --bootc --format-version=2 --rootfs /target-rootfs \
#         --output oci-archive:/run/src/out.ociarchive

# FROM oci-archive:./out.ociarchive
# RUN --mount=type=bind,from=chunker,target=/var/tmp \
#     --mount=type=bind,target=/run/src,rw \
#       rm /run/src/out.ociarchive
