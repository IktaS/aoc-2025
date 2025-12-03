import gleam/int
import gleam/list
import gleam/string
import simplifile as file

pub fn is_invalid_id_p1(id: Int) -> Bool {
  let s = int.to_string(id)
  let length = string.length(s)
  length % 2 == 0
  && string.drop_start(s, length / 2) == string.drop_end(s, length / 2)
}

pub fn is_invalid_id_p2(id: Int) -> Bool {
  let s = int.to_string(id)
  let length = string.length(s)
  case
    list.range(1, length / 2)
    |> list.find(fn(i) {
      let part = string.drop_end(s, length - i)
      let recreated = string.repeat(part, length / i)
      s == recreated
    })
  {
    Ok(_) -> length >= 2 && True
    Error(_) -> False
  }
}

pub fn sum_invalid_id(
  lower: Int,
  upper: Int,
  is_invalid: fn(Int) -> Bool,
) -> Int {
  list.range(lower, upper)
  |> list.fold(0, fn(count, i) {
    case is_invalid(i) {
      True -> count + i
      False -> count
    }
  })
}

pub fn parse_range(s: String) -> Result(#(Int, Int), Nil) {
  let s = string.trim(s)
  let range =
    list.try_map(string.split(s, "-"), fn(a) { int.base_parse(a, 10) })
  case range {
    Ok(v) ->
      case v {
        [first, second, ..] -> Ok(#(first, second))
        _ -> Error(Nil)
      }
    Error(err) -> Error(err)
  }
}

pub fn day2_p1() {
  let assert Ok(input) = file.read(from: "./input/day2.txt")
  string.split(input, on: ",")
  |> list.try_fold(0, fn(count, range) {
    case parse_range(range) {
      Error(err) -> Error(err)
      Ok(r) -> {
        let result = sum_invalid_id(r.0, r.1, is_invalid_id_p1)
        Ok(count + result)
      }
    }
  })
  |> Ok
}

pub fn day2_p2() {
  let assert Ok(input) = file.read(from: "./input/day2.txt")
  string.split(input, on: ",")
  |> list.try_fold(0, fn(count, range) {
    case parse_range(range) {
      Error(err) -> Error(err)
      Ok(r) -> {
        let result = sum_invalid_id(r.0, r.1, is_invalid_id_p2)
        Ok(count + result)
      }
    }
  })
  |> Ok
}
