# encapsulator

This just takes the latest official Fedora Silverblue OSTree commit, verifies
the Fedora signature, encapsulates it into an OCI archive, signs it with my key,
and then pushes it out to quay.io/jlebon/fedora-silverblue.

That image is then used as the `FROM` for my workstation image.

## Why?

There are no official _and_ signed Fedora Silverblue OCI images right now. This
bridges that gap until then by resigning with a key I trust.
