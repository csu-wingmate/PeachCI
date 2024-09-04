#!/usr/bin/python3

import sys
import time
import os

edge_cnt=0
out_file=sys.argv[2]

if os.path.exists(out_file):
    out_file=out_file+"_dup"

with open(out_file, "w") as f:
    f.close()

st = int(time.time())
while True:
    with open(sys.argv[1], 'rb') as f:
        cur=int.from_bytes(f.read(4), "little")
        f.close()
    if edge_cnt<cur:
        edge_cnt=cur
        with open(out_file, "a") as f:
            f.write("{}, {}\n".format(int(time.time()) - st, edge_cnt))
            f.close()
            print("edge_cnt: {}".format(edge_cnt))
    time.sleep(1)
