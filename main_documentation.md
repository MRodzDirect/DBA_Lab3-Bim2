# Documentación del Procedimiento: Implementación de Base de Datos Oracle XE 11g con SQL Developer

## Introducción

Este documento detalla el proceso de diseño, implementación y optimización de una base de datos en Oracle XE 11g utilizando SQL Developer, a partir de un conjunto de datos proporcionado en formato CSV. El objetivo es construir un modelo de datos relacional robusto, importar eficientemente los datos, e incorporar lógica de negocio mediante triggers y procedimientos almacenados. Además, se analizará el rendimiento de consultas complejas, con y sin la aplicación de índices, para demostrar su impacto en la eficiencia de la base de datos.

La información aquí presentada busca ser una guía clara y concisa, permitiendo una comprensión rápida de los pasos clave y las decisiones tomadas durante el desarrollo. Se incluyen marcadores para capturas de pantalla que complementarán visualmente cada etapa del proceso.

## 1. Análisis del Dataset y Diseño del Modelo Relacional

El primer paso crucial fue comprender la estructura del archivo `employee_earnings_300000.csv`. Este dataset contiene una gran cantidad de registros relacionados con las ganancias de empleados, incluyendo información sobre su identidad, departamento, puesto de trabajo y diversos componentes salariales. La inspección inicial reveló la necesidad de normalizar los datos para evitar redundancias y asegurar la integridad referencial.

Se identificaron las siguientes entidades principales:

*   **EMPLOYEES**: Para almacenar la información básica de cada empleado.
*   **DEPARTMENTS**: Para los nombres y números de los departamentos.
*   **JOB_TITLES**: Para los códigos y títulos de los puestos de trabajo.
*   **EARNINGS**: Para los registros de ganancias de los empleados, que incluyen detalles salariales por año y trimestre.

La relación entre estas entidades es fundamental. Un empleado pertenece a un departamento y ocupa un puesto de trabajo. Los registros de ganancias están directamente asociados a un empleado, y a su vez, a un departamento y un puesto de trabajo, lo que permite un análisis detallado de las remuneraciones.

[IMAGEN 1: Captura de pantalla de la estructura del CSV o una vista previa en un editor de texto]
*Descripción: Vista de las primeras filas del archivo CSV, mostrando las columnas y el formato de los datos.* 

## 2. Creación de Modelos y Scripts SQL

El diseño de la base de datos se articuló a través de modelos conceptual, lógico y físico. Estos modelos sirvieron como planos para la construcción de la base de datos, asegurando una estructura coherente y optimizada.

### Modelo Conceptual

Representa las entidades y sus relaciones a un alto nivel, enfocándose en el 'qué' del negocio. Aquí se definieron las entidades `EMPLOYEE`, `DEPARTMENT`, `JOB_TITLE` y `EARNINGS` y sus interconexiones básicas.

[IMAGEN 2: Diagrama del Modelo Conceptual (Mermaid.js renderizado si es posible, o un placeholder para el diagrama generado)]
*Descripción: Diagrama que ilustra las entidades principales y sus relaciones generales.* 

### Modelo Lógico

Este modelo refina el conceptual, añadiendo atributos específicos a cada entidad y detallando las relaciones, pero aún de forma independiente de la tecnología de base de datos. Se definieron las claves primarias y foráneas lógicas.

[IMAGEN 3: Diagrama del Modelo Lógico (Mermaid.js renderizado si es posible, o un placeholder para el diagrama generado)]
*Descripción: Diagrama que muestra las entidades con sus atributos y las relaciones detalladas.* 

### Modelo Físico

El modelo físico es la implementación concreta para Oracle XE 11g. Se tradujeron las entidades y atributos a tablas y columnas SQL, especificando tipos de datos, restricciones de integridad (claves primarias, foráneas, `NOT NULL`) y la definición de secuencias para IDs autoincrementales. Los scripts SQL para la creación de estas tablas se generaron cuidadosamente para asegurar la compatibilidad y eficiencia con Oracle.

[IMAGEN 4: Captura de pantalla de SQL Developer mostrando los scripts SQL de creación de tablas]
*Descripción: Fragmento del script SQL con las sentencias `CREATE TABLE` para las tablas `EMPLOYEES`, `DEPARTMENTS`, `JOB_TITLES` y `EARNINGS`.* 

## 3. Importación de Datos CSV

La importación de 300,000 registros desde el CSV a la estructura relacional diseñada fue un paso crítico. Se optó por un enfoque en dos fases para manejar las dependencias de claves foráneas y asegurar la correcta normalización de los datos:

1.  **Carga a una Tabla Temporal:** Primero, el CSV completo se importó a una tabla temporal (`TEMP_EMPLOYEE_EARNINGS`) con todas las columnas definidas como `VARCHAR2`. Esto minimizó los problemas de tipo de datos durante la carga inicial.

    [IMAGEN 5: Captura de pantalla de SQL Developer mostrando la creación de la tabla temporal]
    *Descripción: Script SQL para la creación de la tabla `TEMP_EMPLOYEE_EARNINGS`.* 

    [IMAGEN 6: Captura de pantalla de SQL Developer mostrando el asistente de importación de datos CSV a la tabla temporal]
    *Descripción: Proceso de importación del CSV a `TEMP_EMPLOYEE_EARNINGS` usando el asistente de SQL Developer.* 

2.  **Transformación y Carga a Tablas Finales:** Una vez los datos estaban en la tabla temporal, se utilizaron sentencias `INSERT INTO ... SELECT FROM` para poblar las tablas `DEPARTMENTS`, `JOB_TITLES`, `EMPLOYEES` y `EARNINGS`. Este método permitió extraer los valores únicos para `DEPARTMENTS` y `JOB_TITLES`, y resolver las claves foráneas. Además, se realizaron conversiones de tipo de datos y cálculos de atributos derivados (como `total_gross_pay`) durante este proceso.

    [IMAGEN 7: Captura de pantalla de SQL Developer mostrando los scripts SQL para poblar DEPARTMENTS y JOB_TITLES]
    *Descripción: Sentencias `INSERT INTO ... SELECT DISTINCT` para poblar las tablas `DEPARTMENTS` y `JOB_TITLES`.* 

    [IMAGEN 8: Captura de pantalla de SQL Developer mostrando los scripts SQL para poblar EMPLOYEES y EARNINGS]
    *Descripción: Sentencias `INSERT INTO ... SELECT` para poblar las tablas `EMPLOYEES` y `EARNINGS`, incluyendo la lógica para `total_gross_pay`.* 

    [IMAGEN 9: Captura de pantalla de SQL Developer mostrando el resultado de la importación en una de las tablas finales]
    *Descripción: Vista de datos de la tabla `EARNINGS` después de la importación, mostrando los registros y el `total_gross_pay` calculado.* 





## 4. Implementación de Triggers, Procedimientos y Funciones

Para asegurar la integridad de los datos y automatizar ciertas tareas, se implementaron triggers y procedimientos almacenados. Estas piezas de lógica de base de datos son esenciales para mantener la consistencia y aplicar reglas de negocio directamente en el motor de la base de datos.

### Trigger para Cálculo de `total_gross_pay`

Se creó un trigger `trg_calculate_total_gross_pay` que se activa antes de cada inserción o actualización en la tabla `EARNINGS`. Su función es calcular automáticamente el `total_gross_pay` sumando los diversos componentes de pago (`base_salary`, `overtime_gross_pay_qtd`, etc.). Esto garantiza que este campo derivado siempre refleje la suma correcta de los ingresos, sin necesidad de que la aplicación cliente lo calcule.

[IMAGEN 10: Captura de pantalla de SQL Developer mostrando el script del trigger `trg_calculate_total_gross_pay`]
*Descripción: Script SQL para la creación del trigger `trg_calculate_total_gross_pay` y el mensaje de confirmación de su creación.* 

### Trigger para Validación de `base_salary`

Para prevenir la inserción de datos inconsistentes, se implementó el trigger `trg_validate_base_salary`. Este trigger verifica que el `base_salary` en la tabla `EARNINGS` no sea un valor negativo. Si se intenta insertar o actualizar un registro con un salario base negativo, el trigger lanza un error, impidiendo la operación y manteniendo la validez de los datos.

[IMAGEN 11: Captura de pantalla de SQL Developer mostrando el script del trigger `trg_validate_base_salary`]
*Descripción: Script SQL para la creación del trigger `trg_validate_base_salary` y el mensaje de confirmación de su creación.* 

### Procedimiento para Actualizar Nombre de Departamento

Se desarrolló el procedimiento almacenado `prc_update_department_name`. Este procedimiento toma un ID de departamento y un nuevo nombre, y actualiza el registro correspondiente en la tabla `DEPARTMENTS`. Incluye manejo de errores para casos donde el ID del departamento no existe, proporcionando una interfaz segura y controlada para la modificación de datos críticos.

[IMAGEN 12: Captura de pantalla de SQL Developer mostrando el script del procedimiento `prc_update_department_name`]
*Descripción: Script SQL para la creación del procedimiento `prc_update_department_name` y el mensaje de confirmación de su creación.* 

## 5. Desarrollo de Consultas Complejas y Análisis de Rendimiento

Para evaluar el rendimiento de la base de datos y demostrar la importancia de los índices, se diseñaron y ejecutaron cuatro consultas complejas. Cada consulta se ejecutó primero sin índices y luego con índices estratégicamente creados, registrando los tiempos de ejecución para comparar el impacto.

### Consultas sin Índices

Antes de la creación de cualquier índice, se ejecutaron las siguientes consultas. Los tiempos de ejecución en esta fase sirven como línea base para la comparación.

#### Consulta 1: Salario promedio por departamento y tipo de salario en un año específico

Esta consulta calcula el salario base promedio para cada combinación de departamento y tipo de salario en el año 2022. Involucra uniones y agrupamientos.

[IMAGEN 13: Captura de pantalla de SQL Developer mostrando la ejecución de la Consulta 1 sin índices y su tiempo de ejecución]
*Descripción: Hoja de trabajo de SQL Developer con la Consulta 1 ejecutada, mostrando el resultado y el tiempo de ejecución registrado.* 

#### Consulta 2: Empleados con el mayor `total_gross_pay` por departamento en un trimestre específico

Esta consulta identifica a los empleados con el `total_gross_pay` más alto dentro de cada departamento para el cuarto trimestre del año 2023. Requiere el uso de subconsultas o funciones de ventana.

[IMAGEN 14: Captura de pantalla de SQL Developer mostrando la ejecución de la Consulta 2 sin índices y su tiempo de ejecución]
*Descripción: Hoja de trabajo de SQL Developer con la Consulta 2 ejecutada, mostrando el resultado y el tiempo de ejecución registrado.* 

#### Consulta 3: Historial de salarios de un empleado específico a lo largo de los años

Esta consulta recupera el `base_salary` y `total_gross_pay` de un empleado específico a lo largo de los años y trimestres. Es una consulta que involucra filtrado por una clave y ordenamiento.

[IMAGEN 15: Captura de pantalla de SQL Developer mostrando la ejecución de la Consulta 3 sin índices y su tiempo de ejecución]
*Descripción: Hoja de trabajo de SQL Developer con la Consulta 3 ejecutada, mostrando el resultado y el tiempo de ejecución registrado.* 

#### Consulta 4: Conteo de empleados por categoría y departamento con salario base superior a un umbral

Esta consulta cuenta el número de empleados por categoría y departamento que tienen un `base_salary` superior a 80000. Implica múltiples uniones, filtrado y agrupamiento.

[IMAGEN 16: Captura de pantalla de SQL Developer mostrando la ejecución de la Consulta 4 sin índices y su tiempo de ejecución]
*Descripción: Hoja de trabajo de SQL Developer con la Consulta 4 ejecutada, mostrando el resultado y el tiempo de ejecución registrado.* 

### Creación de Índices

Para optimizar el rendimiento de las consultas, se crearon índices en las columnas más utilizadas en las cláusulas `WHERE`, `JOIN`, `ORDER BY` y `GROUP BY`. La selección de índices se basó en el análisis de los planes de ejecución de las consultas sin índices y en las mejores prácticas de diseño de bases de datos.

[IMAGEN 17: Captura de pantalla de SQL Developer mostrando los scripts de creación de índices]
*Descripción: Script SQL con las sentencias `CREATE INDEX` para los índices creados y el mensaje de confirmación de su creación.* 

### Consultas con Índices

Después de la creación de los índices, se volvieron a ejecutar las mismas cuatro consultas. Se observó una mejora significativa en los tiempos de ejecución, lo que valida la eficacia de los índices en la optimización del rendimiento de la base de datos.

#### Consulta 1: Salario promedio por departamento y tipo de salario en un año específico (Con Índices)

[IMAGEN 18: Captura de pantalla de SQL Developer mostrando la ejecución de la Consulta 1 con índices y su tiempo de ejecución]
*Descripción: Hoja de trabajo de SQL Developer con la Consulta 1 ejecutada después de la creación de índices, mostrando el resultado y el tiempo de ejecución reducido.* 

#### Consulta 2: Empleados con el mayor `total_gross_pay` por departamento en un trimestre específico (Con Índices)

[IMAGEN 19: Captura de pantalla de SQL Developer mostrando la ejecución de la Consulta 2 con índices y su tiempo de ejecución]
*Descripción: Hoja de trabajo de SQL Developer con la Consulta 2 ejecutada después de la creación de índices, mostrando el resultado y el tiempo de ejecución reducido.* 

#### Consulta 3: Historial de salarios de un empleado específico a lo largo de los años (Con Índices)

[IMAGEN 20: Captura de pantalla de SQL Developer mostrando la ejecución de la Consulta 3 con índices y su tiempo de ejecución]
*Descripción: Hoja de trabajo de SQL Developer con la Consulta 3 ejecutada después de la creación de índices, mostrando el resultado y el tiempo de ejecución reducido.* 

#### Consulta 4: Conteo de empleados por categoría y departamento con salario base superior a un umbral (Con Índices)

[IMAGEN 21: Captura de pantalla de SQL Developer mostrando la ejecución de la Consulta 4 con índices y su tiempo de ejecución]
*Descripción: Hoja de trabajo de SQL Developer con la Consulta 4 ejecutada después de la creación de índices, mostrando el resultado y el tiempo de ejecución reducido.* 

### Análisis de Resultados de Rendimiento

La comparación de los tiempos de ejecución y los planes de ejecución (accesibles en SQL Developer) antes y después de la creación de índices, demuestra claramente cómo los índices reducen la cantidad de datos que el motor de la base de datos necesita leer, transformando operaciones costosas de escaneo completo de tablas en búsquedas rápidas y eficientes. Esto se traduce en una mejora sustancial en la capacidad de respuesta de las consultas, especialmente en bases de datos con grandes volúmenes de información.

[IMAGEN 22: Captura de pantalla de SQL Developer mostrando el plan de ejecución de una consulta sin índices]
*Descripción: El plan de ejecución de una de las consultas complejas antes de la creación de índices, destacando operaciones costosas como Full Table Scans.*

[IMAGEN 23: Captura de pantalla de SQL Developer mostrando el plan de ejecución de la misma consulta con índices]
*Descripción: El plan de ejecución de la misma consulta después de la creación de índices, mostrando el uso de Index Scans y una reducción en el costo estimado.*





## Conclusión

La implementación de la base de datos en Oracle XE 11g, siguiendo un proceso estructurado desde el análisis del dataset hasta la optimización del rendimiento, demuestra la importancia de un diseño de base de datos cuidadoso y la aplicación de técnicas de optimización. La normalización de los datos, la implementación de lógica de negocio a través de triggers y procedimientos, y la creación estratégica de índices son pilares fundamentales para construir sistemas de bases de datos eficientes, robustos y mantenibles. Este enfoque no solo asegura la integridad y consistencia de los datos, sino que también mejora significativamente la capacidad de respuesta de las consultas, lo cual es crucial en entornos con grandes volúmenes de información.

Este documento, junto con el de decisiones de diseño, sirve como una referencia completa para comprender el proceso y las justificaciones detrás de cada elección técnica, facilitando futuras extensiones o modificaciones del sistema.


