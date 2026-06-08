ARG RELEASEVER=44

FROM quay.io/jlebon/fedora-silverblue:${RELEASEVER} AS builder
ARG RELEASEVER
COPY overlay /
# XXX: can't use heredoc; the GitHub Actions buildah is too old
RUN \
set -xeuo pipefail; \
# there is no dnf in the classic silverblue yet, so use rpm-ostree
# but also, rpm-ostree enforces base version locking
rpm-ostree override remove gnome-software gnome-software-rpm-ostree; \
# but do install dnf because it's helpful for the transient case
rpm-ostree install dnf5; \
# drop built-in firefox; we've moved to flatpak
rpm-ostree override remove firefox firefox-langpacks; \
rpm-ostree install fzf inotify-tools wl-clipboard; \
curl -fsSLo /etc/yum.repos.d/scottames-ghostty.repo \
  "https://copr.fedorainfracloud.org/coprs/scottames/ghostty/repo/fedora-${RELEASEVER}/scottames-ghostty-fedora-${RELEASEVER}.repo"; \
rpm-ostree install ghostty; \
rm -rf /var; \
mkdir /var

FROM quay.io/coreos/chunkah:dev AS chunkah
ARG CHUNKAH_CONFIG_STR
RUN --mount=from=builder,src=/,target=/chunkah,ro \
    --mount=type=bind,target=/run/src,rw \
        chunkah build --prune /sysroot/ --max-layers 256 \
          --label ostree.commit- --label ostree.final-diffid- \
          --output oci:/run/src/out

FROM oci:out
