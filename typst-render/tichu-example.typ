#import "tichu-history.typ": readTichuHistory, renderTichu, renderTichuGraph

//#set page(width: 150mm, margin: 8mm)
#set page(paper: "a4")
#set text(font: "Noto Sans CJK KR", size: 14pt)

#let data = readTichuHistory("example/tichu-counter-2026-05-09_18-13-29.json")

#renderTichu(
  data,
  match_title: [결승전],
  show_export_time: true,
)

#v(10pt)

#renderTichuGraph(
  data,
  title: "점수 그래프",
  round_label: "라운드",
  score_label: "점수",
  show_legend: false,
)
