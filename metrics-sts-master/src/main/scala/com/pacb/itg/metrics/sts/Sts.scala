package com.pacb.itg.metrics.sts

import java.nio.file.{Files, Path}

import scala.xml.{Elem, XML}

object Sts {

  val version = "0.0.7"

  lazy val blank = new Sts(null, null)

  lazy val currentVersion = blank.version

  // placeholder to support other versions down the road
  def apply(p: Path): Sts_v0_02 = {
    Files.exists(p) match {
      case true => Files.isDirectory(p) match {
        case false => loadVersion(p)
        case _ => loadVersion(Files.list(p).toArray.toList.asInstanceOf[List[Path]].filter(_.toString.endsWith(".sts.xml")).head)
      }
      case _ => throw new Exception(s"Path $p must be a .sts.xml file that exists or directory with one in it.")
    }
  }

  // check what version exists and send it back
  def loadVersion(p: Path): Sts_v0_02 = Sts_v0_02(p, XML.loadFile(p.toFile))
}


// current latest version
class Sts(p: Path, xml: Elem) extends Sts_v0_02(p, xml)