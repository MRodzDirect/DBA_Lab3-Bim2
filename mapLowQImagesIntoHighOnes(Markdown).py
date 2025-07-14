import os
from PIL import Image
import imagehash
import shutil

def get_image_hash(image_path):
    try:
        with Image.open(image_path) as img:
            return imagehash.average_hash(img)
    except Exception as e:
        print(f"Error processing {image_path}: {e}")
        return None

def map_images(low_quality_dir, high_quality_dir, output_dir):
    # Create output directory if it doesn't exist
    os.makedirs(output_dir, exist_ok=True)
    
    # Get lists of image files
    low_quality_images = [f for f in os.listdir(low_quality_dir) if f.endswith('.png')]
    high_quality_images = [f for f in os.listdir(high_quality_dir) if f.endswith('.png')]
    
    # Sort low-quality images by their numerical suffix (e.g., .001.png, .002.png)
    low_quality_images.sort(key=lambda x: int(x.split('.')[-2]))
    
    # Compute hashes for all images
    low_quality_hashes = {}
    high_quality_hashes = {}
    
    for img in low_quality_images:
        hash_val = get_image_hash(os.path.join(low_quality_dir, img))
        if hash_val:
            low_quality_hashes[img] = hash_val
    
    for img in high_quality_images:
        hash_val = get_image_hash(os.path.join(high_quality_dir, img))
        if hash_val:
            high_quality_hashes[img] = hash_val
    
    # Map low-quality to high-quality images
    mappings = {}
    for low_img, low_hash in low_quality_hashes.items():
        min_diff = float('inf')
        best_match = None
        for high_img, high_hash in high_quality_hashes.items():
            diff = low_hash - high_hash
            if diff < min_diff:
                min_diff = diff
                best_match = high_img
        if best_match:
            mappings[low_img] = best_match
            # Remove matched high-quality image to prevent reuse
            del high_quality_hashes[best_match]
    
    # Copy high-quality images to output directory with low-quality names
    for low_img, high_img in mappings.items():
        shutil.copy2(
            os.path.join(high_quality_dir, high_img),
            os.path.join(output_dir, low_img)
        )
        print(f"Mapped {low_img} to {high_img}")

# Example usage
low_quality_dir = "/mnt/c/Users/MRodz/Documents/U/4th Cycle/Advanced Data Bases/Lab_3-Bim2/laboratorio numero 3"
high_quality_dir = "/mnt/c/Users/MRodz/Documents/U/4th Cycle/Advanced Data Bases/Lab_3-Bim2/assets"
output_dir = "/mnt/c/Users/MRodz/Documents/U/4th Cycle/Advanced Data Bases/Lab_3-Bim2/gq-images"
map_images(low_quality_dir, high_quality_dir, output_dir)
