package com.pacb.itg.metrics.sts

import java.nio.file.Paths

import falkner.jayson.metrics.io.CSV
import falkner.jayson.metrics.{Num, NumArray}
import org.specs2.matcher.MatchResult
import org.specs2.mutable.Specification

/**
  * Tests for sts.xml updates added in 3.2 (aka "Goat")
  *
  * See ITG-273
  */
class Sts_3_2_Goat_Spec extends Specification with TestData {

  val stsPath = Paths.get(s"$testData/pbi/analysis/refarm/317/3170181/r54007_20161118_213950/1_A01/Sequel_3.3.0/m54007_161118_214050.sts.xml")
  lazy val sts = Sts(stsPath)

  def stsDistMatches(name: String,
                     samples: String, mean: String, median: String, stdDev: String, pct95: String,
                     numBins: String, binWidth: String,
                     minOutlier: String, min: String, maxOutlier: String, max: String,
                     bins: Seq[Int]): MatchResult[Any] = {
    val d = sts.asStsDist(name).values
    d(0).asInstanceOf[Num].value mustEqual samples
    d(1).asInstanceOf[Num].value mustEqual mean
    d(2).asInstanceOf[Num].value mustEqual median
    d(3).asInstanceOf[Num].value mustEqual stdDev
    d(4).asInstanceOf[Num].value mustEqual pct95
    d(5).asInstanceOf[Num].value mustEqual numBins
    d(6).asInstanceOf[Num].value mustEqual binWidth
    d(7).asInstanceOf[Num].value mustEqual minOutlier
    d(8).asInstanceOf[Num].value mustEqual min
    d(9).asInstanceOf[Num].value mustEqual maxOutlier
    d(10).asInstanceOf[Num].value mustEqual max
    d(11).asInstanceOf[NumArray].values mustEqual bins
  }

  "Goat sts.xml checking" should {
    // BaselineLevelDist A
    "DmeAngleEstDist: A,C (aka Red)" in (stsDistMatches(
      "DmeAngleEstDist: AC",
      "49491", // SampleNum
      "83.4061", // SampleMean
      "83.4401", // SampleMed
      "0.553837", // SampleStd
      "84.25", // Sample95thPct
      "30", // NumBins
      "0.184612", // BinWidth
      "79.57", // MinOutlier
      "80.6709", // MinBinValue
      "86.27", // MaxOutlier
      "86.2093", // MaxBinValue
      Seq(9, 7, 13, 31, 58, 121, 269, 385, 826, 1273, 2209, 3045, 4432, 5515, 6688, 6699, 6210, 5137, 3184, 1919, 831, 366, 154, 54, 15, 23, 3, 4, 0, 1)
    ))
    "DmeAngleEstDist: G,T (aka Green)" in (stsDistMatches(
      "DmeAngleEstDist: GT",
      "49491", // SampleNum
      "51.3246", // SampleMean
      "51.3126", // SampleMed
      "2.68936", // SampleStd
      "55.76", // Sample95thPct
      "30", // NumBins
      "0.744667", // BinWidth
      "39.14", // MinOutlier
      "39.14", // MinBinValue
      "61.48", // MaxOutlier
      "61.48", // MaxBinValue
      Seq(2, 0, 2, 8, 23, 55, 139, 239, 526, 872, 1580, 2346, 3121, 4032, 4661, 5206, 5293, 5115, 4354, 3804, 2966, 2169, 1449, 833, 416, 180, 69, 24, 4, 2)
    ))
    "Spectral Angle is a calculated form of DME" in {
      sts.asString("Spectral Angle") mustEqual (sts.asStsDist("DmeAngleEstDist: AC").values(1).asInstanceOf[Num].value.toDouble - sts.asStsDist("DmeAngleEstDist: GT").values(1).asInstanceOf[Num].value.toDouble).toString
    }
  }
}