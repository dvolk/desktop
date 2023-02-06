#!/bin/sh
d=${1#ssh://}
kitty ssh $d &
