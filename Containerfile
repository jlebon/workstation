ARG RELEASEVER=42

FROM quay.io/jlebon/fedora-silverblue:${RELEASEVER}
COPY overlay /
RUN <<EOF
set -xeuo pipefail
dnf swap -y noopenh264 openh264
dnf install -y mozilla-openh264 wireguard-tools
dnf remove -y gnome-software gnome-software-rpm-ostree
dnf clean all
EOF
