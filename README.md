# voipmonitor-docker
Build Docker images for voipmonitor network packet sniffer

## Local build

    docker build -f sniffer.Dockerfile -t voipmonitor-sniffer .
    docker build --platform=linux/amd64 -f gui.Dockerfile -t voipmonitor-gui .
