#!/bin/bash
# Python 3 virtual environment management

mkvenv()
{
    [ -z "$1" ] && echo "Specify a venv name." && return
    python3 -m venv $HOME/.venvs/$1
}

venvs()
{
    ls $HOME/.venvs
}

rmvenv()
{
    [ -z "$1" ] && echo "Specify a venv name." && return
    rm -rI $HOME/.venvs/$1
}

workon()
{
    [ -z "$1" ] && echo "Specify a venv name." && return
    source $HOME/.venvs/$1/bin/activate
}
