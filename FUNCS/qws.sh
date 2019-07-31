#!/bin/bash

function qws ()
{
  CMD="aws $@"
  echo $CMD
  eval $CMD |jq
}
