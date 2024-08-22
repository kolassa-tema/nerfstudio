import cv2
import os

def convert_videos(input_folder, output_folder, step):
    image_id = 0
    for root, dirs, files in os.walk(input_folder):
        for file in files:
            if file.lower().endswith('.mp4'):
                path = os.path.join(root, file)
                cap = cv2.VideoCapture(path)
                frameCount = cap.get(cv2.CAP_PROP_FRAME_COUNT)
                for i in range(0, int(frameCount), step):
                    for j in range(0, step):
                        ret, frame = cap.read()
                    if frame is None:
                        break
                    
                    ok = cv2.imwrite(os.path.join(output_folder, "frame_" + str(image_id) + '.jpg'), frame)
                    if not ok:
                        print('Error while saving frame ' + str(image_id))
                    else:
                        print('Saved frame ' + str(image_id))
                    image_id += 1
                cap.release()
    return

if __name__ == '__main__':
    #get arguments
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument('--input_folder', type=str, required=True)
    parser.add_argument('--output_folder', type=str, required=True)
    parser.add_argument('--step', type=int, default=10)
    args = parser.parse_args()
    convert_videos(args.input_folder, args.output_folder, args.step)