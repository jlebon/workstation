# workstation

[![quay.io repository](https://img.shields.io/badge/updated-2026--02--21-green)](https://quay.io/repository/jlebon/workstation)

This is my bootable container for my workstations based on Fedora Silverblue.

## Usage

### Set up signature verification

```
cd signing/
# WARNING: this overwrites any custom policy.json
sudo cp policy-strict-allow-others.json /etc/containers/policy.json
sudo cp quay.io-jlebon.yaml /etc/containers/registries.d/
sudo mkdir -p /etc/pki/containers/
sudo cp quay.io-jlebon.pub /etc/pki/containers/
```

### Rebase

```
sudo bootc switch --enforce-container-sigpolicy quay.io/jlebon/workstation
```
