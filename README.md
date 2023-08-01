
Template code to include seastar in your c++ project.

I selected the minimun working peices of code from the `redpanda-data/redpanda` project, so you can use it as a starting point.


# Prerequisite

```
# use lld as linker

sudo pacman -Sy lld


# these are dependencies of seastar

sudo pacman -Sy lksctp-tools
sudo pacman -Sy yaml-cpp
sudo pacman -Sy ragel
sudo pacman -Sy valgrind

```


# Build and run

```
mkdir build && cd build

cmake ..
make

sudo ./repanda

=> print cpu cores number. in my env, it is '8'

```
