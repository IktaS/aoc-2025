import gleam/dict
import gleam/int
import gleam/list
import gleam/option
import gleam/order
import gleam/regexp
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
  let assert Ok(re) = regexp.from_string("\\S\\s*")

  regexp.scan(re, operator_str) |> list.map(fn(op) { op.content })
}

fn parse_operator(o: String) {
  let length = string.length(o)

  Operator(string.first(o) |> result.unwrap(""), length - 1)
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
    |> list.index_map(fn(operator, index) { #(index, parse_operator(operator)) })
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
  let operator_dict =
    parse_operators(operator_str)
    |> list.index_map(fn(operator, index) { #(index, parse_operator(operator)) })
    |> dict.from_list
  let operator_dict_length = dict.keys(operator_dict) |> list.length
  let cleaned_input =
    list.reverse(cleaned_input) |> list.drop(1) |> list.reverse
  cleaned_input
  |> list.map(fn(operands) {
    let operand_l = string.split(operands, "")
    list.range(0, operator_dict_length - 1)
    |> list.fold(#(operand_l, []), fn(acc, index) {
      let #(current_list, end_list) = acc
      let value =
        dict.get(operator_dict, index) |> result.unwrap(Operator("noop", 0))
      let taken_list = list.take(current_list, value.length)
      let new_list = list.drop(current_list, value.length + 1)
      #(new_list, list.append(end_list, [taken_list]))
    })
  })
  |> list.map(fn(list) {
    let #(_, a) = list
    a
  })
  |> list.fold(dict.new(), fn(acc, operands) {
    operands
    |> list.index_fold(acc, fn(acc, operand, index) {
      dict.upsert(acc, index, fn(x) {
        case x {
          option.None -> [operand]
          option.Some(v) -> list.append(v, [operand])
        }
      })
    })
  })
  |> dict.fold([], fn(acc, key, value) {
    let operator =
      dict.get(operator_dict, key) |> result.unwrap(Operator("noop", 0))
    let transposed_mapped_value =
      value
      |> list.transpose
      |> list.map(fn(x) {
        string.join(x, "")
        |> string.trim
        |> int.parse
        |> result.unwrap(0)
      })
    list.append(acc, [Operations(transposed_mapped_value, operator)])
  })
  |> list.fold(0, fn(acc, operation) { acc + fold_operations(operation) })
  |> Ok
}
