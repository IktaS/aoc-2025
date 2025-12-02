import gleam/int
import gleam/list
import gleam/string
import simplifile as file

pub fn rotate_dial(init: Int, e: String) -> Result(Int, Nil) {
  case string.is_empty(e) {
    True -> Ok(init)
    False -> {
      case int.base_parse(string.drop_start(from: e, up_to: 1), 10) {
        Ok(value) -> {
          let delta = case string.starts_with(e, "L") {
            True -> init - value % 100
            False -> init + value % 100
          }
          case delta < 0 {
            True -> Ok(delta + 100)
            False -> Ok(delta % 100)
          }
        }
        Error(err) -> Error(err)
      }
    }
  }
}

pub fn day1() {
  let assert Ok(input) = file.read(from: "./input/day1.txt")
  let result =
    string.split(input, on: "\n")
    |> list.fold(#(50, 0), fn(count, e) {
      let assert Ok(dial) = rotate_dial(count.0, e)
      case dial {
        0 -> #(dial, count.1 + 1)
        _ -> #(dial, count.1)
      }
    })
  Ok(result.1)
}

pub fn rotate_dial_p2(init: Int, e: String) -> Result(#(Int, Int), Nil) {
  case string.is_empty(e) {
    True -> Ok(#(init, 0))
    False -> {
      case int.base_parse(string.drop_start(from: e, up_to: 1), 10) {
        Ok(value) -> {
          let delta = case string.starts_with(e, "L") {
            True -> -value
            False -> value
          }
          // total circular click
          let click = int.absolute_value(delta) / 100
          // remaining movement
          let delta = delta % 100
          // calculate resulting dial
          let resulting_dial = case init == 0 {
            True ->
              case delta < 0 {
                True -> 100 + delta
                False -> delta
              }
            False -> init + delta
          }
          // additional click due to turnover
          let click =
            click
            + case resulting_dial <= 0 {
              True -> 1
              False -> resulting_dial / 100
            }
          let resulting_dial = case resulting_dial < 0 {
            True -> resulting_dial + 100
            False -> resulting_dial % 100
          }

          // echo "init: "
          //   <> int.to_string(init)
          //   <> ", operation: "
          //   <> e
          //   <> ", result: "
          //   <> int.to_string(resulting_dial)
          //   <> ", click: "
          //   <> int.to_string(click)
          Ok(#(resulting_dial, click))
        }
        Error(err) -> Error(err)
      }
    }
  }
}

pub fn day1_p2() {
  let assert Ok(input) = file.read(from: "./input/day1.txt")
  let result =
    string.split(input, on: "\n")
    |> list.fold(#(50, 0), fn(count, e) {
      let assert Ok(dial) = rotate_dial_p2(count.0, e)
      #(dial.0, count.1 + dial.1)
    })
  Ok(result.1)
}
