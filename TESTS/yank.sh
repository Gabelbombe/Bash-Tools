#!/bin/bash

## Examples of the readline functions `yank-last-arg` and `yank-nth-arg`.
## Without specifying n, nth-arg will default to  the first argument of
## the prior command.

# Table of commands:
#
#     !^      first argument
#     !$      last argument
#     !*      all arguments
#     !:2     second argument
#
#     !:2-3   second to third arguments
#     !:2-$   second to last arguments
#     !:2*    second to last arguments
#     !:2-    second to next to last arguments
#     !:0     command


echo a b c d e                #stage history for manipulation
  # a b c d e


echo !^                       #replay via first word boundary item
  # echo a
  # a


## Manipulate by place *(via yank-nth-arg)
echo !:1                      #replay via declared (1st) word boundary
  # echo a
  # a

echo !:3                      #replay via declared (3th) word boundary
  # echo c
  # c


## Manipulate last word *(via yank-last-arg)
echo !$                        #replay via last word boundary item
  # echo e
  # e


## Fetching args from commands via history
# echo a b c d e f g
#   # a b c d e f g
#
# echo build/libs/jenkins-utils-all-0.1.jar
#   # build/libs/jenkins-utils-all-0.1.jar
#
# history |tail -5
#   # 601  echo build/libs/jenkins-utils-all-0.1.jar
#   # 602  history | tail -10
#   # 603  echo a b c d e f g
#   # 604  echo build/libs/jenkins-utils-all-0.1.jar
#   # 605  history | tail -5
# echo !-3:4
#   # echo d
#   # d
#
# echo !604:1
#   # echo build/libs/jenkins-utils-all-0.1.jar
#   # build/libs/jenkins-utils-all-0.1.jar
