#!/bin/bash
#SBATCH --mem=30G
#SBATCH --time=0-10

# UCCA
for split in dev test; do
  allennlp predict \
  --cuda-device -1 \
  --output-file data/ucca-imp-output-$split.mrp \
  --predictor transition_predictor_ucca \
  --include-package utils \
  --include-package modules \
  --include-package metrics \
  --use-dataset-reader \
  --batch-size 32 \
  checkpoints/ucca_bert \
  data/imp/imp.$split.aug.mrp

  mkdir -p data/imp/ucca-imp-output-$split
  python toolkit/mtool/main.py data/imp/ucca-imp-output-$split.mrp data/imp/ucca-imp-output-$split.xml --read mrp --write ucca
  csplit -zk data/imp/ucca-imp-output-$split.xml '/^<root/' -f '' -b "data/imp/ucca-imp-output-$split/%03d.xml" {533}
  python -m semstr.evaluate data/ucca-output.dev data/ewt/dev -qs ucca-output.dev.scores.txt
done

-------------------------------------------
  csplit -zk ucca-imp-output.test.xml '/^<root/' -f '' -b "ucca-imp-output.test/%03d.xml" {533}

  perl -nle 'print $& while m{(?<=passageID=")[^"]*(?=")}g' data/imp_wo_support/ucca-imp-output-$split/* > data/imp_wo_support/$split-name.txt
  for file in *.xml; do read line; mv -v "${file}" "${line}.xml"; done < ../$split-name.txt

  python -m semstr.evaluate data/imp_wo_support/ucca-imp-output.test data/imp/test/ -qs data/imp_wo_support/ucca-output.test.scores.txt

  allennlp predict \
  --cuda-device -1 \
  --output-file data/ucca-imp-output-test.mrp \
  --predictor transition_predictor_ucca \
  --include-package utils \
  --include-package modules \
  --include-package metrics \
  --use-dataset-reader \
  --batch-size 32 \
  checkpoints/ucca_bert \
  data/imp/imp.test.aug.mrp