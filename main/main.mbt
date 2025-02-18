// typealias PyList = @python.PyList

fn main_err() -> Unit!Error {
  let x = Array::makei(100, fn (i) { i.to_double() })
  let y = x.map(@math.ln)

  @plt.plot!(x, y, color=@plt.Red)
  @plt.show!()
}

fn main {
  main_err?() |> println
}
