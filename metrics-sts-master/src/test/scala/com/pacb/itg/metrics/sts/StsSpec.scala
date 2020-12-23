package com.pacb.itg.metrics.sts

import java.nio.file.Paths

import falkner.jayson.metrics.io.CSV
import falkner.jayson.metrics.{Num, NumArray}
import org.specs2.matcher.MatchResult
import org.specs2.mutable.Specification


class StsSpec extends Specification with TestData {

  val stsFileName = s"$movieTsName.sts.xml"
  val pMovieName = "/data/pa/m54088_160923_213709.baz"
  val stsPath = Paths.get(testData + movie + stsFileName)
  lazy val sts = Sts(movieDir)

  def stsDistMatches(name: String,
                     samples: String, mean: String, median: String, stdDev: String, pct95: String,
                     numBins: String, binWidth: String,
                     minOutlier: String, min: String, maxOutlier: String, max: String,
                     bins: Seq[Int]) : MatchResult[Any] = {
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

  "PipeStats checking" should {
    // checks all loading entry points
    "Current version calculates without error" in {
      println(s"Current EOL QC Version: ${Sts.currentVersion}")
      Sts.currentVersion != null mustEqual true
    }
    "Support blank CSV generation" in {
      CSV(Sts.blank).all != null mustEqual true
    }
    "Load latest from sts.xml" in (Sts(stsPath).asString("Movie Name") mustEqual pMovieName)
    "Load from movie directory" in (sts.asString("Movie Name") mustEqual pMovieName)
    "Load fail must raise exception" in (Sts(Paths.get("wont_work")) must throwA(new Exception(s"Path wont_work must be a .sts.xml file that exists or directory with one in it.")) )
    "Load version 0.02 from sts.xml" in (Sts_v0_02(stsPath).asString("Movie Name") mustEqual pMovieName)

    // checks all extracted values
    "MovieLength" in (sts.asString("Movie Length") mustEqual "120")
    // BaselineLevelDist A
    "BaselineLevelDist.A" in (stsDistMatches(
      "Baseline level: A",
      "139099", // SampleNum
      "34.1722", // SampleMean
      "30.1788", // SampleMed
      "19.9866", // SampleStd
      "70.5634", // Sample95thPct
      "30", // NumBins
      "4.30044", // BinWidth
      "1.09859", // MinOutlier
      "1.09859", // MinBinValue
      "143.894", // MaxOutlier
      "130.112", // MaxBinValue
      Seq(1537, 9668, 12581, 13216, 12936, 11675, 10422, 9050, 8079, 7241, 6815, 6663, 6421, 5879, 5224, 4176, 3127, 1979, 1140, 677, 349, 146, 56, 25, 14, 1, 1, 0, 0, 0)
    ))
    // A and C are identical. Due to Sequel multiplexing?
    "BaselineLevelDist.C" in (stsDistMatches(
      "Baseline level: C",
      "139099", // SampleNum
      "34.1722", // SampleMean
      "30.1788", // SampleMed
      "19.9866", // SampleStd
      "70.5634", // Sample95thPct
      "30", // NumBins
      "4.30044", // BinWidth
      "1.09859", // MinOutlier
      "1.09859", // MinBinValue
      "143.894", // MaxOutlier
      "130.112", // MaxBinValue
      Seq(1537, 9668, 12581, 13216, 12936, 11675, 10422, 9050, 8079, 7241, 6815, 6663, 6421, 5879, 5224, 4176, 3127, 1979, 1140, 677, 349, 146, 56, 25, 14, 1, 1, 0, 0, 0)
    ))
    // G and T are identical. Due to Sequel multiplexing?
    "BaselineLevelDist.G" in (stsDistMatches(
      "Baseline level: G", "139099", "69.0539", "59.9932", "42.3661", "147.275", "30", "7.86268", "1.64085", "1.64085", "237.521", "237.521",
      Seq(1611, 8879, 11337, 11643, 11685, 10889, 9660, 8698, 7753, 6891, 6359, 6003, 5702, 5503, 5216, 4778, 4244, 3690, 2884, 2097, 1485, 938, 536, 340, 171, 72, 22, 8, 1, 3)))
    "BaselineLevelDist.T" in (stsDistMatches(
      "Baseline level: T", "139099", "69.0539", "59.9932", "42.3661", "147.275", "30", "7.86268", "1.64085", "1.64085", "237.521", "237.521",
      Seq(1611, 8879, 11337, 11643, 11685, 10889, 9660, 8698, 7753, 6891, 6359, 6003, 5702, 5503, 5216, 4778, 4244, 3690, 2884, 2097, 1485, 938, 536, 340, 171, 72, 22, 8, 1, 3)))
    "BaselineStdDist A" in (stsDistMatches(
      "Baseline StdDev: A", "139099", "8.01388", "0.000105581", "14.1638", "37.8", "30", "1.66", "0", "0", "49.8", "49.8",
      Seq(104089, 0, 0, 0, 0, 0, 0, 1, 26, 102, 278, 544, 1028, 1449, 1811, 2460, 2841, 2777, 3014, 2883, 3252, 3309, 2999, 2925, 1887, 976, 343, 81, 19, 3)))
    // A and C are identical. Due to Sequel multiplexing?
    "BaselineStdDist C" in (stsDistMatches(
      "Baseline StdDev: C", "139099", "8.01388", "0.000105581", "14.1638", "37.8", "30", "1.66", "0", "0", "49.8", "49.8",
      Seq(104089, 0, 0, 0, 0, 0, 0, 1, 26, 102, 278, 544, 1028, 1449, 1811, 2460, 2841, 2777, 3014, 2883, 3252, 3309, 2999, 2925, 1887, 976, 343, 81, 19, 3)))
    // G and T are identical. Due to Sequel multiplexing?
    "BaselineStdDist G" in (stsDistMatches(
      "Baseline StdDev: G", "139099", "10.0892", "0.000127495", "17.8715", "47.9", "30", "2.11333", "0", "0", "63.4", "63.4",
      Seq(104089, 0, 0, 0, 0, 0, 0, 7, 63, 151, 372, 739, 1201, 1495, 1985, 2650, 2726, 2768, 2826, 2889, 3020, 3003, 3191, 2748, 1847, 890, 334, 82, 16, 6)))
    "BaselineStdDist T" in (stsDistMatches(
      "Baseline StdDev: T", "139099", "10.0892", "0.000127495", "17.8715", "47.9", "30", "2.11333", "0", "0", "63.4", "63.4",
      Seq(104089, 0, 0, 0, 0, 0, 0, 7, 63, 151, 372, 739, 1201, 1495, 1985, 2650, 2726, 2768, 2826, 2889, 3020, 3003, 3191, 2748, 1847, 890, 334, 82, 16, 6)))
  }
  "CSV serialization has Productivity" in {
    val chunk = CSV(sts)
    chunk.map("Productivity: Empty") mustEqual "879017"
    chunk.map("Productivity: Productive") mustEqual "139099"
    chunk.map("Productivity: Other") mustEqual "16101"
    chunk.map("Productivity: Undefined") mustEqual "0"
  }
  "CSV serialization has Read Type" in {
    val chunk = CSV(sts)
    chunk.map("Read Type: Empty") mustEqual "879017"
    chunk.map("Read Type: FullHqRead0") mustEqual "49419"
    chunk.map("Read Type: FullHqRead1") mustEqual "8444"
    chunk.map("Read Type: PartialHqRead0") mustEqual "65659"
    chunk.map("Read Type: PartialHqRead1") mustEqual "11629"
    chunk.map("Read Type: PartialHqRead2") mustEqual "3948"
    chunk.map("Read Type: Indeterminate") mustEqual "16101"
  }
}
