package com.pacb.itg.metrics.sts

import java.io.ByteArrayOutputStream
import java.nio.file.{Files, Path, Paths}

import falkner.jayson.metrics.io.{CSV, JSON}
import org.specs2.matcher.MatchResult
import org.specs2.mutable.Specification

import collection.JavaConverters._
import falkner.jayson.metrics.Distribution.calcContinuous


/**
  * Example from the README.md
  *
  * Not intended for anything other than being a simple example of use. See MetricsSpec.scala for tests of all the main
  * use cases.
  */
class MainSpec extends Specification with TestData {

  val stsFileName = s"$movieTsName.sts.xml"
  val pMovieName = "/data/pa/m54088_160923_213709.baz"
  val stsPath = Paths.get(testData + movie + stsFileName)

  sequential

  "Main entry point" should {
    "Export JSON without error" in {
      withCleanup { (p) =>
        val buf = new ByteArrayOutputStream()
        Console.withOut(buf) {
          Main.main(Array(stsPath.toAbsolutePath.toString, p.resolve("test.json").toString))
        }
        buf.toString.trim mustEqual ""
      }
    }
    "Show usage if args are incorrect" in {
      val buf = new ByteArrayOutputStream()
      Console.withOut(buf) {
        Main.main(Array())
      }
      buf.toString.trim mustEqual Main.usage
    }
  }

  def withCleanup(f: (Path) => MatchResult[Any]): MatchResult[Any] = {
    val temp = Files.createTempDirectory("sts_main_test")
    try {
      f(temp)
    }
    finally {
      Files.list(temp).iterator.asScala.foreach(p => Files.delete(p))
      Files.delete(temp)
    }
  }
}



