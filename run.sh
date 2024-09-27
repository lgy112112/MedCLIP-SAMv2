#!/bin/bash

# custom config

# Enter the path to your dataset
DATASET=$1

python saliency_maps/generate_saliency_maps.py \
--input-path ${DATASET}/images \
--output-path saliency_map_outputs/${DATASET}/masks \
--val-path ${DATASET}/val_images \
--model-name BiomedCLIP \
--finetuned \
--hyper-opt 

python postprocessing/postprocess_saliency_maps.py \
--input-path ${DATASET}/images \
--output-path coarse_outputs/${DATASET}/masks \
--sal-path saliency_map_outputs/${DATASET}/masks \
--postprocess kmeans\
--filter

python segment-anything/prompt_sam.py \
--input ${DATASET}/images \
--mask-input coarse_outputs/${DATASET}/masks \
--output sam_outputs/${DATASET}/masks \
--model-type vit_h \
--checkpoint sam_checkpoints/sam_vit_h_4b8939.pth \
--prompts boxes

python evaluation/eval.py \
--gt_path ${DATASET}/masks \
--seg_path sam_outputs/${DATASET}/masks \
--save_path sam_outputs/${DATASET}/test.csv 
