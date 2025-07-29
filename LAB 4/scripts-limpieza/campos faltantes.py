import json
import os

# Crear la carpeta de salida si no existe
output_dir = "camposfaltantes"
if not os.path.exists(output_dir):
    os.makedirs(output_dir)

# Función para transformar un archivo JSON
def transform_json(input_file, output_file, id_field, fields_mapping, id_type):
    try:
        # Leer el archivo JSON de entrada
        with open(input_file, 'r', encoding='utf-8') as f:
            data = json.load(f)
        
        # Verificar que data es una lista
        if not isinstance(data, list):
            raise ValueError(f"El archivo {input_file} no contiene una lista de objetos")
        
        transformed_data = []
        for item in data:
            # Verificar que item es un diccionario
            if not isinstance(item, dict):
                raise ValueError(f"Un elemento en {input_file} no es un objeto válido: {item}")
            
            # Crear un nuevo documento
            transformed_item = {}
            # Renombrar el campo ID a _id y convertir al tipo correcto
            if id_field not in item:
                raise KeyError(f"El campo {id_field} no se encuentra en un objeto de {input_file}")
            id_value = item[id_field]
            if id_value is None:
                raise ValueError(f"El campo {id_field} es nulo en un objeto de {input_file}")
            transformed_item['_id'] = int(id_value) if id_type == 'Number' else str(id_value)
            
            # Copiar los otros campos según el mapeo y manejar tipos
            for new_field, old_field in fields_mapping.items():
                value = item.get(old_field, None)
                # Convertir valores numéricos si es necesario
                if new_field in ['termination_month', 'termination_year', 'calendar_year', 'quarter', 
                               'base_salary', 'overtime_gross_pay_qtd', 'base_gross_pay_qtd', 
                               'longevity_gross_pay_qtd', 'post_separation_gross_pay_qtd', 
                               'miscellaneous_gross_pay_qtd', 'total_gross_pay', 
                               'employee_id', 'department_id']:
                    transformed_item[new_field] = float(value) if value is not None else None
                else:
                    transformed_item[new_field] = value
            transformed_data.append(transformed_item)
        
        # Escribir el archivo JSON transformado
        with open(output_file, 'w', encoding='utf-8') as f:
            json.dump(transformed_data, f, indent=2)
        print(f"Archivo transformado guardado como: {output_file}")
    
    except FileNotFoundError:
        print(f"Error: No se encontró el archivo {input_file}")
    except Exception as e:
        print(f"Error al procesar {input_file}: {str(e)}")

# Definir los mapeos de campos para cada colección
mappings = {
    'employees': {
        'input_file': os.path.join('sin la propiedad results', 'employees.json'),
        'output_file': os.path.join('camposfaltantes', 'employees_transformed.json'),
        'id_field': 'employee_id',
        'id_type': 'Number',
        'fields_mapping': {
            'first_name': 'first_name',
            'last_name': 'last_name',
            'employee_category': 'employee_category',
            'compulsory_union_code': 'compulsory_union_code',
            'termination_month': 'termination_month',
            'termination_year': 'termination_year'
        }
    },
    'departments': {
        'input_file': os.path.join('sin la propiedad results', 'departments.json'),
        'output_file': os.path.join('camposfaltantes', 'departments_transformed.json'),
        'id_field': 'department_id',
        'id_type': 'Number',
        'fields_mapping': {
            'department_name': 'department_name'
        }
    },
    'job_titles': {
        'input_file': os.path.join('sin la propiedad results', 'job_titles.json'),
        'output_file': os.path.join('camposfaltantes', 'job_titles_transformed.json'),
        'id_field': 'job_code',
        'id_type': 'String',
        'fields_mapping': {
            'title': 'title'
        }
    },
    'earnings': {
        'input_file': os.path.join('sin la propiedad results', 'earnings.json'),
        'output_file': os.path.join('camposfaltantes', 'earnings_transformed.json'),
        'id_field': 'earning_id',
        'id_type': 'Number',
        'fields_mapping': {
            'employee_id': 'employee_id',
            'department_id': 'department_id',
            'job_code': 'job_code',
            'calendar_year': 'calendar_year',
            'quarter': 'quarter',
            'base_salary': 'base_salary',
            'salary_type': 'salary_type',
            'overtime_gross_pay_qtd': 'overtime_gross_pay_qtd',
            'base_gross_pay_qtd': 'base_gross_pay_qtd',
            'longevity_gross_pay_qtd': 'longevity_gross_pay_qtd',
            'post_separation_gross_pay_qtd': 'post_separation_gross_pay_qtd',
            'miscellaneous_gross_pay_qtd': 'miscellaneous_gross_pay_qtd',
            'total_gross_pay': 'total_gross_pay'
        }
    }
}

# Procesar cada archivo JSON
for collection, config in mappings.items():
    print(f"Procesando {collection}...")
    transform_json(
        config['input_file'],
        config['output_file'],
        config['id_field'],
        config['fields_mapping'],
        config['id_type']
    )