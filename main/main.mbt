// typealias PyList = @python.PyList

fn plot_example() -> Unit!Error {
  let x = Array::makei(100, Int::to_double)
  let y = x.map(@math.ln)

  @plt.plot!(x, y, color=@plt.Red)
  @plt.show!()
}

fn bar_example() -> Unit!Error {

  let x = ["Jan", "Feb", "Mar", "Apr", "May"]
  let y = [100.0, 200.0, 300.0, 400.0, 500.0]

  @plt.bar!(x, y, color=@plt.Yellow)
  @plt.show!()
}

fn pie_example() -> Unit!Error {
  let labels = ["A", "B", "C", "D"]
  let sizes = [15.0, 30.0, 45.0, 10.0]

  @plt.pie!(sizes, labels=labels)
  @plt.show!()
}

fn main {
  // bar_example?() |> println
  pie_example?() |> println
}
