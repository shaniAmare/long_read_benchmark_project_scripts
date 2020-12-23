package com.pacb.itg.metrics.sts

import java.nio.file.Path

import falkner.jayson.metrics.{CatDist, _}

import scala.xml.{Elem, Node, XML}

object Sts_v0_02 {
  val version = "0.02"

  def apply(p: Path, parsedXml: Elem): Sts_v0_02 = apply(p, Some(parsedXml))

  def apply(p: Path, parsedXml: Option[Elem] = None): Sts_v0_02 = {
    parsedXml match {
      case Some(xml) => new Sts_v0_02(p, xml)
      case None => new Sts_v0_02(p, XML.loadFile(p.toFile))
    }
  }
}

/**
  * See "Pacific Biosciences: Software Functional Specification: Primary Analysis Metrics: Version 0.2"
  *
  * http://sharepoint/progmgmt/Sequel/ResearchAndDevelopment/Software/Primary/FunctionalSpecifications/SequelPrimaryAnalysisMetrics.docx
  *
  * The intention here is to limit this work to expose data from the above spec.
  *
  * http://itg/metrics/docs.html?STS
  */
class Sts_v0_02(val p: Path, val xml: Node) extends Metrics {
  override val namespace = "STS"
  override val version = s"${Sts.version}~${Sts_v0_02.version}"
  override val values: List[Metric] = List(
    // meta-info from this code
    Str("Code Version", Sts.version),
    Str("Spec Version", Sts_v0_02.version),
    Str("Path", p.toAbsolutePath.toString),
    // 4.1.3 Outputs: "Singleton metrics -- single value for entire chip"
    Str("Movie Name", (xml \ "MovieName").text),
    Num("Movie Length", (xml \ "MovieLength").text),
    Num("Sequencing ZMWs", (xml \ "NumSequencingZmws").text),
    Num("Adapter Dimer Fraction", (xml \ "AdapterDimerFraction").text),
    Num("Short Insert Fraction", (xml \ "ShortInsertFraction").text),
    Num("Reads Fraction", (xml \ "IsReadsFraction").text),
    // 4.1.3 Outputs: "Analog metrics – 4 values, one for each analog per ZMW"
    Num("Total Base Fraction: A", totalBaseFractionPerChannel(xml, "A")),
    Num("Total Base Fraction: C", totalBaseFractionPerChannel(xml, "C")),
    Num("Total Base Fraction: G", totalBaseFractionPerChannel(xml, "G")),
    Num("Total Base Fraction: T", totalBaseFractionPerChannel(xml, "T")),
    ContinuousDist("SNR: A", (root) => (root \ "SnrDist").filter(n => (n \ "@Channel").text == "A").head),
    ContinuousDist("SNR: C", (root) => (root \ "SnrDist").filter(n => (n \ "@Channel").text == "C").head),
    ContinuousDist("SNR: G", (root) => (root \ "SnrDist").filter(n => (n \ "@Channel").text == "G").head),
    ContinuousDist("SNR: T", (root) => (root \ "SnrDist").filter(n => (n \ "@Channel").text == "T").head),
    ContinuousDist("HQ Region SNR: A", (root) => (root \ "HqRegionSnrDist").filter(n => (n \ "@Channel").text == "A").head),
    ContinuousDist("HQ Region SNR: C", (root) => (root \ "HqRegionSnrDist").filter(n => (n \ "@Channel").text == "C").head),
    ContinuousDist("HQ Region SNR: G", (root) => (root \ "HqRegionSnrDist").filter(n => (n \ "@Channel").text == "G").head),
    ContinuousDist("HQ Region SNR: T", (root) => (root \ "HqRegionSnrDist").filter(n => (n \ "@Channel").text == "T").head),
    ContinuousDist("HQ Pk Mid: A", (root) => (root \ "HqBasPkMidDist").filter(n => (n \ "@Channel").text == "A").head),
    ContinuousDist("HQ Pk Mid: C", (root) => (root \ "HqBasPkMidDist").filter(n => (n \ "@Channel").text == "C").head),
    ContinuousDist("HQ Pk Mid: G", (root) => (root \ "HqBasPkMidDist").filter(n => (n \ "@Channel").text == "G").head),
    ContinuousDist("HQ Pk Mid: T", (root) => (root \ "HqBasPkMidDist").filter(n => (n \ "@Channel").text == "T").head),
    // 4.1.3 Outputs: "Per-ZMW metrics – 1 value per ZMW"
    ContinuousDist("Pausiness", (root) => (root \ "PausinessDist").head),
    ContinuousDist("Control Read Qual", (root) => (root \ "ControlReadQual").head),
    ContinuousDist("Control Read Len", (root) => (root \ "ControlReadLenDist").head),
    CatDist("Productivity",
      ((xml \ "ProdDist" \ "BinCounts" \ "BinCount") (0).text.toInt +
        (xml \ "ProdDist" \ "BinCounts" \ "BinCount") (0).text.toInt +
        (xml \ "ProdDist" \ "BinCounts" \ "BinCount") (2).text.toInt +
        (xml \ "ProdDist" \ "BinCounts" \ "BinCount") (3).text.toInt),
      Map(
        ("Empty" -> (xml \ "ProdDist" \ "BinCounts" \ "BinCount") (0).text.toInt),
        ("Productive" -> (xml \ "ProdDist" \ "BinCounts" \ "BinCount") (1).text.toInt),
        ("Other" -> (xml \ "ProdDist" \ "BinCounts" \ "BinCount") (2).text.toInt),
        ("Undefined" -> (xml \ "ProdDist" \ "BinCounts" \ "BinCount") (3).text.toInt)
      ), List("Empty", "Productive", "Other", "Undefined")),
    CatDist("Read Type",
      (xml \ "ReadTypeDist" \ "BinCounts" \ "BinCount").map(_.text.toInt).sum,
      Map[String, AnyVal](
        ("Empty" -> (xml \ "ReadTypeDist" \ "BinCounts" \ "BinCount")(0).text.toInt),
        ("FullHqRead0" -> (xml \ "ReadTypeDist" \ "BinCounts" \ "BinCount")(1).text.toInt),
        ("FullHqRead1" -> (xml \ "ReadTypeDist" \ "BinCounts" \ "BinCount")(2).text.toInt),
        ("PartialHqRead0" -> (xml \ "ReadTypeDist" \ "BinCounts" \ "BinCount")(3).text.toInt),
        ("PartialHqRead1" -> (xml \ "ReadTypeDist" \ "BinCounts" \ "BinCount")(4).text.toInt),
        ("PartialHqRead2" -> (xml \ "ReadTypeDist" \ "BinCounts" \ "BinCount")(5).text.toInt),
        ("Indeterminate" -> (xml \ "ReadTypeDist" \ "BinCounts" \ "BinCount")(6).text.toInt)
      ), List("Empty", "FullHqRead0", "FullHqRead1", "PartialHqRead0", "PartialHqRead1", "PartialHqRead2", "Indeterminate")),
    ContinuousDist("Movie Read Qual", (root) => (root \ "MovieReadQualDist").head), // Missing "MovieReadQualDist"? See ITG-225
    ContinuousDist("Pulse Rate", (root) => (root \ "PulseRateDist").head),
    ContinuousDist("Pulse Width", (root) => (root \ "PulseWidthDist").head),
    ContinuousDist("Base Rate", (root) => (root \ "BaseRateDist").head),
    ContinuousDist("Base Width", (root) => (root \ "BaseWidthDist").head),
    ContinuousDist("Base IPD", (root) => (root \ "BaseIpdDist").head),
    ContinuousDist("Local Base Rate", (root) => (root \ "LocalBaseRateDist").head),
    ContinuousDist("Unfiltered Basecalls", (root) => (root \ "NumUnfilteredBasecallsDist").head),
    ContinuousDist("Read Length", (root) => (root \ "ReadLenDist").head),
    ContinuousDist("Read Qual", (root) => (root \ "ReadQualDist").head),
    ContinuousDist("Insert Read Length", (root) => (root \ "InsertReadLenDist").head),
    ContinuousDist("Insert Read Qual", (root) => (root \ "InsertReadQualDist").head),
    ContinuousDist("Median Insert", (root) => (root \ "MedianInsertDist").head),
    ContinuousDist("HQ Base Fraction", (root) => (root \ "HqBaseFractionDist").head),
    // 4.1.3 Outputs: "Channel metrics – 2 values, one for each sensor channel per ZMW"
    ContinuousDist("Baseline level: A", (root) => (root \ "BaselineLevelDist").filter(n => (n \ "@Channel").text == "A").head),
    ContinuousDist("Baseline level: C", (root) => (root \ "BaselineLevelDist").filter(n => (n \ "@Channel").text == "C").head),
    ContinuousDist("Baseline level: G", (root) => (root \ "BaselineLevelDist").filter(n => (n \ "@Channel").text == "G").head),
    ContinuousDist("Baseline level: T", (root) => (root \ "BaselineLevelDist").filter(n => (n \ "@Channel").text == "T").head),
    ContinuousDist("Baseline StdDev: A", (root) => (root \ "BaselineStdDist").filter(n => (n \ "@Channel").text == "A").head),
    ContinuousDist("Baseline StdDev: C", (root) => (root \ "BaselineStdDist").filter(n => (n \ "@Channel").text == "C").head),
    ContinuousDist("Baseline StdDev: G", (root) => (root \ "BaselineStdDist").filter(n => (n \ "@Channel").text == "G").head),
    ContinuousDist("Baseline StdDev: T", (root) => (root \ "BaselineStdDist").filter(n => (n \ "@Channel").text == "T").head),
    ContinuousDist("Baseline Level Sequencing: AC", (root) => baselineLevelSequencing(xml, "AC")),
    ContinuousDist("Baseline Level Sequencing: GT", (root) => baselineLevelSequencing(xml, "GT")),
    // Missing: BaselineLevelNoZmwsNoAperturesDist
    // Missing: BaselineLevelNoZmwsWithAperturesDist
    // Missing: BaselineLevelZmwGreenFilterOnlyDist
    // Missing: BaselineLevelZmwRedFilterOnlyDist
    // Missing: BaselineLevelZmwFLTIDist
    // Missing: BaselineLevelScatteringMetrologyDist

    // Goat (3.2) is when sts.xml (look for "Signal Processing Version" of 3.2.0-186859 or above) started having Red (A,C) and Green (G,T) spectral angle data.
    ContinuousDist("DmeAngleEstDist: AC", (root) => (root \ "DmeAngleEstDist").filter(n => (n \ "@Channel").text == "A").head),
    ContinuousDist("DmeAngleEstDist: GT", (root) => (root \ "DmeAngleEstDist").filter(n => (n \ "@Channel").text == "G").head),
    Num("Spectral Angle", // red - green = spectral angle as per ITG-273
      (((xml \ "DmeAngleEstDist").filter(n => (n \ "@Channel").text == "A").head) \ "SampleMean").text.toDouble -
        (((xml \ "DmeAngleEstDist").filter(n => (n \ "@Channel").text == "G").head) \ "SampleMean").text.toDouble),

    // Bonus. Not currently in spec?
    Str("PkMidCV: A", pkMidCVPerChannel(xml, "A")), // not in spec?
    Str("PkMidCV: C", pkMidCVPerChannel(xml, "C")),
    Str("PkMidCV: G", pkMidCVPerChannel(xml, "G")),
    Str("PkMidCV: T", pkMidCVPerChannel(xml, "T"))
  )

  def totalBaseFractionPerChannel(xml: Node, n: String): String = (xml \ "TotalBaseFractionPerChannel").filter(n => (n \ "@Channel").text == n).text

  def pkMidCVPerChannel(xml: Node, n: String): String = (xml \ "PkMidCVPerChannel").filter(n => (n \ "@Channel").text == n).text

  def baselineLevelSequencing(xml: Node, n: String): Node = (xml \ "BaselineLevelSequencingDist").filter(n => (n \ "@Channel").text == n).head

  // "4.1.2.1.1  ContinuousDistribution"
  case class ContinuousDist(name: String, node: (Node) => Node) extends Metric with Metrics {
    val namespace = Sts_v0_02.this.namespace
    val version = Sts_v0_02.this.version
    val values: List[Metric] = List(
      Num(s"Samples", (node(xml) \ "SampleSize").text),
      Num(s"Mean", (node(xml) \ "SampleMean").text),
      Num(s"Median", (node(xml) \ "SampleMed").text),
      Num(s"StdDev", (node(xml) \ "SampleStd").text),
      Num(s"95th Pct", (node(xml) \ "Sample95thPct").text),
      Num(s"Num Bins", (node(xml) \ "NumBins").text),
      Num(s"Bin Width", (node(xml) \ "BinWidth").text),
      Num(s"Min Outlier", (node(xml) \ "MinOutlierValue").text),
      Num(s"Min", (node(xml) \ "MinBinValue").text),
      Num(s"Max Outlier", (node(xml) \ "MaxOutlierValue").text),
      Num(s"Max", (node(xml) \ "MaxBinValue").text),
      NumArray(s"Bins", (node(xml) \ "BinCounts" \ "BinCount").map(_.text.toInt))
    )
  }

  def asStsDist(name: String): ContinuousDist = metric(name) match {
    case d: ContinuousDist => d
  }
}