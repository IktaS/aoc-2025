import gleam/dict
import gleam/list
import gleam/result

pub type Coordinate {
  Coordinate(x: Int, y: Int)
}

pub type Map(value) {
  Map(map: dict.Dict(Coordinate, value), length_x: Int, length_y: Int)
}

pub fn build_map_from_list(l: List(List(value))) -> Result(Map(value), Nil) {
  let list_of_value =
    l
    |> list.index_fold([], fn(acc, row, y) {
      case list.is_empty(row) {
        True -> acc
        False -> {
          let folded_list =
            list.index_fold(row, acc, fn(acc2, val, x) {
              list.append(acc2, [#(Coordinate(x, y), val)])
            })
          folded_list
        }
      }
    })
  use first_arr <- result.try(list.first(l))
  Ok(Map(
    map: dict.from_list(list_of_value),
    length_x: list.length(first_arr) - 1,
    length_y: list.length(l) - 1,
  ))
}
