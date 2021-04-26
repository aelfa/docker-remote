# docker-remote
docker backup / restore for remote and local

## FYI

```
So if you see a broken part plz report it here
           over githube issues
           or on the Discord

   All the Contributors you can see at the end 

```


## Docker run commands

----

## Commands explains

```
APPNAME = App to backup ( sample sonarr )
STORAGE = name of specifi folder ( sample server01 || myplex || what_you_want ) 
PASSWORD = password what you want ( dont miss them || no storing of any password plain )
           ( password will be openssl enc -aes-256-cbc crypted )
		   
Backup  Storage = /mnt/downloads/appbackups/${STORAGE}/${APPNAME}
Restore Storage = /mnt/unionfs/appbackups/${STORAGE}/${APPNAME}

```

----
 
## Backup Docker (no protected backup)
```
$(command -v docker) run --rm \
  -v /opt/appdata:/backup/{APPNAME} \
  -v /mnt:/mnt \
  ghcr.io/doob187/docker-remote:latest backup {APPNAME} {STORAGE} 
```

## Backup Docker (protected backup)
```
$(command -v docker) run --rm \
  -v /opt/appdata:/backup/{APPNAME} \
  -v /mnt:/mnt \
  ghcr.io/doob187/docker-remote:latest backup {APPNAME} {STORAGE} {PASSWORD}
```

----

## Restore Docker (no protected backup)
```
$(command -v docker) run --rm \
  -v /opt/appdata:/restore \
  -v /mnt:/mnt \
  ghcr.io/doob187/docker-remote:latest restore {APPNAME} {STORAGE} 
```

## Restore Docker (protected backup)
```
$(command -v docker) run --rm \
  -v /opt/appdata:/restore \
  -v /mnt:/mnt \
  ghcr.io/doob187/docker-remote:latest restore {APPNAME} {STORAGE}  {PASSWORD}
```

----

## check Docker (no protected backup)
```
$(command -v docker) run --rm \
  -v /mnt:/mnt \
  ghcr.io/doob187/docker-remote:latest check {APPNAME} {STORAGE} 
```

## check Docker (protected backup)
```
$(command -v docker) run --rm \
  -v /mnt:/mnt \
  ghcr.io/doob187/docker-remote:latest check {APPNAME} {STORAGE} {PASSWORD}
```

----

## show usage menu
```
$(command -v docker) run --rm \
  ghcr.io/doob187/docker-remote:latest usage
```

----

## Contributors ✨

Thanks goes to these wonderful people ([emoji key](https://allcontributors.org/docs/en/emoji-key)):

<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- prettier-ignore-start -->
<!-- markdownlint-disable -->
<table>
  <tr>
    <td align="center"><a href="https://github.com/mrfret"><img src="https://avatars.githubusercontent.com/u/72273384?v=4?s=100" width="100px;" alt=""/><br /><sub><b>mrfret</b></sub></a><br /><a href="#infra-mrfret" title="Infrastructure (Hosting, Build-Tools, etc)">🚇</a> <a href="https://github.com/doob187/docker-remote/commits?author=mrfret" title="Tests">⚠️</a> <a href="https://github.com/doob187/docker-remote/commits?author=mrfret" title="Code">💻</a> <a href="#content-mrfret" title="Content">🖋</a></td>
    <td align="center"><a href="https://github.com/doob187"><img src="https://avatars.githubusercontent.com/u/60312740?v=4?s=100" width="100px;" alt=""/><br /><sub><b>doob187</b></sub></a><br /><a href="#infra-doob187" title="Infrastructure (Hosting, Build-Tools, etc)">🚇</a> <a href="https://github.com/doob187/docker-remote/commits?author=doob187" title="Tests">⚠️</a> <a href="https://github.com/doob187/docker-remote/commits?author=doob187" title="Code">💻</a> <a href="#content-doob187" title="Content">🖋</a></td>
  </tr>
</table>

<!-- markdownlint-restore -->
<!-- prettier-ignore-end -->

----

## LICENSE
```

##################################
# Copyright (c) 2021,  : MrDoob  #
# Docker owner         : doob187 #
# Docker Maintainer    : doob187 #
# Code owner           : doob187 #
#     All rights reserved        #
##################################
# THIS DOCKER IS UNDER LICENSE   #
# CUSTOMIZING IS ALLOWED         #
# REBRANDING IS NOT ALLOWED      #
# CODE MIRRORING IS ALLOWED      #
##################################
 
```

