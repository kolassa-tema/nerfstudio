#!/bin/bash

# Check if an argument is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <scan-name>"
    exit 1
fi

echo y | ns-train nerfsh
echo y | ns-train kplanes

# Embed the argument into the path
input_path="data/$1/input"

# Print the resulting path
echo "input path is: $input_path/video.mp4"

if [ ! -d "data/$1/processed_hloc" ]; then
    ns-process-data video --data data/$1/input/video.mp4 --output-dir data/$1/processed_hloc --num-frames-target 1000 --sfm-tool hloc --matcher-type superpoint+lightglue
fi


if [ ! -d "data/$1/splat" ]; then
    ns-train splatfacto --pipeline.model.cull_alpha_thresh=0.005 --pipeline.model.continue_cull_post_densification=False --pipeline.model.use_scale_regularization=True --viewer.quit-on-train-completion=True --data data/$1/processed_hloc/ --output-dir data/$1/splat/
    # Get the last directory in the specified path
    first_dir=$(ls -d data/$1/splat/processed_hloc/splatfacto/*/ | tail -n 1)
    # Construct the path with the first directory
    config_path="${first_dir}config.yml"
    ns-export gaussian-splat --load-config $config_path --output-dir data/$1/splat/export
fi

if [ ! -d "data/$1/nerfsh" ]; then

    ns-train nerfsh --data data/$1/processed_hloc --output-dir data/$1/nerfgs_hloc/ --viewer.quit-on-train-completion=True --pipeline.model.camera-optimizer.mode off
    first_dir=$(ls -d data/$1/nerfgs_hloc/processed_hloc/nerfsh/*/ | tail -n 1)
    ns-export-nerfsh --load-config ${first_dir}config.yml --output-dir data/$1/nerfgs_hloc/export --num-points 2000000 --remove-outliers True --normal-method open3d --use_bounding_box False
fi

ns-train kplanes --data data/$1/processed_hloc/ --output-dir data/$1/kplanes/
