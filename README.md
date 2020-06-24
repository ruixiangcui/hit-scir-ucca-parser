# UCCA Parser from HIT-SCIR CoNLL2019 Unified Transition-Parser

This repository is based on [the one](https://github.com/DreamerDeo/HIT-SCIR-CoNLL2019) that accompanies the paper
[HIT-SCIR at MRP 2019: A Unified Pipeline for Meaning Representation Parsing via Efficient Training and Effective Encoding](https://www.aclweb.org/anthology/K19-2007.pdf),
providing code to train models and pre/post-process the MRP dataset.

CoNLL2019 Shared Task Official Website: <http://mrp.nlpl.eu/>

## Pre-requisites

- Python 3.6
- AllenNLP 0.9.0

## Dataset

The full MRP training data is available at [mrp-data].
Specifically, we use the publicly available [UCCA data in MRP format](http://svn.nlpl.eu/mrp/2019/public/ucca.tgz?p=28375).

## Model

Download the pre-trained model from [google-drive] (CoNLL2019 Submission Version). 
For prediction, please specify the BERT path in `config.json` to import the bert-indexer and bert-embedder.

## Usage

### Install requirements

After creating a [Conda environment](https://docs.conda.io/en/latest/miniconda.html)
or a [virtualenv](https://virtualenv.pypa.io/en/latest/), run

    pip install -r requirements.txt
    
### Download BERT

The parser uses BERT Large.
To get the BERT checkpoints, run

    cd bert/
    make

### Prepare data

To get the data, augment it with the companion data, and split it to training/validation/evaluation, run

    cd data/
    make split

For evaluation data given only as input text in MRP format, you need to convert the companion data to conllu format:

```shell script
python3 toolkit/preprocess_eval.py \
    udpipe.mrp \
    input.mrp \
    --outdir /path/to/output
```

### Train the parser

Based on AllenNLP, the training command is like

```shell script
CUDA_VISIBLE_DEVICES=${gpu_id} \
TRAIN_PATH=${train_set} \
DEV_PATH=${dev_set} \
BERT_PATH=${bert_path} \
WORD_DIM=${bert_output_dim} \
LOWER_CASE=${whether_bert_is_uncased} \
BATCH_SIZE=${batch_size} \
    allennlp train \
        -s ${model_save_path} \
        --include-package utils \
        --include-package modules \
        --file-friendly-logging \
        ${config_file}
```

Refer to `bash/train.sh` for more and detailed examples.

### Predict with the parser

The predicting command is like

```shell script
CUDA_VISIBLE_DEVICES=${gpu_id} \
    allennlp predict \
        --cuda-device 0 \
        --output-file ${output_path} \
        --predictor ${predictor_class} \
        --include-package utils \
        --include-package modules \
        --batch-size ${batch_size} \
        --silent \
        ${model_save_path} \
        ${test_set}
```

More examples in `bash/predict.sh`.

## Package structure

* `bash/` command pipelines and examples
* `config/` Jsonnet config files
* `metrics/` metrics used in training and evaluation
* `modules/` implementations of modules
* `toolkit/` external libraries and dataset tools
* `utils/` code for input/output and pre/post-processing

## Acknowledgement

We thank the developers of the HIT-SCIR parser.

[mrp-data]: http://mrp.nlpl.eu/index.php?page=4#training "mrp-data"
[mrp-sample-data]: http://svn.nlpl.eu/mrp/2019/public/sample.tgz "mrp-sample-data"
[google-drive]: https://drive.google.com/open?id=1SbtqPdNYZWY9m2cDo58tNuzCFtKUMSj1 "google-drive"
