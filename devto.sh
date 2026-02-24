#!/usr/bin/env bash

mdformat --wrap no $@
sed -i 's#\.\./assets#https://media.githubusercontent.com/media/patonw/articles/refs/heads/main/aerie/assets#' $@
sed -i 's/\[!note\]/ℹ️ **note**\n>/' $@
sed -i 's/\[!tip\]/💡 **tip**\n>/' $@
