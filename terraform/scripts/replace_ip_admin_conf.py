#!/usr/bin/env python
# -*- coding: utf-8 -*-
import re
import sys

public_ip = sys.argv[1]
read_file = open("admin.conf", "r")
read_file = read_file.readlines()
write_file = open("config", "w")
for i in read_file:
    if re.findall(":\/\/(\d+.\d+.\d+.\d+)", i):
        replace_ip = re.sub("\d+.\d+.\d+.\d+", public_ip, i)
        write_file.write(replace_ip)
    else:
        write_file.write(i)
