#!/bin/bash

curl https://severstal-avia.ru/online-board/departure/ > /home/vtext/app/script/test/parsing/dep_$(date "+%Y%m%d_%H-%M.html")

curl https://severstal-avia.ru/online-board/arrival/ > /home/vtext/app/script/test/parsing/arr_$(date "+%Y%m%d_%H-%M.html")
