enum BoardTool {
  select,
  passArrow,
  runArrow,
  pressArrow,
  curvedRun,
  zone,
  circle,
  textNote,
  eraser,
}

extension BoardToolX on BoardTool {
  bool get isSelect => this == BoardTool.select;

  bool get isDragDrawTool =>
      this == BoardTool.passArrow ||
      this == BoardTool.runArrow ||
      this == BoardTool.pressArrow ||
      this == BoardTool.curvedRun ||
      this == BoardTool.zone ||
      this == BoardTool.circle;

  bool get isTapTool => this == BoardTool.textNote || this == BoardTool.eraser;
}
