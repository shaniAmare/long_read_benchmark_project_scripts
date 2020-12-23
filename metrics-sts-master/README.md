# PipeStats (aka *.sts.xml) Metrics

Exports all the commonly used PipeStats metrics from the PacBio
supported pipeline. It can be a slow and tedious to sort out where 
metrics exist and how they were calculated. This project aims to solve
that with docs, tests and exports to JSON and CSV. Use the data!

Key goals of this project.

- Export data from PipeStats (*.sts.xml) files to convenient to use CSV or JSON
- Support all known versions. Don't assume the latest.
- Scala API for quick access to typed data or raw values from the input files
- Documentation
  - Keep a version history for sts.xml schema changes
  - Explain what each metric means in [easy-to-use documentation](#metrics)

See the overall PacBio Metrics project if you want to aggregate metrics
from more than just PipeStats files.

## Usage

Export metrics by passing one or more files and directories that contain sts.xml files. First build a JAR.

```
# Option 1: Build a JAR for standalone use (example below)
sbt run
```

Exporting aligned movies is the most common use case. See [ITG-190](https://jira.pacificbiosciences.com/browse/ITG-190) for an example.

```
# Export all the data to a CSV named ITG-190.csv
sbt "run m54088_160923_213709.sts.xml m54088_160923_213709.csv"

# Another option is to export to a JSON
sbt "run m54088_160923_213709.sts.xml m54088_160923_213709.json"
```

## Metrics

The full list of metrics is listed on [itg/metrics/docs.html under the namespace STS](http://itg/metrics/docs.html?q=STS),
which is derived from the [Scala code in this project](src/main/scala/com/pacb/itg/metrics/sts/Sts_3_0_1.scala).

TODO: work the below disclosure in to metrics-docs.

PipeStats is a dumping group of metrics and stats. You'll find that it has
a lot of numbers and distributions that may not be what you expect. Here
is a list of key points to consider before reading each metric.

- The instrument makes PipeStats calculations based on *all* ZMWs. It does
  this while subreads are being called and before any alignment.
- Many ZMWs will not generate reads or make unusable data (e.g. two polymerases in the same well)
- You probably want to remove the 0 values from the distributions. If you don't,
  the mean and medians are not useful. This code will also do this and prefix metrics with "NZ" (No Zeros). e.g. NZ Read Length
- A common strategy for refining PipeStats metrics is to sequence a 
  reference, do an alignment to the known genome, then re-generate similar
  stats using only the ZMWs that provided alignable reads.
- It isn't always smart to ignore the 0's. If you are trying to improve
  loading, then you need to consider what % ZMWs made usable data.