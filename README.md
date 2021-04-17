# Build opencv, locally

This is my config to build opencv, now it's version controlled!

Building opencv is fairly easy. Here is what it looks like:

1. clone `opencv` and `opencv_contrib` from git
2. `mkdir build` and run `cmake` with some args and props from there
3. `cmake` generates everything required for you build tool. (I like `ninja`)
4. build tool handles actual compiling, linking and installing as configured.


I want to do the following:

1. select `opencv` modules to build
2. be able to add / remove (contrib) modules as I grow
3. use compiled opencv from both python (venv) and c++ 


## Build steps

Create python venv and activate it. 
```
# see virtualenvwrapper
mkvirtualenv 3D-reconstruction

# workon 3D-reconstruction
```

Run `./do-cmake.sh` to create build dir and run cmake inside.
Provided arguments will

- configure install path to created venv
- enable non-free algs
- use `ninja` instaed of `make`
- will be continued... see [file itself](do-cmake.sh) for full list.


Then actually build and install.  
```
# cmake inferes build tool from generated config.
cmake --build build
cmake --install build
```

Initiall build will take long. Following builds and reconfigurations will be
iterative and relatively quick.
