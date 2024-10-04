#!/bin/bash

# Check if an argument is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <scan-name>"
    exit 1
fi

pip install "numpy<2"
echo y | ns-train nerfsh

# Embed the argument into the path
input_path="data/$1/input"

# Print the resulting path
echo "input path is: $input_path/video.mp4"

ns-process-data video --data data/$1/input/video.mp4 --output-dir data/$1/processed_hloc --num-frames-target 5000 --sfm-tool hloc --refine-pixsfm --use-sfm-depth --matcher-type superpoint+lightglue
ns-train splatfacto-big --pipeline.model.cull_alpha_thresh=0.005 --pipeline.model.continue_cull_post_densification=False --pipeline.model.use_scale_regularization=True --data data/$1/processed_hloc/ --output-dir data/$1/splat-big_hloc/

# Get the last directory in the specified path
first_dir=$(ls -d data/$1/splat_hloc/processed_hloc/splatfacto/*/ | tail -n 1)

# Check if the directory exists
if [ -z "$first_dir" ]; then
    echo "No directory found in data/$1/splat_hloc/processed_hloc/splatfacto/"
    exit 1
fi


# Construct the path with the first directory
config_path="${first_dir}config.yml"

# Print the resulting config path
echo "Config path is: $config_path"
ns-export gaussian-splat --load-config $config_path --output-dir data/$1/splat-big_hloc/export

ns-train nerfsh --data data/$1/processed_hloc --output-dir data/$1/nerfgs_hloc/ --pipeline.model.camera-optimizer.mode off

first_dir=$(ls -d data/$1/nerfgs_hloc/processed_hloc/nerfsh/*/ | tail -n 1)

ns-export-nerfsh --load-config ${first_dir}config.yml --output-dir data/$1/nerfgs_hloc/export --num-points 2000000 --remove-outliers True --normal-method open3d --use_bounding_box False
