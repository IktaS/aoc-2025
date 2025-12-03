import gleam/float
import gleam/int
import gleam/list
import gleam/result
import gleam/string
import simplifile as file

pub fn day3_p1() {
  let assert Ok(input) = file.read(from: "./input/day3.txt")
  string.split(input, on: "\n")
  |> list.try_fold(0, fn(count, line) {
    use int_list <- result.try(
      string.split(line, "")
      |> list.try_map(fn(s) { int.parse(s) }),
    )
    let length = list.length(int_list)
    let #(first_digit, first_digit_idx, _) =
      list.fold(int_list, #(0, 0, 0), fn(acc, elem) {
        let #(current_highest, highest_idx, current_idx) = acc
        case elem > current_highest && current_idx < length - 1 {
          True -> #(elem, current_idx, current_idx + 1)
          False -> #(current_highest, highest_idx, current_idx + 1)
        }
      })
    let second_digit =
      list.drop(int_list, first_digit_idx + 1)
      |> list.fold(0, fn(current_highest, elem) {
        case elem > current_highest {
          True -> elem
          False -> current_highest
        }
      })
    Ok(count + first_digit * 10 + second_digit)
  })
}

pub fn find_highest_number_digit(l: List(Int), digit_count: Int) -> Int {
  find_highest_number_with_limit_rec(l, 0, digit_count)
}

pub fn find_highest_number_with_limit_rec(
  l: List(Int),
  sum: Int,
  digit_count: Int,
) -> Int {
  let length = list.length(l)
  case list.is_empty(l) || digit_count == 0 {
    True -> sum
    False -> {
      let search_area = list.take(l, length - digit_count + 1)
      let #(digit, digit_idx, _) =
        list.fold(search_area, #(0, 0, 0), fn(acc, elem) {
          let #(current_highest, highest_idx, current_idx) = acc
          case elem > current_highest {
            True -> #(elem, current_idx, current_idx + 1)
            False -> #(current_highest, highest_idx, current_idx + 1)
          }
        })
      find_highest_number_with_limit_rec(
        list.drop(l, digit_idx + 1),
        sum * 10 + digit,
        digit_count - 1,
      )
    }
  }
}

pub fn day3_p2() {
  let assert Ok(input) = file.read(from: "./input/day3.txt")
  let digit = 12
  string.split(input, on: "\n")
  |> list.try_fold(0, fn(count, line) {
    use int_list <- result.try(
      string.split(line, "")
      |> list.try_map(fn(s) { int.parse(s) }),
    )
    let best_digit = find_highest_number_digit(int_list, digit)
    echo "Best digit: " <> int.to_string(best_digit)
    Ok(count + best_digit)
  })
}
