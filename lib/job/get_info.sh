#!/bin/bash

export PATH=/usr/local/bin:$PATH

dir=`dirname $0`

input=$1

ffmpeg -i "${input}" 2>&1 | ruby ${dir}/get_info.rb
