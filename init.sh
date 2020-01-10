  
#!/bin/bash

set -eux

apt-get update -y
apt-get -y install build-essential ruby-dev
gem install md2review
npm i 
# npx textlint review-starter/*.md
for f in review-starter/chap*.md; do basename ${f} | sed 's/\.[^\.]*$//' | xargs -i sh -c 'md2review review-starter/{}.md > review-starter/{}.re'; done
echo 'Finish kawamoto!'
