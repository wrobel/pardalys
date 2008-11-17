#!/bin/bash

ls | awk '/^function\..*\.html$/ { gsub(/-/,"_"); print(substr($0,10,length($0)-14)); }' > php_completions