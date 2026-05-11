// tichu-history.typ
// Flutter tichu-counter export JSON -> Typst score sheet renderer
// Usage:
//   #import "tichu-history.typ": readTichuHistory, renderTichu
//   #let data = readTichuHistory("test.json")
//   #renderTichu(data)

#import "@preview/cetz:0.4.2"
#import "@preview/cetz-plot:0.1.3"

#let _need(dict, key) = {
  if type(dict) != dictionary {
    panic("Expected a JSON object while reading key `" + key + "`.")
  }

  if not (key in dict) {
    panic("Missing required key: `" + key + "`.")
  }

  dict.at(key)
}

#let _int(dict, key) = {
  let value = _need(dict, key)
  if type(value) != int {
    panic("`" + key + "` must be an int. Actual: " + repr(value))
  }
  value
}

#let _str(dict, key) = {
  let value = _need(dict, key)
  if type(value) != str {
    panic("`" + key + "` must be a string. Actual: " + repr(value))
  }
  value
}

#let _bool(dict, key) = {
  let value = _need(dict, key)
  if type(value) != bool {
    panic("`" + key + "` must be a bool. Actual: " + repr(value))
  }
  value
}

#let _array(dict, key) = {
  let value = _need(dict, key)
  if type(value) != array {
    panic("`" + key + "` must be an array. Actual: " + repr(value))
  }
  value
}

#let _player_name(data, index) = data.playerName.at(index)

#let _is_blue_player(index) = calc.rem(index, 2) == 0

#let _tichu_amount(is_large) = if is_large { 200 } else { 100 }

#let _tichu_label(is_large) = if is_large { "LT" } else { "ST" }

#let _fmt_score(value, plus: false) = {
  let abs_value = calc.abs(value)

  if value < 0 {
    "-" + str(abs_value)
  } else if plus and value > 0 {
    "+" + str(abs_value)
  } else {
    str(abs_value)
  }
}

#let _join(values, sep) = {
  let out = ""
  let first = true

  for value in values {
    if first {
      out = str(value)
      first = false
    } else {
      out = out + sep + str(value)
    }
  }

  out
}

#let _short_export_time(value) = {
  if value == none {
    ""
  } else if type(value) != str {
    str(value)
  } else {
    let base = value.split(".").at(0)
    base.replace("T", " ")
  }
}

#let _is_game_end(blue_total, red_total) = {
  let score_crit = 1000

  if blue_total == red_total {
    false
  } else if blue_total >= score_crit or red_total >= score_crit {
    true
  } else if blue_total <= -score_crit or red_total <= -score_crit {
    true
  } else if calc.abs(blue_total - red_total) >= score_crit {
    true
  } else {
    false
  }
}
#let _player_color(index, blue_color, red_color) = {
  if _is_blue_player(index) { blue_color } else { red_color }
}

#let _colored_player_name(data, index, blue_color, red_color) = {
  text(fill: _player_color(index, blue_color, red_color), weight: "bold")[#_player_name(data, index)]
}

#let _round_note(data, row, blue_color: rgb("#1272a3"), red_color: rgb("#b3262f")) = {
  let notes = ()

  for tichu in row.tichus {
    let label = _tichu_label(tichu.is_large)
    let result = if tichu.success { "성공" } else { "실패" }
    let delta = _fmt_score(tichu.delta, plus: true)
    let suffix = " " + label + " " + result + "(" + delta + ")"

    notes.push([
      #_colored_player_name(data, tichu.player_index, blue_color, red_color)#suffix
    ])
  }

  if row.one_two == "blue" {
    notes.push([
      #text(fill: blue_color, weight: "bold")[#data.blueName] 원투
    ])
  } else if row.one_two == "red" {
    notes.push([
      #text(fill: red_color, weight: "bold")[#data.redName] 원투
    ])
  }

  if notes.len() == 0 {
    []
  } else {
    stack(dir: ttb, spacing: 4pt, ..notes)
  }
}

#let _rounds_from_commands(data) = {
  let commands = _array(_need(data, "commandHistory"), "commands")
  let rounds = ()
  let pending_tichus = ()
  let blue_total = 0
  let red_total = 0
  let round_index = 1

  for command in commands {
    let kind = _str(command, "type")

    if kind == "tichu" {
      let player_index = _int(command, "playerIndex")
      let is_large = _bool(command, "isLarge")

      pending_tichus.push((
        player_index: player_index,
        is_large: is_large,
      ))
    } else if kind == "score" {
      let winner_index = _int(command, "winnerIndex")
      let blue = _int(command, "blueScore")
      let red = _int(command, "redScore")
      let tichu_notes = ()

      for tichu in pending_tichus {
        let amount = _tichu_amount(tichu.is_large)
        let success = tichu.player_index == winner_index
        let delta = if success { amount } else { -amount }

        if _is_blue_player(tichu.player_index) {
          blue = blue + delta
        } else {
          red = red + delta
        }

        tichu_notes.push(
          tichu
            + (
              success: success,
              delta: delta,
            ),
        )
      }

      blue_total = blue_total + blue
      red_total = red_total + red

      rounds.push((
        index: round_index,
        blue: blue,
        red: red,
        blue_total: blue_total,
        red_total: red_total,
        winner_index: winner_index,
        one_two: none,
        tichus: tichu_notes,
      ))

      round_index = round_index + 1
      pending_tichus = ()
    } else if kind == "onetwo" {
      let winner_index = _int(command, "winnerIndex")
      let team = _str(command, "team")
      let blue = 0
      let red = 0

      if team == "blue" {
        blue = 200
      } else if team == "red" {
        red = 200
      } else {
        panic("Unknown OneTwo team: " + team)
      }

      let tichu_notes = ()

      for tichu in pending_tichus {
        let amount = _tichu_amount(tichu.is_large)
        let success = tichu.player_index == winner_index
        let delta = if success { amount } else { -amount }

        if _is_blue_player(tichu.player_index) {
          blue = blue + delta
        } else {
          red = red + delta
        }

        tichu_notes.push(
          tichu
            + (
              success: success,
              delta: delta,
            ),
        )
      }

      blue_total = blue_total + blue
      red_total = red_total + red

      rounds.push((
        index: round_index,
        blue: blue,
        red: red,
        blue_total: blue_total,
        red_total: red_total,
        winner_index: winner_index,
        one_two: team,
        tichus: tichu_notes,
      ))

      round_index = round_index + 1
      pending_tichus = ()
    } else {
      panic("Unknown command type: " + kind)
    }
  }

  (
    rounds: rounds,
    pending_tichus: pending_tichus,
    blue_total: blue_total,
    red_total: red_total,
  )
}

#let readTichuHistory(path, schema_version: 1) = {
  let data = json(path)

  if type(data) != dictionary {
    panic("Tichu history JSON must be a JSON object.")
  }

  let actual_schema_version = _int(data, "schemaVersion")
  if actual_schema_version != schema_version {
    panic("Unsupported schemaVersion: " + str(actual_schema_version) + ". Expected: " + str(schema_version))
  }

  let players = _array(data, "playerName")
  if players.len() != 4 {
    panic("playerName must contain exactly four players.")
  }

  for player in players {
    if type(player) != str {
      panic("Every playerName entry must be a string.")
    }
  }

  let _blue_name = _str(data, "blueName")
  let _red_name = _str(data, "redName")
  let command_history = _need(data, "commandHistory")
  let _commands = _array(command_history, "commands")

  let computed = _rounds_from_commands(data)

  (
    data
      + (
        rounds: computed.rounds,
        pending_tichus: computed.pending_tichus,
        totals: (
          blue: computed.blue_total,
          red: computed.red_total,
        ),
        computed_is_game_end: _is_game_end(computed.blue_total, computed.red_total),
      )
  )
}

#let renderTichu(
  data,
  match_title: "TICHU SCORE SHEET",
  show_export_time: true,
  export_time_label: auto,
  show_summary: true,
  min_rows: none,
  border_color: rgb("#9b1d30"),
  blue_color: rgb("#1272a3"),
  red_color: rgb("#b3262f"),
) = {
  let rounds = data.rounds
  let blue_players = _player_name(data, 0) + " · " + _player_name(data, 2)
  let red_players = _player_name(data, 1) + " · " + _player_name(data, 3)

  let cells = ()

  cells.push(table.cell(fill: rgb("#f8e6e8"))[ ])
  cells.push(table.cell(colspan: 2, fill: rgb("#eef7fb"))[#align(center)[
    #text(fill: blue_color, weight: "bold")[#data.blueName] \
    #text(size: 10pt)[#blue_players]
  ]])
  cells.push(table.cell(colspan: 2, fill: rgb("#fff0f1"))[#align(center)[
    #text(fill: red_color, weight: "bold")[#data.redName] \
    #text(size: 10pt)[#red_players]
  ]])
  cells.push(table.cell(fill: rgb("#f8e6e8"))[ ])

  cells.push(table.header(
    table.cell(fill: rgb("#f8e6e8"))[Round],
    table.cell(fill: rgb("#f8e6e8"))[Total],
    table.cell(fill: rgb("#f8e6e8"))[Score],
    table.cell(fill: rgb("#f8e6e8"))[Score],
    table.cell(fill: rgb("#f8e6e8"))[Total],
    table.cell(fill: rgb("#f8e6e8"))[Details],
  ))

  for row in rounds {
    cells.push([#row.index])
    cells.push(text(fill: blue_color, weight: "bold")[#_fmt_score(row.blue_total)])
    cells.push(text(fill: black)[#_fmt_score(row.blue)])
    cells.push(text(fill: black)[#_fmt_score(row.red)])
    cells.push(text(fill: red_color, weight: "bold")[#_fmt_score(row.red_total)])
    cells.push(text(size: 10pt)[#_round_note(data, row, blue_color: blue_color, red_color: red_color)])
  }

  let blank_count = if min_rows == none {
    0
  } else { min_rows - rounds.len() }
  if blank_count < 0 {
    blank_count = 0
  }

  for i in range(blank_count) {
    cells.push([ ])
    cells.push([ ])
    cells.push([ ])
    cells.push([ ])
    cells.push([ ])
    cells.push([ ])
  }

  let export_time = if "date" in data { data.date } else { none }

  let time_label = if export_time_label == auto {
    if data.computed_is_game_end { "End Time" } else { "Exported Time" }
  } else {
    export_time_label
  }

  rect(width: 100%, stroke: 1.2pt + border_color, radius: 3pt, inset: 8pt)[
    #align(center)[
      #text(size: 17pt, weight: "bold", fill: border_color)[#match_title]
    ]

    #v(-10pt)

    #align(center, table(
      columns: (1fr, 1fr, 1fr, 1fr, 1fr, 3fr),
      inset: (x: 4pt, y: 3.5pt),
      align: (center + horizon, center + horizon, center + horizon, center + horizon, center + horizon, left + horizon),
      stroke: 0.45pt + border_color,
      table.vline(x: 3, stroke: 1pt + border_color),
      ..cells,
    ))

    #v(6pt)

    #if show_summary [
      #grid(
        columns: (1fr, 1fr),
        align: center,
        gutter: 8pt,
        [#text(fill: blue_color, weight: "bold")[Blue Score] #data.totals.blue],
        [#text(fill: red_color, weight: "bold")[Red Score] #data.totals.red],
      )
    ]

    #if show_export_time [
      #v(3pt)
      #align(right)[#text(size: 10pt, fill: rgb("#555"))[#time_label: #_short_export_time(export_time)]]
    ]

    #if data.pending_tichus.len() > 0 [
      #v(3pt)
      #text(
        size: 10pt,
        fill: rgb("#555"),
      )[진행 중 티츄: #_join(data.pending_tichus.map(t => _player_name(data, t.player_index) + " " + _tichu_label(t.is_large)), " · ")]
    ]
  ]
}

#let _score_series(rounds, side) = {
  let points = ((0, 0),)

  for row in rounds {
    if side == "blue" {
      points.push((row.index, row.blue_total))
    } else if side == "red" {
      points.push((row.index, row.red_total))
    } else {
      panic("Unknown score series side: " + side)
    }
  }

  points
}

#let _graph_bounds(rounds) = {
  let min_score = 0
  let max_score = 0

  for row in rounds {
    if row.blue_total < min_score { min_score = row.blue_total }
    if row.red_total < min_score { min_score = row.red_total }

    if row.blue_total > max_score { max_score = row.blue_total }
    if row.red_total > max_score { max_score = row.red_total }
  }

  let span = max_score - min_score

  let step = 200

  let padded_min = step * calc.floor((min_score - step) / step)
  let padded_max = step * calc.ceil((max_score + step) / step)

  (
    min: padded_min,
    max: padded_max,
    step: step,
  )
}

#let renderTichuGraph(
  data,
  title: "Score Trend",
  round_label: "Round",
  score_label: "Score",
  plot_width: 12,
  plot_height: 5,
  blue_color: rgb("#1272a3"),
  red_color: rgb("#b3262f"),
  border_color: rgb("#9b1d30"),
  show_legend: true,
) = {
  let rounds = data.rounds

  if rounds.len() == 0 {
    rect(
      width: 100%,
      stroke: 0.6pt + rgb("#999"),
      radius: 3pt,
      inset: 8pt,
    )[
      #align(center)[완료된 라운드가 아직 없습니다.]
    ]
  } else {
    let blue_data = _score_series(rounds, "blue")
    let red_data = _score_series(rounds, "red")
    let bounds = _graph_bounds(rounds)
    let max_round = rounds.len()

    [
      #align(center)[
        #text(weight: "bold", fill: border_color)[#title]
      ]

      #v(-10pt)

      #align(center)[
        #cetz.canvas(length: 1cm, {
          import cetz.draw: *
          import cetz-plot: *

          set-style(
            axes: (
              stroke: 0.55pt + border_color,
              tick: (
                stroke: 0.45pt + border_color,
              ),
              grid: (
                stroke: 0.25pt + rgb("#dddddd"),
              ),
            ),
          )

          plot.plot(
            size: (plot_width, plot_height),
            axis-style: "scientific",
            legend: none,

            x-min: 0,
            x-max: max_round,
            x-tick-step: 1,
            x-label: [#round_label],

            y-min: bounds.min,
            y-max: bounds.max,
            y-tick-step: bounds.step,
            y-grid: true,
            y-label: [#score_label],

            {
              plot.add(
                blue_data,
                line: "raw",
                mark: "o",
                mark-size: 0.15,
                style: (
                  stroke: 1.2pt + blue_color,
                  fill: none,
                ),
                mark-style: (
                  stroke: 0.7pt + blue_color,
                  fill: white,
                ),
              )

              plot.add(
                red_data,
                line: "raw",
                mark: "o",
                mark-size: 0.15,
                style: (
                  stroke: 1.2pt + red_color,
                  fill: none,
                ),
                mark-style: (
                  stroke: 0.7pt + red_color,
                  fill: white,
                ),
              )
            },
          )
        })
      ]

      #if show_legend [
        #v(4pt)
        #align(center)[
          #text(fill: blue_color, weight: "bold")[#data.blueName]
          #h(1.5em)
          #text(fill: red_color, weight: "bold")[#data.redName]
        ]
      ]
    ]
  }
}
