#!/bin/bash

# Based on OpenNMT baseline training script:
# https://github.com/OpenNMT/OpenNMT-tf/tree/master/scripts/wmt

source config.sh

echo "Splitting train and valid data"
./split_train_and_valid.py raw_data/source.$sl
./split_train_and_valid.py raw_data/source.$tl

cp raw_data/train.$sl raw_data/all.txt
cat raw_data/train.$tl >> raw_data/all.txt

spm_train --input=raw_data/all.txt --model_prefix=sentencepiece \
           --vocab_size=$vocab_size --character_coverage=$character_coverage\
	   --input_sentence_size=1000000 --shuffle_input_sentence=true

rm raw_data/all.txt

mkdir -p tokenized
spm_encode --model=sentencepiece.model < raw_data/train.$sl > tokenized/train.$sl
spm_encode --model=sentencepiece.model < raw_data/train.$tl > tokenized/train.$tl
spm_encode --model=sentencepiece.model < raw_data/valid.$sl > tokenized/valid.$sl
spm_encode --model=sentencepiece.model < raw_data/valid.$tl > tokenized/valid.$tl

onmt-build-vocab --from_format sentencepiece --from_vocab sentencepiece.vocab --save_vocab tokenized/vocab.vocab

./resume_train.sh
