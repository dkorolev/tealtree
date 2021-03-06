#!/bin/bash

BASE=../..
INPUT_FILE=MSLR-WEB30K.zip
FEATURE_NAMES_FILE=feature_names.txt

SAMPLE_RATE=${1:-1.0}

if [ ! -f $INPUT_FILE ]; then
  echo "Downloading MSLR dataset from the Internet..."
  curl http://research.microsoft.com/en-us/um/beijing/projects/mslr/data/MSLR-WEB30K.zip > $INPUT_FILE
fi

unzip -p $INPUT_FILE Fold1/train.txt \
 | $BASE/bin/tealtree \
 --train \
 --input_format svm \
 --default_raw_feature_type uint16 \
 --input_sample_rate $SAMPLE_RATE \
 --feature_names_file $FEATURE_NAMES_FILE \
 --cost_function lambda_rank \
 --exponentiate_label \
 --n_leaves 150 \
 --n_trees 150 \
 --learning_rate 0.1 \
 --output_tree forest.json
 

EVAL="$BASE/bin/tealtree \
 --evaluate \
 --input_format svm \
 --input_sample_rate $SAMPLE_RATE \
 --exponentiate_label \
 --input_tree forest.json"

 
echo "Evaluating on training data:"
unzip -p $INPUT_FILE Fold1/train.txt  | $EVAL \
 --output_predictions pred_train.txt \
 --output_epochs epochs_train.txt

 echo "Evaluating on testing data:"
unzip -p $INPUT_FILE Fold1/test.txt  | $EVAL \
 --output_predictions pred_test.txt \
 --output_epochs epochs_test.txt
