# openvas-in-the-box

This is a Docker image that comes with Openvas installed and ready to use.
The NVT is downloaded during the build and stored inside the final image.
This way, when the image starts it's ready to start scanning.

## How to start a local container

```
sudo docker run -p 80:80 -p 443:443 --rm -ti -d --name openvas openvas
```

## How to access the web UI

The web UI will be available at:

```
https://127.0.0.1

Username: openvas
Password: openvas
```

## List of software and versions 
- gvm-libs `v11.0.0`
- openvas `v7.0.0`
- ospd `v2.0.0`
- ospd-openvas `v1.0.0`
- gvmd `v9.0.0`
- gvmd-tools `v2.0.0`
- gsa `v9.0.0`
- nmap