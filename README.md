# Kubernetes Local Development Environment

There are two machines defined in the `Vagrantfile`:

- **k8s**: after provisioning this machine, you may visit the Kubernetes management
  dashboard at the following URL: http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/#!/job?namespace=default
- **artifacts**: after running `vagrant up` and provisioning completes, you are
  able to push a Docker image to `docker.local.quantumframework.org`

## Preparing your system

### Cloning the repository

### Setting up your Docker registry

The development infrastructure deploys a Docker registry, but
`docker push` will refuse operation if the URL is not whitelisted
as an `insecure-registry`.

If you are not going to push Docker images to the local registry
from the host machine, you may omit this step.

For more information on this subject, refer to
https://docs.docker.com/registry/insecure/.

#### Docker for Desktop

Open Docker for Desktop and click on the Daemon tab. Add
`docker.local.quantumframework.org` to the list under
"Insecure registries". Next, click "Apply & Restart"
and wait for the Docker daemon to come up again.
