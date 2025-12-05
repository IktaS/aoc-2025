import gleam/dict
import gleam/int
import gleam/list
import gleam/order
import gleam/result
import gleam/string
import simplifile as file

pub fn is_overlapping(a: #(Int, Int), b: #(Int, Int)) {
  let #(a_start, a_end) = a
  let #(b_start, b_end) = b
  case a_start <= b_end && a_start >= b_start {
    True -> True
    False -> b_start <= a_end && b_start >= a_start
  }
}

pub fn merge_range(a: #(Int, Int), b: #(Int, Int)) {
  let #(a_start, a_end) = a
  let #(b_start, b_end) = b
  #(int.min(a_start, b_start), int.max(a_end, b_end))
}

pub fn reduce_ranges(ranges: List(#(Int, Int))) {
  let sorted_list =
    list.sort(ranges, fn(a, b) {
      let #(a_start, _) = a
      let #(b_start, _) = b
      case a_start < b_start {
        True -> order.Lt
        False -> order.Gt
      }
    })
  case sorted_list {
    [] -> []
    [first] -> [first]
    [first, ..rest] -> {
      let #(merged_interval, last_range) =
        list.fold(rest, #([], first), fn(acc, range) {
          let #(merged_interval, last_range) = acc
          case is_overlapping(last_range, range) {
            False -> {
              #(list.append(merged_interval, [last_range]), range)
            }
            True -> {
              let merged = merge_range(last_range, range)
              #(merged_interval, merged)
            }
          }
        })
      list.append(merged_interval, [last_range])
    }
  }
}

pub fn day5_p1() {
  let assert Ok(input) = file.read(from: "./input/day5.txt")
  let input_str = string.split(input, on: "\n\n")
  let #(ranges, input) = case input_str {
    [a, b] -> #(a, b)
    _ -> panic as "Unexpected input"
  }
  let ranges_int =
    ranges
    |> string.split("\n")
    |> list.fold([], fn(acc, range) {
      let r = string.split(range, on: "-")
      let #(lower, upper) = case r {
        [a, b] -> #(
          result.unwrap(int.parse(a), -1),
          result.unwrap(int.parse(b), -1),
        )
        _ -> panic as "Unexpected input"
      }
      list.append(acc, [#(lower, upper)])
    })
  let ranges_int = ranges_int |> reduce_ranges
  echo ranges_int
  input
  |> string.split("\n")
  |> list.try_fold(0, fn(acc, line) {
    case string.is_empty(line) {
      True -> Ok(acc)
      False -> {
        use v <- result.try(int.parse(line))
        case
          list.find(ranges_int, fn(a) {
            let #(a_start, a_end) = a
            v >= a_start && v <= a_end
          })
        {
          Ok(_) -> {
            // echo "Found fresh :"
            //   <> int.to_string(v)
            //   <> " in range "
            //   <> int.to_string(r.0)
            //   <> "-"
            //   <> int.to_string(r.1)
            Ok(acc + 1)
          }
          Error(_) -> {
            // echo "Found spoiled :" <> int.to_string(v)
            Ok(acc)
          }
        }
      }
    }
  })
  |> Ok
}

pub fn day5_p2() {
  let assert Ok(input) = file.read(from: "./input/day5.txt")
  let input_str = string.split(input, on: "\n\n")
  let #(ranges, input) = case input_str {
    [a, b] -> #(a, b)
    _ -> panic as "Unexpected input"
  }
  let ranges_int =
    ranges
    |> string.split("\n")
    |> list.fold([], fn(acc, range) {
      let r = string.split(range, on: "-")
      let #(lower, upper) = case r {
        [a, b] -> #(
          result.unwrap(int.parse(a), -1),
          result.unwrap(int.parse(b), -1),
        )
        _ -> panic as "Unexpected input"
      }
      list.append(acc, [#(lower, upper)])
    })
  let ranges_int = ranges_int |> reduce_ranges
  ranges_int
  |> list.fold(0, fn(acc, range) {
    let #(lower, upper) = range
    acc + upper - lower + 1
  })
  |> Ok
}
