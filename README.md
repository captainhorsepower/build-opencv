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


## Python bindings for custom modules

Ну держись...

1. cmake не переваривает .cc файлы без дополнительный конфигов (linker language бла бла).
   Так что сиди ровно и использую .hpp .cpp
2. Сгенерированные биндинги ожидают namespace, используй (или переписывай генератора)
3. ауф

Значит проще все было внедрить свой модуль в opencv. Для этого:

1. обновляю `CMakeLists.txt` модуля в
   ```cmake
    set(the_description "Polar Rectification Impl with python bindings!")
    // polarrect - имя модуля
    // остальное -- зависимости.
    ocv_define_module(polarrect opencv_core opencv_imgproc opencv_calib3d opencv_xfeatures2d  WRAP python)
   ```
2. Обновляю структуру модуля: хедеры в `include/opencv2`, исходники в `src` main  в `samples`.
3. Все хедеры должны быть `.hpp` (иначе биндинги не генерит), сорсы `.cpp` (на `.cc` линкер ругается)
4. Чтобы не расписывать все приватные детали имплементации класса в хедере
   поможет `pImpl` паттерн, либо наследование. Для вторго в родителе нужно определить виртуальный деструктор, но с имплементацией.
5. Вообще ООП в с++ штука специфичная, разбирайтейсь сами)))
6. И при вызове cmake, нужно указать на модули (`do-cmake.sh`): 
   ```sh
    -D OPENCV_EXTRA_MODULES_PATH='../opencv_contrib/modules;../custom-modules' \
    -D BUILD_LIST=python3,videoio,highgui,calib3d,xfeatures2d,ximgproc,polarrect\
    ```

Для генерации биндингов:

1. standalone func: `CV_EXPORTS_W void func(....);`
2. Класс: `CV_EXPORTS_W class ABC: ... CV_WRAP void instance_method(); CV_EXPORTS_W static void static_method(); ...`
3. Генератор биндингов `gen2.py` всегда ждёт хоть один namespace. Вложенные namespaces в стиле c++17 не поддерживаются (никаких `cv::polarrect { ... }`)
4. в итоге в питоне биндинги такие:
   1. Для просто функций: `cv.namespace.func_name`
   2. Для классов: `cv.namespace_ClassName`
   3. статические методы (2 варианта)
      - `cv.namespace.ClassName_method`
      - `cv.namespace_ClassName.method`

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