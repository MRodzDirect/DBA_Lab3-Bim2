--1 

SET TIMING ON;
SELECT
    (SELECT department_name FROM DEPARTMENTS WHERE department_id = E.department_id) AS department_name,
    E.salary_type,
    AVG(E.base_salary) AS average_base_salary
FROM
    EARNINGS E
WHERE
    E.calendar_year = 2022
    AND E.department_id IN (SELECT department_id FROM DEPARTMENTS)
GROUP BY
    E.department_id,
    E.salary_type
ORDER BY
    E.department_id,
    E.salary_type;
SET TIMING OFF;
    
    
-- SELECT * FROM EARNINGS e WHERE e.total_gross_pay<0;
-- SELECT total_gross_pay FROM earnings;

-- 2
SET TIMING ON;
SELECT
    (SELECT first_name FROM EMPLOYEES WHERE employee_id = ER.employee_id) AS first_name,
    (SELECT last_name FROM EMPLOYEES WHERE employee_id = ER.employee_id) AS last_name,
    (SELECT department_name FROM DEPARTMENTS WHERE department_id = ER.department_id) AS department_name,
    ER.total_gross_pay
FROM
    EARNINGS ER
WHERE
    ER.calendar_year = 2023 
    AND ER.quarter = 4
    AND ER.department_id IN (SELECT department_id FROM DEPARTMENTS)
    AND ER.employee_id IN (SELECT employee_id FROM EMPLOYEES)
    AND ER.total_gross_pay = (
        SELECT MAX(total_gross_pay)
        FROM EARNINGS
        WHERE department_id = ER.department_id
        AND calendar_year = 2023 
        AND quarter = 4
    );
SET TIMING OFF;

--3

SET TIMING ON;
SELECT
    (SELECT first_name FROM EMPLOYEES WHERE employee_id = ER.employee_id) AS first_name,
    (SELECT last_name FROM EMPLOYEES WHERE employee_id = ER.employee_id) AS last_name,
    ER.calendar_year,
    ER.quarter,
    ER.base_salary,
    ER.total_gross_pay
FROM
    EARNINGS ER
WHERE
    ER.employee_id = 34277 
    AND ER.employee_id IN (SELECT employee_id FROM EMPLOYEES)
ORDER BY
    ER.calendar_year,
    ER.quarter;
SET TIMING OFF;

--4
SET TIMING ON;
SELECT
    (SELECT department_name FROM DEPARTMENTS WHERE department_id = E.department_id) AS department_name,
    (SELECT employee_category FROM EMPLOYEES WHERE employee_id = E.employee_id) AS employee_category,
    COUNT(DISTINCT E.employee_id) AS number_of_employees
FROM
    EARNINGS E
WHERE
    E.base_salary > 80000
    AND E.department_id IN (SELECT department_id FROM DEPARTMENTS)
    AND E.employee_id IN (SELECT employee_id FROM EMPLOYEES)
GROUP BY
    E.department_id,
    E.employee_id
ORDER BY
    E.department_id,
    E.employee_id;
SET TIMING OFF;