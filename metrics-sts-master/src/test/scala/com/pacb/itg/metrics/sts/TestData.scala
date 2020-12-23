package com.pacb.itg.metrics.sts

import java.nio.file.Paths

/**
  * Common test data.
  */
trait TestData {
  // location of test data
  val testData = "/pbi/dept/itg/test-data"
  val movie = "/pbi/collections/320/3200035/r54088_20160923_213253/1_A01/"
  val movieTsName = "m54088_160923_213709"
  val movieDir = Paths.get(testData+movie)
  // alignment from smrtlink-alpha that matches m54088_160923_213709
  val alignment = "/pbi/dept/secondary/siv/smrtlink/smrtlink-alpha/smrtsuite_170220/userdata/jobs_root/000/000731/tasks/pbalign.tasks.consolidate_alignments-0/combined.alignmentset.xml"

}
