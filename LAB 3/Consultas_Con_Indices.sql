--1
SET TIMING ON;
SELECT
    D.department_name,
    E.salary_type,
    AVG(E.base_salary) AS average_base_salary
FROM
    EARNINGS E
    JOIN DEPARTMENTS D ON E.department_id = D.department_id
WHERE
    E.calendar_year = 2022
GROUP BY
    D.department_name,
    E.salary_type
ORDER BY
    D.department_name,
    E.salary_type;
SET TIMING OFF;
    
--2
SET TIMING ON;
WITH MaxPay AS (
    SELECT
        department_id,
        MAX(total_gross_pay) AS max_gross_pay
    FROM
        EARNINGS
    WHERE
        calendar_year = 2023
        AND quarter = 4
    GROUP BY
        department_id
)
SELECT
    E.first_name,
    E.last_name,
    D.department_name,
    ER.total_gross_pay
FROM
    EARNINGS ER
    JOIN MaxPay MP ON ER.department_id = MP.department_id AND ER.total_gross_pay = MP.max_gross_pay
    JOIN EMPLOYEES E ON ER.employee_id = E.employee_id
    JOIN DEPARTMENTS D ON ER.department_id = D.department_id
WHERE
    ER.calendar_year = 2023
    AND ER.quarter = 4;
SET TIMING OFF;
--3
SET TIMING ON;
SELECT
    E.first_name,
    E.last_name,
    ER.calendar_year,
    ER.quarter,
    ER.base_salary,
    ER.total_gross_pay
FROM
    EARNINGS ER
    JOIN EMPLOYEES E ON ER.employee_id = E.employee_id
WHERE
    ER.employee_id = 34277
ORDER BY
    ER.calendar_year,
    ER.quarter;
SET TIMING OFF;
--4
SET TIMING ON;
SELECT
    D.department_name,
    E.employee_category,
    COUNT(DISTINCT E.employee_id) AS number_of_employees
FROM
    EARNINGS ER
    JOIN EMPLOYEES E ON ER.employee_id = E.employee_id
    JOIN DEPARTMENTS D ON ER.department_id = D.department_id
WHERE
    ER.base_salary > 80000
GROUP BY
    D.department_name,
    E.employee_category
ORDER BY
    D.department_name,
    E.employee_category;
SET TIMING OFF;