import os
import json

# Ruta base donde están los archivos JSON originales
BASE_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))

# Carpeta de salida
OUTPUT_DIR = os.path.join(BASE_DIR, 'sin la propiedad rows')

# Asegura que la carpeta exista
os.makedirs(OUTPUT_DIR, exist_ok=True)

# Recorre todos los archivos .json en la carpeta base
for filename in os.listdir(BASE_DIR):
    if filename.endswith('.json'):
        file_path = os.path.join(BASE_DIR, filename)

        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                data = json.load(f)

            # Extraer datos desde results[0]["items"]
            items = data["results"][0]["items"]

            # Nombre del archivo de salida
            output_file = os.path.join(OUTPUT_DIR, filename)

            with open(output_file, 'w', encoding='utf-8') as f:
                json.dump(items, f, indent=4, ensure_ascii=False)

            print(f"✅ Procesado: {filename}")

        except Exception as e:
            print(f"❌ Error en {filename}: {e}")
