import coord
import gleam/dict
import gleam/int
import gleam/list
import gleam/option
import gleam/result
import gleam/string
import map
import simplifile as file

pub fn count_split(
  acc: #(Int, dict.Dict(coord.Coordinate, Bool)),
  m: map.Map(String),
  c: coord.Coordinate,
) {
  let #(count, visited) = acc
  let is_visited = dict.get(visited, c) |> result.unwrap(False)
  case
    c.y > m.length_y || c.x > m.length_x || c.x < 0 || c.y < 0 || is_visited
  {
    True -> Ok(#(count, visited))
    False -> {
      use value <- result.try(map.get(m, c))
      let visited = dict.insert(visited, c, True)
      case value {
        "^" -> {
          let count = count + 1
          use #(count, visited) <- result.try(count_split(
            #(count, visited),
            m,
            coord.Coordinate(c.x - 1, c.y),
          ))
          count_split(#(count, visited), m, coord.Coordinate(c.x + 1, c.y))
        }
        _ -> count_split(#(count, visited), m, coord.Coordinate(c.x, c.y + 1))
      }
    }
  }
}

fn increment(x: option.Option(Int)) {
  case x {
    option.Some(i) -> i + 1
    option.None -> 1
  }
}

pub fn count_path(
  acc: dict.Dict(coord.Coordinate, Int),
  m: map.Map(String),
  c: coord.Coordinate,
) {
  case c.y > m.length_y || c.x > m.length_x || c.x < 0 || c.y < 0 {
    True -> {
      Ok(dict.upsert(acc, c, increment))
    }
    False -> {
      let visited_count = dict.get(acc, c) |> result.unwrap(0)
      case visited_count > 0 {
        True -> Ok(acc)
        False -> {
          use value <- result.try(map.get(m, c))
          case value {
            "^" -> {
              use acc <- result.try(count_path(
                acc,
                m,
                coord.Coordinate(c.x - 1, c.y),
              ))
              let left_count =
                dict.get(acc, coord.Coordinate(c.x - 1, c.y))
                |> result.unwrap(0)
              use acc <- result.try(count_path(
                acc,
                m,
                coord.Coordinate(c.x + 1, c.y),
              ))
              let right_count =
                dict.get(acc, coord.Coordinate(c.x + 1, c.y))
                |> result.unwrap(0)
              Ok(dict.insert(acc, c, left_count + right_count))
            }
            _ -> {
              use acc <- result.try(count_path(
                acc,
                m,
                coord.Coordinate(c.x, c.y + 1),
              ))
              let visited_count =
                dict.get(acc, coord.Coordinate(c.x, c.y + 1))
                |> result.unwrap(0)
              Ok(dict.insert(acc, c, visited_count))
            }
          }
        }
      }
    }
  }
}

pub fn day7_p1() {
  let assert Ok(input) = file.read(from: "./input/day7.txt")
  let input_str = string.split(input, on: "\n")
  // drop last empty string
  let cleaned_input = list.reverse(input_str) |> list.drop(1) |> list.reverse
  let map_final =
    cleaned_input
    |> list.index_fold(map.new(), fn(acc, line, y) {
      line
      |> string.split("")
      |> list.index_fold(acc, fn(acc, v, x) {
        map.insert(acc, coord.Coordinate(x, y), v)
      })
    })
  let first_coords =
    dict.fold(map_final.map, coord.Coordinate(-1, -1), fn(acc, key, value) {
      case value {
        "S" -> key
        _ -> acc
      }
    })
  use #(count, _) <- result.try(count_split(
    #(0, dict.new()),
    map_final,
    first_coords,
  ))
  Ok(count)
}

pub fn day7_p2() {
  let assert Ok(input) = file.read(from: "./input/day7.txt")
  let input_str = string.split(input, on: "\n")
  // drop last empty string
  let cleaned_input = list.reverse(input_str) |> list.drop(1) |> list.reverse
  let map_final =
    cleaned_input
    |> list.index_fold(map.new(), fn(acc, line, y) {
      line
      |> string.split("")
      |> list.index_fold(acc, fn(acc, v, x) {
        map.insert(acc, coord.Coordinate(x, y), v)
      })
    })
  let first_coords =
    dict.fold(map_final.map, coord.Coordinate(-1, -1), fn(acc, key, value) {
      case value {
        "S" -> key
        _ -> acc
      }
    })
  use final_path <- result.try(count_path(dict.new(), map_final, first_coords))
  dict.get(final_path, first_coords)
}
