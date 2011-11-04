#!/bin/bash

export PATH=/usr/local/bin:$PATH

job_dir=`dirname $0`

input_file=$1
output_path=$2
aspect=$3
aspect_only=$4
file_prefix=$5


ffmpeg_cmd="ffmpeg -er 4 -y -i '${input_file}' -f mp4 -s 640x480 -aspect ${aspect_only} -vcodec libx264 -b 600k -r 29.97 -acodec libfaac -ar 44100 -ab 128k -flags +loop -cmp +chroma -partitions +parti8x8+parti4x4+partp8x8+partp4x4 -me_method hex -subq 6 -me_range 16 -g 250 -keyint_min 25 -sc_threshold 40 -i_qfactor 0.71 -b_strategy 1 -qcomp 0.6 -qmin 10 -qmax 51 -qdiff 4 -directpred 1 -flags2 fastpskip -maxrate 1000k -coder 0 -level 30 -async 2 -threads 2 ${output_path}/${file_prefix}.mp4"

sh -c "${ffmpeg_cmd}"
