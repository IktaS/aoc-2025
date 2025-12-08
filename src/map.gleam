import coord
import gleam/dict
import gleam/list
import gleam/result

pub type Map(value) {
  Map(map: dict.Dict(coord.Coordinate, value), length_x: Int, length_y: Int)
}

pub fn new() -> Map(value) {
  Map(map: dict.new(), length_x: 0, length_y: 0)
}

pub fn get(m: Map(value), c: coord.Coordinate) -> Result(value, Nil) {
  dict.get(m.map, c)
}

pub fn insert(m: Map(value), c: coord.Coordinate, v: value) -> Map(value) {
  let length_x = case c.x > m.length_x {
    True -> c.x
    False -> m.length_x
  }
  let length_y = case c.y > m.length_y {
    True -> c.y
    False -> m.length_y
  }
  let new_map = dict.insert(m.map, c, v)
  Map(map: new_map, length_x: length_x, length_y: length_y)
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
              list.append(acc2, [#(coord.Coordinate(x, y), val)])
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
