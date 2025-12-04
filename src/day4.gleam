import gleam/dict
import gleam/list
import gleam/result
import gleam/string
import simplifile as file

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

pub fn find_all_removable_coords(
  map: Map(String),
) -> Result(List(Coordinate), Nil) {
  list.range(0, map.length_y)
  |> list.try_fold([], fn(acc, y) {
    use count <- result.try(
      list.range(0, map.length_x)
      |> list.try_fold([], fn(acc2, x) {
        use current_value <- result.try(dict.get(map.map, Coordinate(x, y)))
        case current_value == "@" {
          False -> Ok(acc2)
          True -> {
            let rolls = count_rolls_surrounding_coord(map, Coordinate(x, y))
            case rolls < 4 {
              True -> Ok(list.append(acc2, [Coordinate(x, y)]))
              False -> Ok(acc2)
            }
          }
        }
      }),
    )
    Ok(list.append(acc, count))
  })
}

pub fn count_rolls_surrounding_coord(m: Map(String), coords: Coordinate) -> Int {
  let x = coords.x
  let y = coords.y
  let search_space = [
    Coordinate(x - 1, y),
    Coordinate(x + 1, y),
    Coordinate(x, y - 1),
    Coordinate(x, y + 1),
    Coordinate(x - 1, y - 1),
    Coordinate(x + 1, y - 1),
    Coordinate(x - 1, y + 1),
    Coordinate(x + 1, y + 1),
  ]
  search_space
  |> list.fold(0, fn(acc3, search) {
    let search_value = dict.get(m.map, search)
    case search_value {
      Ok(value) ->
        case value == "@" {
          True -> acc3 + 1
          False -> acc3
        }
      Error(_) -> acc3
    }
  })
}

pub fn day4_p1() {
  let assert Ok(input) = file.read(from: "./input/day4.txt")
  let arr =
    string.split(input, on: "\n")
    |> list.fold([], fn(a, line) {
      let line_arr = string.split(string.trim(line), "")
      case list.is_empty(line_arr) {
        True -> a
        False -> list.append(a, [line_arr])
      }
    })
  use map <- result.try(build_map_from_list(arr))
  use removables <- result.try(find_all_removable_coords(map))
  removables
  |> list.length
  |> Ok
}

pub fn count_all_removable_rolls(sum: Int, map: Map(String)) -> Result(Int, Nil) {
  use removables <- result.try(find_all_removable_coords(map))
  let count = list.length(removables)
  case count {
    0 -> Ok(sum)
    _ -> {
      let new_map =
        removables
        |> list.fold(map.map, fn(acc, coord) { dict.insert(acc, coord, ".") })

      count_all_removable_rolls(
        sum + count,
        Map(new_map, length_x: map.length_x, length_y: map.length_y),
      )
    }
  }
}

pub fn day4_p2() {
  let assert Ok(input) = file.read(from: "./input/day4.txt")
  let arr =
    string.split(input, on: "\n")
    |> list.fold([], fn(a, line) {
      let line_arr = string.split(string.trim(line), "")
      case list.is_empty(line_arr) {
        True -> a
        False -> list.append(a, [line_arr])
      }
    })
  use map <- result.try(build_map_from_list(arr))
  Ok(count_all_removable_rolls(0, map))
}
