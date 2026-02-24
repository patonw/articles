#!/usr/bin/env bash

mdformat --wrap no $@
sed -i 's#\.\./assets#https://media.githubusercontent.com/media/patonw/articles/refs/heads/main/aerie/assets#' $@
sed -i 's/\[!note\]/ℹ️ **note**\n>/Ig' $@
sed -i 's/\[!tip\]/💡 **tip**\n>/Ig' $@
sed -i 's/\[!important\]/📢 **important**\n>/Ig' $@
sed -i 's/\[!warning\]/⚠️ **warning**\n>/Ig' $@
sed -i 's/\\\[\^\(.*\)\\\]/[^\1]/Ig' $@
