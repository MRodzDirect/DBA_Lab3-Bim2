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


