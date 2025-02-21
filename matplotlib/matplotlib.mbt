typealias PyModule = @python.PyModule
typealias PyString = @python.PyString
// typealias PyInteger = @python.PyInteger
typealias PyTuple = @python.PyTuple
typealias PyDict = @python.PyDict
typealias PyList = @python.PyList
typealias PyFunc = @python.PyFunc

type! MatplotlibError {
  LoadMatplotlibError
  LoadPyPlotError
  LoadColorMapError
  LoadPylabError
  LoadFuncError(String)
  CallFuncError(String)
} derive(Show)

pub(all) enum Color {
  Red; Green; Blue; Yellow; Cyan; Magenta; Black; White;
  CustomHex(UInt); CustomColorName(String)
} derive(Show)

pub impl Show for Color with to_string(self) {
  match self {
    Red => "red"
    Green => "green"
    Blue => "blue"
    Yellow => "yellow"
    Cyan => "cyan"
    Magenta => "magenta"
    Black => "black"
    White => "white"
    // Custom(c) => (c & 0xFFFFFF).to_string(radix=16)
    CustomHex(h) => "#" + (h & 0xFFFFFF).to_string()
    CustomColorName(s) => s
  }
}

pub struct Matplotlib {
  // priv matplotlib: PyModule 
  priv pyplot: PyModule
  // priv color_map: PyModule
  priv pylab: PyModule
  priv funcs: Map[String, PyFunc]
}

pub fn new() -> Matplotlib!Error {
  let matplotlib = @python.pyimport("matplotlib")

  // @cpython.py_object_call_method(
  //   matplotlib.get_obj(), "use", "s"
  // )

  let pyplot = @python.pyimport("matplotlib.pyplot")
  let color_map = @python.pyimport("matplotlib.cm")
  let pylab = @python.pyimport("pylab")

  let _ = match matplotlib {
    Some(m) => m
    None => raise LoadMatplotlibError
  }

  let pyplot = match pyplot {
    Some(m) => m
    None => raise LoadPyPlotError
  }

  let _ = match color_map {
    Some(m) => m
    None => raise LoadColorMapError
  }

  let pylab = match pylab {
    Some(m) => m
    None => raise LoadPylabError
  }

  let funcs: Map[String, PyFunc] = Map::new()

  Matplotlib::{
    // matplotlib,
    pyplot,
    // color_map,
    pylab,
    funcs
  }
}

fn pyplot_get_func(fname: String) -> PyFunc!MatplotlibError {
  let lib = singleton()
  match lib.funcs.get(fname) {
    Some(f) => return f
    None =>()
  }
  let f = match lib.pyplot.get_func(fname) {
    Some(f) => f
    None => raise LoadFuncError("Didn't find function : \{fname} in matplotlib.pyplot")
  }
  lib.funcs.set(fname, f)
  f
}

fn pylab_get_func(fname: String) -> PyFunc!MatplotlibError {
  let lib = singleton()
  match lib.funcs.get(fname) {
    Some(f) => return f
    None =>()
  }
  let f = match lib.pylab.get_func(fname) {
    Some(f) => f
    None => raise LoadFuncError("Didn't find function : \{fname} in pylab")
  }
  lib.funcs.set(fname, f)
  f
}

let singleton : () -> Matplotlib = get_lib()

fn get_lib() -> () -> Matplotlib {
  @python.init_py()
 
  let mlib = match new?() {
    Ok(mlib) => mlib
    Err(e) => {
      println(e)
      panic()
    }
  }

  fn () {mlib}
}

///| Matplotlib.pyplot.plot
pub fn plot(
  xs: Array[Double],
  ys: Array[Double],
  color~: Color = Color::Blue,
  keywords~: Map[String, String] = Map::new()
) -> Unit!MatplotlibError {
  guard xs.length() == ys.length() else {
    raise CallFuncError("plot require same list length")
  }

  guard xs.length() > 0 else {
    raise CallFuncError("plot require non-empty data list")
  }

  let func = pyplot_get_func!("plot")

  let kwargs = PyDict::new()
  keywords.each(fn (key, val) { kwargs.set(key, val) })

  kwargs.set("color", color.to_string())

  let xs = PyList::from(xs)
  let ys = PyList::from(ys)

  let plot_args = PyTuple::from((xs, ys))
  let _ = func.invoke(plot_args, kwargs~)

  plot_args.drop()
}

///| Matplotlib.pyplot.scatter
pub fn scatter(
  xs: Array[Double],
  ys: Array[Double],
  scale~: Double = 1.0,
  color~: Color = Color::Blue,
  keywords~: Map[String, String] = Map::new()
) -> Unit!MatplotlibError {

  guard xs.length() == ys.length() else {
    raise CallFuncError("plot require same list length")
  }

  guard xs.length() > 0 else {
    raise CallFuncError("scatter require non-empty data list")
  }

  let func = pyplot_get_func!("scatter")
  let kwargs = PyDict::new()
  keywords.each(fn (key, val) { kwargs.set(key, val) })

  kwargs.set("s", scale)
  kwargs.set("color", color.to_string())

  let xs = PyList::from(xs)
  let ys = PyList::from(ys)

  let plot_args = PyTuple::from((xs, ys))
  let _ = func.invoke(plot_args, kwargs~)
  plot_args.drop()
  kwargs.drop()
}

///| Matplotlib.pyplot.bar
pub fn bar(
  xs: Array[String],
  heigh: Array[Double],
  color~ : Color = Color::Blue,
  keywords~: Map[String, String] = Map::new()
) -> Unit!MatplotlibError {
  guard xs.length() == heigh.length() else {
    raise CallFuncError("plot require same list length")
  }

  guard xs.length() > 0 else {
    raise CallFuncError("bar require non-empty data list")
  }

  let func = pyplot_get_func!("bar")
  let kwargs = PyDict::new()
  keywords.each(fn (key, val) { kwargs.set(key, val) })

  kwargs.set("color", color.to_string())

  let xs = PyList::from(xs)
  let heigh = PyList::from(heigh)

  let plot_args = PyTuple::from((xs, heigh))
  let _ = func.invoke(plot_args, kwargs~)
  plot_args.drop()
  kwargs.drop()
}

///| Matplotlib.pyplot.pie
pub fn pie(
  sizes: Array[Double],
  labels~: Array[String] = Array::new(),
  keywords~: Map[String, String] = Map::new()
) -> Unit!MatplotlibError {
  guard sizes.length() > 0 else {
    raise CallFuncError("pie require non-empty data list")
  }

  let func = pyplot_get_func!("pie")
  let kwargs = PyDict::new()
  keywords.each(fn (key, val) { kwargs.set(key, val) })

  let sizes = PyList::from(sizes)
  if labels.length() > 0 {
    kwargs.set("labels", labels)
  }

  let plot_args = PyTuple::from(sizes)
  let _ = func.invoke(plot_args, kwargs~)
  plot_args.drop()
  kwargs.drop()
}

///| Matplotlib.pyplot.xlim
pub fn xlim(
  left: Double, right: Double
) -> Unit!MatplotlibError {
  let func = pyplot_get_func!("xlim")

  let list = PyList::from([left, right])
  let args = PyTuple::new(1) .. set(0, list)

  let _ = func.invoke(args)

  args.drop()
}

///| Matplotlib.pyplot.ylim
pub fn ylim(left: Double, right: Double) -> Unit!MatplotlibError {
  let func = pyplot_get_func!("ylim")

  let list = @python.PyList::from([left, right])
  let args = @python.PyTuple::new(1) .. set(0, list)

  let _ = func.invoke(args)

  args.drop()
}

///| Matplotlib.pyplot.title
pub fn title(
  title_str: String,
  // keywords~: Map[String, String] = Map::new()
) -> Unit!MatplotlibError {
  let func = pyplot_get_func!("title")
  let py_str = PyString::from(title_str)

  let args = PyTuple::new(1) .. set(0, py_str)

  let _ = func.invoke(args)

  args.drop()
}


pub fn show() -> Unit!Error {
  let func = pyplot_get_func!("show")
  let _ = func.invoke(PyTuple::new(0))
}

pub fn save(
  filename: String,
  dpi~: Int = 0
) -> Unit!Error {
  let func = pylab_get_func!("save")
  let py_str = PyString::from(filename)

  let args = PyTuple::new(1) .. set(0, py_str)
  let kwargs = PyDict::new()

  if dpi > 0 {
    kwargs.set("dpi", dpi)
  }

  let _ = func.invoke(args, kwargs = kwargs)

  args.drop()
  kwargs.drop()
}
