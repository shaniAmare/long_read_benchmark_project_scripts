package com.pacb.itg.metrics.sts

import java.nio.file.Paths
import falkner.jayson.metrics.io.JSON


object Main extends App {
  val usage = "Usage: java com.pacb.itg.metrics.sts.Main <sts.xml> <output.json>"
  if (args.size != 2)
    println(usage)
  else
    JSON(Paths.get(args(1)), Sts(Paths.get(args(0))))
}
