# storage for your k8s stateful apps
Play with persistent volume, persistent-volume claim and storage class

## prerequisites

enable docker for mac and k8s (use for example minishift)

```bash
brew reinstall cask minishift
sudo minishift setup
minishift start

minishift oc-env
eval $(minishift oc-env)

oc login -u system:admin
```

open https://192.168.64.19:8443/console
login with:
* username: `developer`
* password: `123`

## cleanup

```bash
minishift stop ; minishift delete -f
```

## resources

* [YouTube: Kubernetes Webinar Series - Dealing with Storage and Persistence](https://youtu.be/n06kKYS6LZE?t=1089)
* https://kubernetes.io/docs/concepts/storage/storage-classes/
