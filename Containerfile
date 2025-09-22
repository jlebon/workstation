ARG RELEASEVER=42

FROM quay.io/jlebon/fedora-silverblue:${RELEASEVER}
COPY overlay /
RUN <<EOF
set -xeuo pipefail
# there is no dnf in the classic silverblue yet, so use rpm-opstree
rpm-ostree override remove noopenh264 \
  --install openh264 --install mozilla-openh264
rpm-ostree override remove gnome-software gnome-software-rpm-ostree
rpm-ostree install wireguard-tools
rm -rf /var && mkdir /var
EOF
