#!/bin/bash
docker build docker/ora2pg-otrs --no-cache -t samueldc/ora2pg-otrs:1.0 \
&& docker push samueldc/ora2pg-otrs:1.0