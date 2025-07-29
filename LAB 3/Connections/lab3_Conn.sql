CREATE TABLE EMPLOYEES (
    employee_id NUMBER PRIMARY KEY,
    first_name VARCHAR2(100),
    last_name VARCHAR2(100),
    employee_category VARCHAR2(50),
    compulsory_union_code VARCHAR2(10),
    termination_month NUMBER(2),
    termination_year NUMBER(4)
);

CREATE TABLE DEPARTMENTS (
    department_id NUMBER PRIMARY KEY,
    department_name VARCHAR2(200)
);

CREATE TABLE JOB_TITLES (
    job_code VARCHAR2(20) PRIMARY KEY,
    title VARCHAR2(200)
);

CREATE TABLE EARNINGS (
    earning_id NUMBER PRIMARY KEY,
    employee_id NUMBER NOT NULL,
    department_id NUMBER NOT NULL,
    job_code VARCHAR2(20) NOT NULL,
    calendar_year NUMBER(4) NOT NULL,
    quarter NUMBER(1) NOT NULL,
    base_salary NUMBER(10, 2),
    salary_type VARCHAR2(50),
    overtime_gross_pay_qtd NUMBER(10, 2),
    base_gross_pay_qtd NUMBER(10, 2),
    longevity_gross_pay_qtd NUMBER(10, 2),
    post_separation_gross_pay_qtd NUMBER(10, 2),
    miscellaneous_gross_pay_qtd NUMBER(10, 2),
    total_gross_pay NUMBER(10, 2),
    CONSTRAINT fk_employee
        FOREIGN KEY (employee_id)
        REFERENCES EMPLOYEES(employee_id),
    CONSTRAINT fk_department
        FOREIGN KEY (department_id)
        REFERENCES DEPARTMENTS(department_id),
    CONSTRAINT fk_job_title
        FOREIGN KEY (job_code)
        REFERENCES JOB_TITLES(job_code)
);

CREATE SEQUENCE earnings_seq
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;

CREATE OR REPLACE TRIGGER earnings_before_insert -- trigger de control
BEFORE INSERT ON EARNINGS
FOR EACH ROW
BEGIN
    IF :NEW.earning_id IS NULL THEN
        SELECT earnings_seq.NEXTVAL
        INTO :NEW.earning_id
        FROM dual;
    END IF;
END;

 -- tabla temporal
 
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


-- creacion de triggers

CREATE OR REPLACE TRIGGER trg_calculate_total_gross_pay -- trigger para atributo
-- derivado: del salario total grueso que se debe pagar al empleado
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

CREATE OR REPLACE TRIGGER trg_validate_base_salary
BEFORE INSERT OR UPDATE ON EARNINGS
FOR EACH ROW
BEGIN
    IF :NEW.base_salary < 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'El salario base no puede ser negativo.');
    END IF;
END;
/

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



--- despues de insercioin
SELECT count(*) FROM EMPLOYEES;

