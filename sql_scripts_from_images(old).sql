-- Este archivo contiene los scripts SQL correspondientes a las acciones descritas en las capturas de pantalla.
-- Cada sección se corresponde con la imagen referenciada en la documentación principal.




-- IMAGEN 5: Script SQL para la creación de la tabla `TEMP_EMPLOYEE_EARNINGS`.
-- Esta tabla temporal se utiliza para cargar los datos crudos del CSV antes de su procesamiento y normalización.
CREATE TABLE TEMP_EMPLOYEE_EARNINGS (
    the_geom VARCHAR2(200),
    cartodb_id NUMBER,
    the_geom_webmercator VARCHAR2(200),
    objectid NUMBER,
    calendar_year NUMBER,
    quarter NUMBER,
    last_name VARCHAR2(100),
    first_name VARCHAR2(100),
    title VARCHAR2(200),
    job_code VARCHAR2(20),
    department_name VARCHAR2(200),
    department_number NUMBER,
    base_salary VARCHAR2(50), -- Importar como VARCHAR2 para manejar formatos variados
    salary_type VARCHAR2(50),
    overtime_gross_pay_qtd VARCHAR2(50),
    base_gross_pay_qtd VARCHAR2(50),
    longevity_gross_pay_qtd VARCHAR2(50),
    post_separation_gross_pay_qtd VARCHAR2(50),
    miscellaneous_gross_pay_qtd VARCHAR2(50),
    employee_category VARCHAR2(50),
    compulsory_union_code VARCHAR2(10),
    termination_month VARCHAR2(10),
    termination_year VARCHAR2(10),
    public_id NUMBER
);




-- IMAGEN 10: Script SQL para la creación del trigger `trg_calculate_total_gross_pay`.
-- Este trigger calcula automáticamente el total_gross_pay antes de cada inserción o actualización en la tabla EARNINGS.
CREATE OR REPLACE TRIGGER trg_calculate_total_gross_pay
BEFORE INSERT OR UPDATE ON EARNINGS
FOR EACH ROW
BEGIN
    :NEW.total_gross_pay := NVL(:NEW.base_salary, 0) +
                            NVL(:NEW.overtime_gross_pay_qtd, 0) +
                            NVL(:NEW.base_gross_pay_qtd, 0) +
                            NVL(:NEW.longevity_gross_pay_qtd, 0) +
                            NVL(:NEW.post_separation_gross_pay_qtd, 0) +
                            NVL(:NEW.miscellaneous_gross_pay_qtd, 0);
END;
/




-- IMAGEN 11: Script SQL para la creación del trigger `trg_validate_base_salary`.
-- Este trigger valida que el salario base no sea negativo, lanzando un error si la condición se cumple.
CREATE OR REPLACE TRIGGER trg_validate_base_salary
BEFORE INSERT OR UPDATE ON EARNINGS
FOR EACH ROW
BEGIN
    IF :NEW.base_salary < 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'El salario base no puede ser negativo.');
    END IF;
END;
/




-- IMAGEN 12: Script SQL para la creación del procedimiento `prc_update_department_name`.
-- Este procedimiento permite actualizar el nombre de un departamento dado su ID, con manejo de errores.
CREATE OR REPLACE PROCEDURE prc_update_department_name (
    p_department_id IN DEPARTMENTS.department_id%TYPE,
    p_new_department_name IN DEPARTMENTS.department_name%TYPE
)
IS
BEGIN
    UPDATE DEPARTMENTS
    SET department_name = p_new_department_name
    WHERE department_id = p_department_id;

    IF SQL%ROWCOUNT = 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Departamento con ID ' || p_department_id || ' no encontrado.');
    END IF;

    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END;
/




-- IMAGEN 13: Script SQL para la Consulta 1 (sin índices).
-- Esta consulta calcula el salario promedio por departamento y tipo de salario en un año específico.
SELECT
    d.department_name,
    e.salary_type,
    AVG(e.base_salary) AS average_base_salary
FROM
    EARNINGS e
JOIN
    DEPARTMENTS d ON e.department_id = d.department_id
WHERE
    e.calendar_year = 2022
GROUP BY
    d.department_name,
    e.salary_type
ORDER BY
    d.department_name, e.salary_type;




-- IMAGEN 14: Script SQL para la Consulta 2 (sin índices).
-- Esta consulta identifica a los empleados con el mayor total_gross_pay por departamento en un trimestre específico.
SELECT
    e.first_name,
    e.last_name,
    d.department_name,
    er.total_gross_pay
FROM
    EMPLOYEES e
JOIN
    EARNINGS er ON e.employee_id = er.employee_id
JOIN
    DEPARTMENTS d ON er.department_id = d.department_id
WHERE
    (er.department_id, er.total_gross_pay) IN (
        SELECT
            department_id,
            MAX(total_gross_pay)
        FROM
            EARNINGS
        WHERE
            calendar_year = 2023 AND quarter = 4
        GROUP BY
            department_id
    );




-- IMAGEN 15: Script SQL para la Consulta 3 (sin índices).
-- Esta consulta recupera el historial de salarios de un empleado específico a lo largo de los años y trimestres.
SELECT
    e.first_name,
    e.last_name,
    er.calendar_year,
    er.quarter,
    er.base_salary,
    er.total_gross_pay
FROM
    EMPLOYEES emp
JOIN
    EARNINGS er ON emp.employee_id = er.employee_id
WHERE
    emp.employee_id = 34277 -- Ejemplo de public_id
ORDER BY
    er.calendar_year, er.quarter;




-- IMAGEN 16: Script SQL para la Consulta 4 (sin índices).
-- Esta consulta cuenta el número de empleados por categoría y departamento con salario base superior a un umbral.
SELECT
    d.department_name,
    emp.employee_category,
    COUNT(DISTINCT emp.employee_id) AS number_of_employees
FROM
    EMPLOYEES emp
JOIN
    EARNINGS er ON emp.employee_id = er.employee_id
JOIN
    DEPARTMENTS d ON er.department_id = d.department_id
WHERE
    er.base_salary > 80000
GROUP BY
    d.department_name,
    emp.employee_category
ORDER BY
    d.department_name, emp.employee_category;




-- IMAGEN 17: Script SQL para la creación de índices.
-- Estos índices están diseñados para optimizar el rendimiento de las consultas complejas.
CREATE INDEX idx_earnings_year_quarter ON EARNINGS (calendar_year, quarter);
CREATE INDEX idx_earnings_department_id ON EARNINGS (department_id);
CREATE INDEX idx_earnings_employee_id ON EARNINGS (employee_id);
CREATE INDEX idx_earnings_base_salary ON EARNINGS (base_salary);
CREATE INDEX idx_earnings_dept_total_pay ON EARNINGS (department_id, total_gross_pay);
CREATE INDEX idx_employees_category ON EMPLOYEES (employee_category);




-- IMAGEN 18: Script SQL para la Consulta 1 (con índices).
-- Esta consulta calcula el salario promedio por departamento y tipo de salario en un año específico, optimizada con índices.
SELECT
    d.department_name,
    e.salary_type,
    AVG(e.base_salary) AS average_base_salary
FROM
    EARNINGS e
JOIN
    DEPARTMENTS d ON e.department_id = d.department_id
WHERE
    e.calendar_year = 2022
GROUP BY
    d.department_name,
    e.salary_type
ORDER BY
    d.department_name, e.salary_type;




-- IMAGEN 19: Script SQL para la Consulta 2 (con índices).
-- Esta consulta identifica a los empleados con el mayor total_gross_pay por departamento en un trimestre específico, optimizada con índices.
SELECT
    e.first_name,
    e.last_name,
    d.department_name,
    er.total_gross_pay
FROM
    EMPLOYEES e
JOIN
    EARNINGS er ON e.employee_id = er.employee_id
JOIN
    DEPARTMENTS d ON er.department_id = d.department_id
WHERE
    (er.department_id, er.total_gross_pay) IN (
        SELECT
            department_id,
            MAX(total_gross_pay)
        FROM
            EARNINGS
        WHERE
            calendar_year = 2023 AND quarter = 4
        GROUP BY
            department_id
    );




-- IMAGEN 20: Script SQL para la Consulta 3 (con índices).
-- Esta consulta recupera el historial de salarios de un empleado específico a lo largo de los años y trimestres, optimizada con índices.
SELECT
    e.first_name,
    e.last_name,
    er.calendar_year,
    er.quarter,
    er.base_salary,
    er.total_gross_pay
FROM
    EMPLOYEES emp
JOIN
    EARNINGS er ON emp.employee_id = er.employee_id
WHERE
    emp.employee_id = 34277 -- Ejemplo de public_id
ORDER BY
    er.calendar_year, er.quarter;




-- IMAGEN 21: Script SQL para la Consulta 4 (con índices).
-- Esta consulta cuenta el número de empleados por categoría y departamento con salario base superior a un umbral, optimizada con índices.
SELECT
    d.department_name,
    emp.employee_category,
    COUNT(DISTINCT emp.employee_id) AS number_of_employees
FROM
    EMPLOYEES emp
JOIN
    EARNINGS er ON emp.employee_id = er.employee_id
JOIN
    DEPARTMENTS d ON er.department_id = d.department_id
WHERE
    er.base_salary > 80000
GROUP BY
    d.department_name,
    emp.employee_category
ORDER BY
    d.department_name, emp.employee_category;




-- IMAGEN 22: Script SQL para ver el plan de ejecución de una consulta sin índices.
-- Este comando permite visualizar cómo Oracle ejecuta la Consulta 1 antes de aplicar cualquier índice.
-- Ejecuta estas líneas en SQL Developer para obtener el plan de ejecución.
EXPLAIN PLAN FOR
SELECT
    d.department_name,
    e.salary_type,
    AVG(e.base_salary) AS average_base_salary
FROM
    EARNINGS e
JOIN
    DEPARTMENTS d ON e.department_id = d.department_id
WHERE
    e.calendar_year = 2022
GROUP BY
    d.department_name,
    e.salary_type
ORDER BY
    d.department_name, e.salary_type;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);




-- IMAGEN 23: Script SQL para ver el plan de ejecución de una consulta con índices.
-- Este comando permite visualizar cómo Oracle ejecuta la Consulta 1 después de aplicar los índices.
-- Ejecuta estas líneas en SQL Developer para obtener el plan de ejecución.
EXPLAIN PLAN FOR
SELECT
    d.department_name,
    e.salary_type,
    AVG(e.base_salary) AS average_base_salary
FROM
    EARNINGS e
JOIN
    DEPARTMENTS d ON e.department_id = d.department_id
WHERE
    e.calendar_year = 2022
GROUP BY
    d.department_name,
    e.salary_type
ORDER BY
    d.department_name, e.salary_type;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);



