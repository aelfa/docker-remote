# docker-remote
docker backup / restore for remote and local

## Docker run commands

---

## Backup Docker (no protected backup)
```
$(command -v docker) run --rm \
  -v /opt/appdata:/backup/{APPNAME} \
  -v /mnt:/mnt \
  ghcr.io/doob187/docker-remote:latest backup {APPNAME}
```

## Backup Docker (protected backup)
```
$(command -v docker) run --rm \
  -v /opt/appdata:/backup/{APPNAME} \
  -v /mnt:/mnt \
  ghcr.io/doob187/docker-remote:latest backup {APPNAME} {PASSWORD}
```

---

## Restore Docker (no protected backup)
```
$(command -v docker) run --rm \
  -v /opt/appdata:/restore \
  -v /mnt:/mnt \
  ghcr.io/doob187/docker-remote:latest restore {APPNAME}
```

## Restore Docker (protected backup)
```
$(command -v docker) run --rm \
  -v /opt/appdata:/restore \
  -v /mnt:/mnt \
  ghcr.io/doob187/docker-remote:latest restore {APPNAME} {PASSWORD}
```

---

## check Docker (no protected backup)
```
$(command -v docker) run --rm \
  -v /mnt:/mnt \
  ghcr.io/doob187/docker-remote:latest check {APPNAME}
```

## check Docker (protected backup)
```
$(command -v docker) run --rm \
  -v /mnt:/mnt \
  ghcr.io/doob187/docker-remote:latest check {APPNAME} {PASSWORD}
```


---
## show usage menu
```
$(command -v docker) run --rm \
  ghcr.io/doob187/docker-remote:latest usage
```

