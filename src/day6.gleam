import gleam/dict
import gleam/int
import gleam/list
import gleam/option
import gleam/order
import gleam/result
import gleam/string
import simplifile as file

pub fn handle_upsert(value: Int, operator: String) {
  fn(f: option.Option(Int)) {
    case f {
      option.None -> value
      option.Some(old_value) ->
        case operator {
          "+" -> int.add(old_value, value)
          "*" -> int.multiply(old_value, value)
          _ -> panic as "Invalid operator"
        }
    }
  }
}

fn parse_operators(operator_str: String) {
  let splitted =
    operator_str
    |> string.split("")
  let first = splitted |> list.first |> result.unwrap("")
  let cleaned_splitted = splitted |> list.drop(1)
  echo cleaned_splitted
  let #(a, _) =
    cleaned_splitted
    |> list.fold(#([], first), fn(acc, char) {
      let #(operators, current_operator) = acc
      case char {
        "*" -> #(list.append(operators, [current_operator]), char)
        "+" -> #(list.append(operators, [current_operator]), char)
        _ -> #(operators, current_operator <> char)
      }
    })
  a
}

fn parse_operator(o: String) {
  let length = string.length(o)

  Operator(string.first(o) |> result.unwrap(""), length)
}

pub type Operator {
  Operator(operator: String, length: Int)
}

pub type Operations {
  Operations(operand: List(Int), operator: Operator)
}

fn fold_operations(o: Operations) {
  let init_value = case o.operator.operator {
    "+" -> 0
    "*" -> 1
    _ -> panic as "Invalid operator"
  }
  list.fold(o.operand, init_value, fn(acc, operand) {
    case o.operator.operator {
      "+" -> int.add(acc, operand)
      "*" -> int.multiply(acc, operand)
      _ -> panic as "Invalid operator"
    }
  })
}

pub fn day6_p1() {
  let assert Ok(input) = file.read(from: "./input/day6.txt")
  let input_str = string.split(input, on: "\n")
  // drop last empty string
  let cleaned_input = list.reverse(input_str) |> list.drop(1) |> list.reverse
  use operator_str <- result.try(list.last(cleaned_input))
  let operator_dict =
    parse_operators(operator_str)
    |> echo
    |> list.index_map(fn(operator, index) { #(index, parse_operator(operator)) })
    |> echo
    |> dict.from_list
  let cleaned_input =
    list.reverse(cleaned_input) |> list.drop(1) |> list.reverse
  cleaned_input
  |> list.fold([], fn(acc, operands) {
    let l2 =
      operands
      |> string.split(" ")
      |> list.fold([], fn(acc2, operand) {
        case string.is_empty(operand) {
          True -> acc2
          False -> {
            let value = int.parse(operand) |> result.unwrap(0)
            list.append(acc2, [value])
          }
        }
      })
    list.append(acc, [l2])
  })
  |> list.transpose
  |> list.index_map(fn(operands, index) {
    let operator =
      dict.get(operator_dict, index) |> result.unwrap(Operator("noop", 0))
    Operations(operands, operator)
  })
  |> list.fold(0, fn(acc, operation) { acc + fold_operations(operation) })
  |> Ok
}

pub fn day6_p2() {
  let assert Ok(input) = file.read(from: "./input/day6.txt")
  let input_str = string.split(input, on: "\n")
  // drop last empty string
  let cleaned_input = list.reverse(input_str) |> list.drop(1) |> list.reverse
  use operator_str <- result.try(list.last(cleaned_input))
  let #(operator_list, _) =
    operator_str
    |> string.split(" ")
    |> list.fold(#([], 0), fn(acc, operator) {
      let #(final_list, idx) = acc
      case string.is_empty(operator) {
        True -> acc
        False -> #(
          list.append(final_list, [#(idx, operator |> string.trim)]),
          idx + 1,
        )
      }
    })
  let operator_dict = dict.from_list(operator_list)
  let cleaned_input =
    list.reverse(cleaned_input)
    |> list.drop(1)
    |> list.reverse
    |> list.fold([], fn(acc, operands) {
      let l2 =
        operands
        |> string.split(" ")
      list.append(acc, [l2])
    })
    |> list.transpose
    |> list.index_map(fn(operands, index) {
      echo operands
      let operator = dict.get(operator_dict, index) |> result.unwrap("noop")
      // Operations(operands, operator)
    })
    // |> list.fold(0, fn(acc, operation) {
    //   acc + fold_operation_transpose(operation)
    // })
    |> Ok
}
