#!/bin/bash
function genpass()
{
  pwgen -syBv -1 32 |pbcopy ; echo -e 'Password copied..'
}

genpass
