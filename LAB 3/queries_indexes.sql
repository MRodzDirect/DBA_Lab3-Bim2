-- Consulta 1: Salario promedio por departamento y tipo de salario en un año específico
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

-- Consulta 2: Empleados con el mayor total_gross_pay por departamento en un trimestre específico
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

-- Consulta 3: Historial de salarios de un empleado específico a lo largo de los años
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

-- Consulta 4: Conteo de empleados por categoría y departamento con salario base superior a un umbral
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

-- Creación de Índices
CREATE INDEX idx_earnings_year_quarter ON EARNINGS (calendar_year, quarter);
CREATE INDEX idx_earnings_department_id ON EARNINGS (department_id);
CREATE INDEX idx_earnings_employee_id ON EARNINGS (employee_id);
CREATE INDEX idx_earnings_base_salary ON EARNINGS (base_salary);
CREATE INDEX idx_earnings_dept_total_pay ON EARNINGS (department_id, total_gross_pay);
CREATE INDEX idx_employees_category ON EMPLOYEES (employee_category);


