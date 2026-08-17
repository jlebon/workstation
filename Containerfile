ARG RELEASEVER=44

FROM quay.io/jlebon/fedora-silverblue:${RELEASEVER} AS builder
ARG RELEASEVER
COPY overlay /
# XXX: can't use heredoc; the GitHub Actions buildah is too old
RUN \
set -xeuo pipefail; \
# fedora-repos >= 45 ships the Fedora repo files under
# /usr/share/dnf5/repos.d/ and leaves /etc/yum.repos.d/ for third-party
# repos only; rpm-ostree reads from /etc/yum.repos.d/, so merge the Fedora
# repos there. No-op on older releases where /usr/share/dnf5/repos.d/ doesn't exist.
[ -d /usr/share/dnf5/repos.d ] && cp -a /usr/share/dnf5/repos.d/. /etc/yum.repos.d/ || true; \
# there is no dnf in the classic silverblue yet, so use rpm-ostree
# but also, rpm-ostree enforces base version locking
rpm-ostree override remove gnome-software gnome-software-rpm-ostree; \
# but do install dnf because it's helpful for the transient case
rpm-ostree install dnf5; \
# drop built-in firefox; we've moved to flatpak
rpm-ostree override remove firefox firefox-langpacks; \
rpm-ostree install fzf inotify-tools crun-krun; \
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
