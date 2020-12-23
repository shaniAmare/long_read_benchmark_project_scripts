name := "itg_metrics_sts"

version in ThisBuild := "0.0.7"

organization in ThisBuild := "com.pacb"

scalaVersion in ThisBuild := "2.11.8"

scalacOptions in ThisBuild := Seq("-unchecked", "-deprecation", "-encoding", "utf8", "-feature", "-language:postfixOps")

fork in ThisBuild := true

// passed to JVM
javaOptions in ThisBuild += "-Xms256m"
javaOptions in ThisBuild += "-Xmx1g"

// assembly options from - https://github.com/sbt/sbt-assembly
// Don't run the test before building the jar
test in assembly := {}
assemblyJarName in assembly := s"pacb_metrics_sts-${version.value}.jar"
mainClass in assembly := Some("com.pacb.itg.metrics.sts.Main")

// `sbt run` will run this class
mainClass in (Compile, run) := Some("com.pacb.itg.metrics.sts.Main")

// `sbt pack` to make all JARs for a deploy. see https://github.com/xerial/sbt-pack
packSettings

libraryDependencies ++= Seq(
  "org.scala-lang.modules" %% "scala-xml" % "1.0.5",
  "org.specs2" %% "specs2-core" % "3.8.5" % "test"
)

lazy val metrics = RootProject(uri("https://github.com/jfalkner/metrics.git#0.2.3"))
//lazy val metrics = RootProject(file("/Users/jfalkner/tokeep/git/jfalkner/metrics"))

val main = Project(id = "itg_metrics_sts", base = file(".")).dependsOn(metrics)
