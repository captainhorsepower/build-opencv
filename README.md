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

```sh
# see virtualenvwrapper
mkvirtualenv 3D-reconstruction

# workon 3D-reconstruction
```

Run `./do-cmake.sh` to create build dir and run cmake inside.
Provided arguments will

- configure install path to created venv
- enable non-free algs
- use `ninja` instead of `make`
- will be continued... see [file itself](do-cmake.sh) for full list.


Then actually build and install.  

```sh
# cmake inferes build tool from generated config.
cmake --build build
cmake --install build
```

Initiall build will take long. Following builds and reconfigurations will be
iterative and relatively quick.

## Access opencv

Within configured vevn `import cv2` is present out of the box.

Other python programms need to modify `sys.path`. 
There must be a better way, but for quick and dirty stuff you can use:

```py
import sys
sys.path.append('/<your install location>/lib/python2.7/site-packages')
sys.path.append('/<your install location>/lib/python3.9/site-packages')


import cv2
print(cv2.__version__)
```

From cpp, when using cmake, export appropriate `OpenCV_DIR`. 
See opencv docs for the rest.


## Add and remove modules from build.

Now I explicitly specify required modules with `-D BUILD_LIST=model1,module2,...`. It automatically accounts for transitive dependencies.

There is a catch: presense or absense of a module 'A' may change build config
for module 'B' (optional dependency). Then the whole thing won't compile.

Workaround: from `build` forlder remove `lib/<module_A.*>`. Ninja will recompile missing fiels from scratch. 

Same thing for python executable. It can 'ignore' all the updates.
Then just delete it, recompile and reinstall. Should do the trick.

## Discovering modules

Do find out what modules are available to you and what they do,
inspect [`opencv/modules`](opencv/modules) and [`opencv_contrib/modules`]
(opencv_contrib/modules). Within each module navigate to `include` folder, 
which contains reasonable description in comments in `.hpp` files.

Python API is generated from this `include` files with `CV_WRAP` and `CV_EXPORTS_W` macrosses. 
(but some stuff like `cv2.xfeatures2d.SURF_create` I just can't understand)

---

Discorvering and using python API is a nightmare :)))

You need to find appropriate module, then cpp function in it. 
Then find how it maps to python (not always obviously and directly).
And in most cases still google how to actually use it, as 
docs and python help are empty...

Maybe I just need to build docs?


## Links

- how [python mappings are generated](https://docs.opencv.org/master/da/d49/tutorial_py_bindings_basics.html)

- opencv build [config options](https://docs.opencv.org/master/db/d05/tutorial_config_reference.html)

- trying to 'install' cumstom opencv to venvs:
    - https://stackoverflow.com/questions/55600132/installing-local-packages-with-python-virtualenv-system-site-packages
    - https://docs.python.org/3/library/site.html

- might be useful one day:
    - https://gist.github.com/Unbinilium/13495c2fa236cc31c1b2bfb929c7e0db
    
    - [meson](https://mesonbuild.com/Wrap-dependency-system-manual.html) and [cmake](https://cmake.org/overview/)
    
    - https://carlosvin.github.io/posts/choosing-modern-cpp-stack/en/