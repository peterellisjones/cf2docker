# CF2DOCKER

cf2docker stages and runs Cloud Foundry apps in Docker. It uses a multi-stage Dockerfile to build a minimal final image based on [cflinuxfs2](https://github.com/cloudfoundry/cflinuxfs2/tree/master/cflinuxfs2) that just contains your app and the [CF launcher](https://github.com/cloudfoundry/buildpackapplifecycle).

It currently stages apps using the latest go, nodejs and ruby buildpacks.

```bash
# Clone this repo
git clone https://github.com/peterellisjones/cf2docker
cd cf2docker

# Clone an example app
git clone https://github.com/cloudfoundry-samples/cf-sample-app-nodejs.git

# Stage your app by building this Dockerfile
docker build --build-arg APP_PATH=cf-sample-app-nodejs --tag my-cf-app .

# Run your CF app in docker!
docker run -d -p 8080:8080 my-cf-app:latest
curl localhost:8080
```

Check out the [Dockerfile](https://github.com/peterellisjones/cf2docker/blob/master/Dockerfile) to see how it works
