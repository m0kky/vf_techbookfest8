#!/bin/bash
[ ! -z $REVIEW_CONFIG_FILE ] || REVIEW_CONFIG_FILE=config.yml

# コマンド手打ちで作業したい時は以下の通り /book に pwd がマウントされます
# docker run -i -t -v $(pwd):/book vvakame/review:4.0 /bin/bash

docker run -t --rm -v $(pwd):/book kauplan/review2.5 /bin/bash -ci "cd /book && chmod +x ./init.sh && ./init.sh && REVIEW_CONFIG_FILE=$REVIEW_CONFIG_FILE cd ./review-starter; rake pdf"
